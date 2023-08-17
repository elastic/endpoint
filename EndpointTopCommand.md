# Identifying Endpoint CPU triggers with the `top` command

### Applicable Versions
- Elastic Endpoint 8.8.2+ (Windows only)
- Elastic Endpoint 8.9.0+ (All platforms)

## Background

Elastic Endpoint provides comprehensive Endpoint Detection Response (EDR) capabilities, combining malware protection, memory threat protection, ransomware protection, and a comprehensive behavioral protection (rules) engine.  Beyond these protections, Endpoint provides event collection, enrichment, and streaming.  In order to implement these protections, Endpoint must monitor and record activity performed by all processes on the system. This monitoring requires CPU and I/O.

For example, a software update may write out thousands of files and registry keys.  As these files are written, Endpoint must scan these files for malware, create file events describing them, enrich those events with information about the process that wrote them, and then evaluate these events against [hundreds](https://github.com/elastic/protections-artifacts/tree/main/behavior/rules) of behavioral protection rules to identify patterns of malicious behavior.  Simultaneously, Endpoint is analyzing this activity for behavior indicative of ransomware.

In other words, if Endpoint is consuming CPU, it's likely in response to some other activity occurring on the system.  Previously, it was difficult to identify which processes were causing Endpoint's resource usage, but it is now easier thanks to the `top` command.

## Introducing the new `top` command

![image](https://github.com/elastic/endpoint-dev/assets/42078554/f87aa385-b056-4891-80a3-6156f7f3566b)

Newer versions of Endpoint include a feature similar to `top` on POSIX platforms.  `top` graphically shows a breakdown of the processes that triggered Endpoint's CPU usage within the last 3 seconds.  Further, `top` breaks this activity down by feature.  `top` displays utilization in CPU-milliseconds.  On multi-core systems, there are 1000 CPU-milliseconds per core per second, so it's possible to have more than 3000ms in a given 3-second interval.

For example, it may indicate that Endpoint spent 1000ms within the last 3 seconds scanning files written by `msiexec.exe` for malware.  This information can be useful to both understand why Endpoint is using CPU, and to guide you in the creation of [Exceptions](https://www.elastic.co/guide/en/security/current/add-exceptions.html#endpoint-rule-exceptions) and [Trusted Applications](https://www.elastic.co/guide/en/security/current/trusted-apps-ov.html) to [optimize Endpoint](https://www.elastic.co/guide/en/security/current/endpoint-artifacts.html) for your environment.

## Demo
In the video below, we can see Endpoint's activity during the compilation of a large CMake project.  It's spending most of its time scanning `MSBuild.exe` and `powershell.exe` for in-memory threats.

https://github.com/elastic/endpoint/assets/42078554/c1bbd806-ccfa-4fbb-be08-553ef5c1175f

## Abbreviations

To fit everything on the screen, columns are abbreviated as follows:

| Abbreviation | Feature | How do I toggle this off? |
| - | - | - |
| MLWR | Malware Protection | Uncheck [Malware protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#malware-protection) |
| NET | Network Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection) |
| PROC | Process Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)| 
| FILE | File Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)| 
| REG | Registry Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)| 
| DNS | DNS Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)| 
| LIB | Library Load Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)| 
| AUTH | Authentication Events | Uncheck Security Events in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection) |
| CRED | Credential Access Events | Uncheck in [Event Collection](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#event-collection)|
| RANSOM | Ransomware Protection | Uncheck [Ransomware protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#ransomware-protection) |
| TI API | Threat Intelligence Events | In [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings), set `windows.advanced.events.api: false` |
| KEYBD | Keylogger Detection Events | In [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings), set `windows.advanced.events.api: false` |
| PROJ INJ | Process Injection Protection (part of Memory Protection) | Uncheck [Memory threat protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#memory-protection) to turn off Memory Protection entirely, or set `windows.advanced.memory_protection.shellcode: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) to turn off only Process Injection protection. |
| MEM SCAN | Memory Scanning (part of Memory Protection) | Uncheck [Memory threat protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#memory-protection) to turn off Memory Protection entirely, or set `*.advanced.memory_protection.memory_scan: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) to turn off only Memory Scanning. |
| BHVR | Malicious Behavior Protection (Rules Engine) | Uncheck [Malicious behavior protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#behavior-protection) |
| DIAG BHVR | Diagnostic Malicious Behavior Protection (Rules Engine) | Set `*.advanced.diagnostic.enabled: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) |


## Conclusion

The Elastic Endpoint team is constantly working to evaluate and improve performance, but every environment is unique with varying combinations of software and configurations.  The `top` command can help you gain a greater understanding of performance issues in your environment, empowering you to take action to [resolve](https://www.elastic.co/guide/en/security/current/endpoint-artifacts.html) them.
