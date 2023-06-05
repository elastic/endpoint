# [Windows] Elastic Defend (Endpoint) high CPU utilization

This article pertains to the Elastic Defend (Endpoint) on Windows.

## Introduction

This article aims to provide a greater understanding of the causes of Elastic Defend’s system resource utilization, and provides workarounds for some common problems that users may encounter, especially when deploying Defend alongside other security software.

## Event Collection

The Elastic Endpoint (part of Elastic Defend) monitors activity across your system.  In response to the actions of other programs, it collects information including:

* Process Creation/Termination
* File Access/Creation/Modification/Rename/Deletion
* Registry modifications
* Network activity
* DNS activity
* Windows Security Logs
* Threat Intelligence API Activity (such as process injection)

It may or may not forward these events to your Elastic Stack.  If events are disabled in policy, Defend  won’t stream these events to ElasticSearch, but it may still collect and enrich them to support other features such as Behavioral Protections.

## Event Enrichment

Beyond collecting the base event information, Defend also collects additional information to enrich each event.  For example, it computes and verifies digital signatures to include signer information in every process event.  It also parses PE files to extract their [Original File Names](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.fileversioninfo.originalfilename?view=net-7.0).  These are just some examples - there are many more enrichments.

Collecting this information requires CPU cycles, and may require I/O.  For example, when a file is written, the Defend must then read that file to scan it for malware.  This involves checking its digital signature, computing file hashes, computing file entropy for its Machine Learning model, and scanning the file with yara.

