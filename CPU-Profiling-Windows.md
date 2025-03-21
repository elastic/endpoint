# Collecting Windows CPU Traces

When reporting a CPU usage issue to Elastic support, it can be helpful to provide a CPU profiling trace.  This allows Elastic support to precisely identify which portions of Defend's code are using CPU time during the capture.

It is important to only capture traces while the problematic behavior is occurring.  A trace captured on an idle system doesn't provide value.

## Windows Performance Recorder (WPR) Trace

Run this command then provide the generated `Defend-CPU.etl` to support:
```
powershell.exe -noprofile -command "&wpr.exe -start CPU -filemode; Start-Sleep 60; &wpr.exe -stop Defend-CPU.etl -compress -skipPdbGen; &wpr.exe -stop Defend-CPU.etl"
```

### Corrupted WPR Traces
Due to the volume of data captured, CPU profiling is a very resource-intensive operation.  It requires spare CPU and disk I/O to be effectively capture and record the data.  If either CPU or I/O cannot keep up, the resulting trace can be corrupted.  If you want to verify the trace is not corrupted before providing it to Elastic support, you can open the resulting ETL file in [Windows Performance Analyzer](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-analyzer).  If any errors occur while opening it, then it is corrupted and must be re-captured.

## Process Monitor Trace 
[Process Monitor](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon) also provides the ability to capture profiling data.  ProcMon CPU traces are less-comprehensive and lower fidelity than WPR traces, but include other context such as file, registry, network, image, and process events.

ProcMon CPU traces are not enabled by default.  To enable profiling data capture, Select *Options* -> *Profiling Events*

![image](https://github.com/user-attachments/assets/8d79cab5-a425-4fe8-8016-107b76bfa3c0)

Then check *Generate thread profiling events* and select *Every 100 milliseconds*

![image](https://github.com/user-attachments/assets/25113c84-2ebb-4f0b-8373-fb682489dbe6)

If a trace was already running, start a new one by selecting *Edit* -> *Clear Display*

![image](https://github.com/user-attachments/assets/2155763c-c447-4ea6-9791-b58ff1a46b58)

Now, reproduce the problematic behavior while the trace is running.  When you are done, select *All Events* and PML format in the save dialog.  The resulting PML file should compress well - please zip it.

![image](https://github.com/user-attachments/assets/8ecbc63f-3f09-4175-aa1a-b61a33cfdbd9)

Because Elastic Defend runs as an [Antimalware Protected Process Light](https://learn.microsoft.com/en-us/windows/win32/services/protecting-anti-malware-services-), Procmon cannot fully enrich the CPU trace.  To facilitate analysis by Elastic support, please also capture a memory dump using the following command, zip it, and provide it to Elastic support alongside the PML:
```
"C:\Program Files\ELastic\Endpoint\elastic-endpoint.exe" memorydump
```

This dump will compress well.  Please zip it.  Note you will not be able to navigate to `C:\Program Files\ELastic\Endpoint\cache` in Windows Explorer on most systems, but you should be able to copy out the dump via command line.
