/*
wait-stats.sql
Aggregated wait statistics excluding common benign waits. Use for server-level bottleneck insight.
*/

;WITH ws AS (
    SELECT
        wait_type,
        wait_time_ms,
        signal_wait_time_ms,
        waiting_tasks_count
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT LIKE 'SLEEP%'
      AND wait_type NOT LIKE 'BROKER_%'
      AND wait_type NOT IN (
        'LAZYWRITER_SLEEP','RESOURCE_QUEUE','SQLTRACE_BUFFER_FLUSH','XE_TIMER_EVENT','XE_DISPATCHER_WAIT',
        'REQUEST_FOR_DEADLOCK_SEARCH','CLR_AUTO_EVENT','CLR_MANUAL_EVENT','BROKER_TASK_STOP','BROKER_TO_FLUSH'
      )
)
SELECT TOP 50
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms,
    (wait_time_ms - signal_wait_time_ms) AS resource_wait_ms
FROM ws
ORDER BY wait_time_ms DESC;