## Behavioral Protections
If Behavioral Protections are enabled, Defend runs all collected events through a stateful rules engine that checks for (and quickly reacts to) [hundreds](https://github.com/elastic/protections-artifacts/tree/main/behavior/rules) of known-malicious patterns of behavior.  This evaluation process requires CPU cycles.

# Feedback Loops
Defend reacts to activity on your system, generating its own activity in response.  Problems can arise on systems running other software that does the same thing.  Example of such software include:

* Anti-Malware (AM) / Anti-Virus (AV)
* Endpoint Detection and Response (EDR)
* eXtended Detection and Response (XDR)
* Endpoint Protection Platform (EPP)
* Data Loss Prevention (DLP)
* Employee Monitoring Software
* Application Virtualization Software

If two or more applications react to system activity by generating their own activity, then feedback loops are possible.  These feedback loops can cause spikes in resource usage for either or both products, or lead to [deadlocks](https://en.wikipedia.org/wiki/Deadlock) that cause the system to hang.

Imagine the following scenario with hypothetical third-party AV product:

1. A user downloads a file with their web browser
2. Elastic Defend's filesystem minifilter driver intercepts this file creation and asks its user-mode component, `elastic-endpoint.exe`, to scan the file.
3. `elastic-endpoint.exe` attempts to open the file to scan it.
4. AV's filesystem minifilter driver sees an application (`elastic-endpoint.exe`) opening a file and intercepts it, asking its user-mode process to scan a file.
5. AV's user-mode process `AV.exe` attempts to open the file to scan it.
6. Elastic Defend's filesystem minifilter driver intercepts `AV.exe`'s activity and asks its user-mode component, `elastic-endpoint.exe`, to scan the file.
7. `elastic-endpoint.exe` attempts to open the file to scan it.
8. AV's filesystem minifilter driver sees an application (`elastic-endpoint.exe`) opening a file and intercepts it, asking its user-mode process to scan a file.
9. AV's user-mode process `AV.exe` attempts to open the file to scan it.
10. ... the loop continues

Such feedback loops degrade system performance and responsiveness, and can lead to spikes in CPU and I/O utilization.  There are variations of this too, such as where the AV makes a temporary copy of the file to scan it asynchronously.  Interactions can get even more complex when there are more than two products installed on a system.

# Trusted Applications
Generally, it's not recommended to run multiple AV applications simultaneously. Here is AV Comparatives' take on it, titled "[Why you should never have multiple antivirus programs on your computer](https://www.av-comparatives.org/why-you-should-never-have-multiple-antivirus-programs-on-your-computer)."  Despite this, some users prefer to run multiple security products simultaneously.  In response, we created [Trusted Applications](https://www.elastic.co/guide/en/security/master/trusted-apps-ov.html) to help deal with these conflicts.  By having Defend ignore the activity of the other security software on your system, we can break this cycle, reduce wasted resources, and improve system performance.  By also adding Defend as a Trusted Application in the third-party security product, we can break this cycle even sooner for better performance and fewer wasted resources.  In the above example, even if both AV applications trust each other, both will still scan the file saved by the web browser.

While not guaranteed to resolve performance issues, Trusted Applications are a common first step when deploying new security software to an already-protected environment.  **If you intend to run multiple security applications in your environment and are encountering performance problems, we strongly recommend you deploy Trusted Applications ASAP.**

## Limitations of Trusted Applications
Trusted applications work on a process level.  Many security products also include kernel-level components (drivers) that can generate activity in [system worker threads](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/system-worker-threads) and/or [arbitrary thread contexts](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/driver-thread-context).  System worker threads run inside the System process in Task Manager, which should not be added as a Trusted Application.  Activity generated within an arbitrary thread context can come from any thread (in any process) on the system while it is executing in kernel mode, such as performing a system call.

Many security products also inject DLLs into processes throughout the system to perform user-mode hooking.  For example, an EDR may inject a DLL into Microsoft Office in order to intercept specific intra-process activity that is not easily accessible from its kernel driver.  In this example, activity generated by this injected DLL appears to come from Microsoft Office, not the EDR.  Microsoft Office should not be added as a Trusted Application, so Trusted Applications will likely not be able to work around issues stemming from this activity.

## Trusting Elastic Defend in Other Software
While adding your existing AV/EDR/EPP/DLP/etc software as a Trusted Application in Elastic Defend can help performance, better performance will be achieved (with fewer compatibility issues) if the trust is mutual.  Defend calls these exclusions Trusted Applications, but other products may call them Process Exclusions, Ignored Processes, or Trusted Processes.  **It is important to note that file-, folder-, and path-based exclusions/exceptions are distinct from Trusted Applications and will NOT achieve the same result.  The goal here is to ignore actions taken BY a process, not ignore the file that the process was spawned from.  Files are different from processes.**

The Elastic Defend’s main executable is “`C:\Program Files\Elastic\Endpoint\elastic-endpoint.exe`”.  It is signed by “`Elasticsearch, Inc.`” (spaces included, sans quotes).  There may be a secondary signature from “`Elasticsearch B.V.`”, though this may change in future releases.  When adding Defend as a Trusted Application in a third-party product, you should require both the path and the signer to match if possible.  This will reduce the risk of an attacker exploiting the gap created by this trust.

Here is an example of the process exclusion UI in Microsoft Defender:

![image](https://github.com/elastic/endpoint/assets/42078554/c660fd36-d4c3-4ea3-bdb9-d9d7571caac2)

# Third-Party Resources
Below are some resources to help you add Defend as a Trusted Application in your third-party security software.  If you use a product not listed here, try searching for “[PRODUCTNAME add process exclusion](https://www.google.com/search?q=PRODUCTNAME+add+process+exclusion)”

| Product | Resources |
| - | - |
| Microsoft Defender | [How to add a file type or process exclusion to Windows Security](https://support.microsoft.com/en-us/topic/how-to-add-a-file-type-or-process-exclusion-to-windows-security-e524cbc2-3975-63c2-f9d1-7c2eb5331e53)<br>[Configure exclusions for files opened by processes](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-process-opened-file-exclusions-microsoft-defender-antivirus) | 
| Symantec Endpoint Protection | [Preventing SEP from scanning files accessed by a trusted process](https://knowledge.broadcom.com/external/article/199534/preventing-sep-from-scanning-files-acces.html) |
| Carbon Black Protection (Bit9) | [Anti-Virus Exclusions for Agent (Windows)](https://community.carbonblack.com/t5/Knowledge-Base/App-Control-Anti-Virus-Exclusions-for-Agent-Windows/ta-p/38334) <br> [Antivirus Exclusions for Server](https://community.carbonblack.com/t5/Knowledge-Base/App-Control-Antivirus-Exclusions-for-Server/ta-p/65891) |
| Carbon Black Cloud | [How to Set up Exclusions in the Carbon Black Cloud Console for AV Products](https://community.carbonblack.com/t5/Knowledge-Base/Carbon-Black-Cloud-How-to-Set-up-Exclusions-in-the-Carbon-Black/ta-p/42334) |
| Trend Micro | [Adding exclusion for Anti-Malware Real-Time Scan in Deep Security](https://success.trendmicro.com/dcx/s/solution/1122045-adding-exclusion-for-anti-malware-real-time-scan-in-deep-security?language=en_US) |
| SentinelOne | [SentinelOne - Path Exclusion](https://www.cybervigilance.uk/post/sentinelone-path-exclusion) <br> (SentinelOne appears to combine path and process exclusions) |
| Cisco Secure Endpoint / AMP | [Configure and Identify Cisco Secure Endpoint Exclusions](https://www.cisco.com/c/en/us/support/docs/security/amp-endpoints/213681-best-practices-for-amp-for-endpoint-excl.html#toc-hId-1814232963) |
