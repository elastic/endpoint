# Identifying Endpoint CPU triggers with the `top` command

### Applicable Versions
- Elastic Endpoint 8.8.2+ (Windows only)
- Elastic Endpoint 8.9.0+ (All platforms)
- Elastic Endpoint 8.12.0 (new UI)

## Background

Elastic Endpoint provides comprehensive Endpoint Detection Response (EDR) capabilities, combining malware protection, memory threat protection, ransomware protection, and a comprehensive behavioral protection (rules) engine.  Beyond these protections, Endpoint provides event collection, enrichment, and streaming.  In order to implement these protections, Endpoint must monitor and record activity performed by all processes on the system. This monitoring requires CPU and I/O.

For example, a software update may write out thousands of files and registry keys.  As these files are written, Endpoint must scan these files for malware, create file events describing them, enrich those events with information about the process that wrote them, and then evaluate these events against [hundreds](https://github.com/elastic/protections-artifacts/tree/main/behavior/rules) of behavioral protection rules to identify patterns of malicious behavior.  Simultaneously, Endpoint is analyzing this activity for behavior indicative of ransomware.

In other words, if Endpoint is consuming CPU, it's likely in response to some other activity occurring on the system.  Previously, it was difficult to identify which processes were causing Endpoint's resource usage, but it is now easier thanks to the `top` command.

## The `top` command


```
| PROCESS            | OVERALL | AUTH | BHVR | DIAG BHVR | DNS | FILE | LIB | MLWR | MEM SCAN | NET | PROC | RANSOM | REG | TI API | UI API |
=============================================================================================================================================
| cmake.exe          |    16.4 |  0.0 |  0.2 |       1.9 | 0.0 | 10.9 | 0.0 |  3.3 |      0.0 | 0.0 |  0.1 |    0.0 | 0.0 |    0.0 |    0.0 |
| MSBuild.exe        |    11.6 |  0.0 |  0.9 |       1.3 | 0.0 |  0.5 | 2.7 |  5.3 |      0.0 | 0.0 |  0.9 |    0.0 | 0.0 |    0.0 |    0.0 |
| cmd.exe            |     6.1 |  0.0 |  1.3 |       1.7 | 0.0 |  0.1 | 0.0 |  0.0 |      1.2 | 0.0 |  1.7 |    0.0 | 0.0 |    0.1 |    0.0 |
| conhost.exe        |     1.6 |  0.0 |  0.3 |       0.4 | 0.0 |  0.0 | 0.1 |  0.0 |      0.0 | 0.0 |  0.8 |    0.0 | 0.0 |    0.0 |    0.0 |
| svchost.exe        |     1.2 |  0.0 |  0.0 |       0.0 | 0.0 |  1.2 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| Slack.exe          |     0.1 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| cl.exe             |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| msiexec.exe        |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| setup.exe          |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| chrome.exe         |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| Code.exe           |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| mscorsvw.exe       |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| msedge.exe         |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| vctip.exe          |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| mscorsvw.exe       |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| msedgewebview2.exe |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| filebeat.exe       |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| devenv.exe         |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| Tracker.exe        |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |
| link.exe           |     0.0 |  0.0 |  0.0 |       0.0 | 0.0 |  0.0 | 0.0 |  0.0 |      0.0 | 0.0 |  0.0 |    0.0 | 0.0 |    0.0 |    0.0 |

Endpoint service (16 CPU): 44.3% out of 1600%
```

_Image: Elastic Endpoint 8.12.0 running on Windows_

Newer versions of Endpoint include a feature similar to `top` on POSIX platforms.  `top` graphically shows a breakdown of the processes groups that triggered Endpoint's CPU usage. Further, `top` breaks this activity down by feature.  

`top` displays the percentage of time Endpoint service spent on particular process group not accounting for operating system's process scheduling, etc, also known as "the wall clock". In other words, it's a coarse indicator how much percent of service's CPU consumption might* be consumed by a particular work unit. Taking the above example, Elastic Endpoint service consumed 44.3% (out of 1600%) system CPU time, where 16% might* be consumed by work done on behalf of `cmake.exe`.

_\*Endpoint service, as a user mode process, cannot track reliably CPU time spent executing particular code path. Time measured by a wall clock is higher than real CPU time spent because the code path execution could get blocked on synchronization elements and as any process the Endpoint service shares CPU time with other processes_

Endpoint displays metrics for process groups as opposed to POSIX's `top` command displaying metrics per process. Taking the above example, there could have been multiple `MSBuild.exe` processes running at that time but the statistics for all of them are added together. This information can be useful to guide you in the creation of [Exceptions](https://www.elastic.co/guide/en/security/current/add-exceptions.html#endpoint-rule-exceptions) and [Trusted Applications](https://www.elastic.co/guide/en/security/current/trusted-apps-ov.html) to [optimize Endpoint](https://www.elastic.co/guide/en/security/current/endpoint-artifacts.html) for your environment.

If you prefer to see values normalized to 100%, regardless of how many logical processors you have, use `top --normalized`

**Note** 

The `top` statistics are far from perfect but they are tried and tested tool to fine tune Endpoint configuration to eliminate outliers. 

The content comes from Endpoint metrics module which writes the metrics document to `metrics-endpoint.metrics-*` index, `Endpoint.metrics.system_impact` node. Endpoint has been collecting it since many releases, aggregating data over a week for each executing binary:
```
{
    "process": {
    "executable": """C:\Program Files\Elastic\Agent\data\elastic-agent-dc443b\components\metricbeat.exe"""
    },
    "process_events": {
    "week_ms": 74
    },
    "overall": {
    "week_ms": 74
    }
},
```
This has helped us to see what the customer is experiencing in their environment anytime they contacted our support about performance issues. Moreover we could clearly see which feature required tuning.

**Takeaway: it's not about precise numbers**

The name `top` was chosen for the general meaning, not to indicate a close relationship with POSIX `top` command output. Don't expect to have a precise breakdown of real time Endpoint CPU usage by Endpoint's feature. Even though we give you `--interval x` option don't be tempted to set it too low, the lower it is the higher the error. Focus your attention on numbers standing out over longer time, if you can clearly see an outlier consider adding an Exception or Trusted Application and validate the effect in `top` after policy change.

#### Earlier implementations

Earlier implementations displayed the raw time statistics, in milliseconds, gathered in fixed time interval. To get the percentage view, you'd need to divide (value displayed)/(interval in millisecond). The Endpoint service CPU utilization % was normalized to 100%.

- Elastic Endpoint 8.8.2+ used interval 3000 ms.
- Elastic Endpoint 8.9.0+ used interval 5000 ms.

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
| UI API | win32k API Events | In [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings), set `windows.advanced.events.api: false` |
| PROJ INJ | Process Injection Protection (part of Memory Protection) | Uncheck [Memory threat protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#memory-protection) to turn off Memory Protection entirely, or set `windows.advanced.memory_protection.shellcode: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) to turn off only Process Injection protection. |
| MEM SCAN | Memory Scanning (part of Memory Protection) | Uncheck [Memory threat protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#memory-protection) to turn off Memory Protection entirely, or set `*.advanced.memory_protection.memory_scan: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) to turn off only Memory Scanning. |
| BHVR | Malicious Behavior Protection (Rules Engine) | Uncheck [Malicious behavior protections enabled](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#behavior-protection) |
| DIAG BHVR | Diagnostic Malicious Behavior Protection (Rules Engine) | Set `*.advanced.diagnostic.enabled: false` in [Advanced Policy](https://www.elastic.co/guide/en/security/8.9/configure-endpoint-integration-policy.html#adv-policy-settings) |

_*For up-to-date list of abbreviations consult built in help, `elastic-endpoint --help`_

## Conclusion

The Elastic Endpoint team is constantly working to evaluate and improve performance, but every environment is unique with varying combinations of software and configurations.  The `top` command can help you gain a greater understanding of performance issues in your environment, empowering you to take action to [resolve](https://www.elastic.co/guide/en/security/current/endpoint-artifacts.html) them.
