# Collecting Windows CPU Traces

When reporting a CPU usage issue to Elastic support, it can be very helpful to provide a CPU profiling trace.  This allows Elastic Support to precisely identify which portions of Defend's code are using CPU during the capture.

> [!IMPORTANT]  
> It is important to only capture traces while the problematic behavior is occurring.  A trace captured on an idle system isn't useful.

## Windows Performance Recorder (WPR) Trace

Windows Performance Recorder is a Windows feature which leverages built-in kernel features to capture detailed low-level CPU usage information.

To capture a WPR trace, run this command then provide the resulting `Defend-CPU.etl` to Elastic Support:
```
powershell.exe -noprofile -command "&wpr.exe -start CPU -filemode; Start-Sleep 60; &wpr.exe -stop Defend-CPU.etl -compress -skipPdbGen; &wpr.exe -stop Defend-CPU.etl"
```


> [!WARNING]
> Due to the volume of data captured, CPU profiling is a very resource-intensive operation.  It requires significant CPU and disk I/O to capture and record the data as it is generated.  If either CPU or I/O cannot keep up, the resulting trace can be corrupted.  If you want to verify the trace is not corrupted before providing it to Elastic Support, you can open the resulting ETL file in [Windows Performance Analyzer](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-analyzer).  If any errors occur while opening it, then it is corrupted and must be re-captured.

## Process Monitor Trace 
[Process Monitor](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon) also provides the ability to capture profiling data.  ProcMon CPU traces are less-comprehensive and lower fidelity than WPR traces, but include other context such as file, registry, network, image, and process events.

### Enabling CPU Tracing

ProcMon does not capture CPU traces by default.  When enabled, its GUI allows a maximum of 10 samples/second.  This resolution isn't isn't useful for diagnosing some types of CPU issues.  To capture higher-fidelity (20 samples/second) traces, set the following **before launching ProcMon**:
```
reg.exe add "HKCU\Software\SysInternals\Process Monitor" /f /v Profiling /t REG_DWORD /d 20
```

If the system becomes unusable during high-fidelity CPU profiling, then either use this command or follow the GUI instructions below to enable 10 samples/second tracing.

```
reg.exe add "HKCU\Software\SysInternals\Process Monitor" /f /v Profiling /t REG_DWORD /d 10
```

<details>
  
<summary>Configure Low-Fidelity CPU Profiling via GUI</summary>

To enable profiling 10 samples/sec data capture, Select **Options** -> **Profiling Events**

![image](https://github.com/user-attachments/assets/8d79cab5-a425-4fe8-8016-107b76bfa3c0)

Then check **Generate thread profiling events** and select **Every 100 milliseconds**

![image](https://github.com/user-attachments/assets/25113c84-2ebb-4f0b-8373-fb682489dbe6)

If a trace was already running, start a new one by selecting **Edit** -> **Clear Display**

![image](https://github.com/user-attachments/assets/2155763c-c447-4ea6-9791-b58ff1a46b58)

</details>

### Capturing the Trace

Now, reproduce the problematic behavior while the trace is running.  When you are done, select **All Events** and PML format in the save dialog.  The resulting PML file should compress well - please zip it.

![image](https://github.com/user-attachments/assets/8ecbc63f-3f09-4175-aa1a-b61a33cfdbd9)

Because Elastic Defend runs as an [Antimalware Protected Process Light](https://learn.microsoft.com/en-us/windows/win32/services/protecting-anti-malware-services-), Procmon cannot fully enrich the CPU trace.  To facilitate analysis by Elastic Support, please also capture a memory dump using the following command:
```
"C:\Program Files\ELastic\Endpoint\elastic-endpoint.exe" memorydump
```

 The resulting DMP file will compress well.  Please zip it.  Note you will not be able to navigate to `C:\Program Files\ELastic\Endpoint` in Windows Explorer on most systems, but you should be able to copy out the DMP file via command line.
