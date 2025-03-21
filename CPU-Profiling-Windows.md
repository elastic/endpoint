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
Process Monitor also provides the ability to capture profiling data, but it is not enabled by default.  To enable profiling data capture, Select *Options* -> *Profiling Events*

Then check *Generate thread profiling events* and select *Every 100 milliseconds*

