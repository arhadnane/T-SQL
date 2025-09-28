/*
latch-hotspots.sql
Identify latch hotspots from server-level latch and wait statistics.
*/

-- Latch stats
SELECT TOP (50)
    latch_class,
    waiting_requests_count,
    wait_time_ms,
    wait_time_ms / NULLIF(waiting_requests_count,0) AS avg_wait_ms
FROM sys.dm_os_latch_stats
ORDER BY wait_time_ms DESC;

-- Page latch waits (memory vs I/O)
SELECT TOP (50)
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    100.0 * wait_time_ms / NULLIF(SUM(wait_time_ms) OVER(), 0) AS pct_total_wait_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH_%' OR wait_type LIKE 'PAGEIOLATCH_%'
ORDER BY wait_time_ms DESC;