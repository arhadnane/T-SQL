/*
top-cpu-queries.sql
Top queries by total CPU time (worker time) from the plan cache.
*/

SELECT TOP 50
    DB_NAME(st.dbid) AS DatabaseName,
    qs.total_worker_time/1000.0 AS total_cpu_ms,
    qs.total_worker_time/NULLIF(qs.execution_count,0)/1000.0 AS avg_cpu_ms,
    qs.execution_count,
    qs.total_elapsed_time/1000.0 AS total_elapsed_ms,
    qs.total_elapsed_time/NULLIF(qs.execution_count,0)/1000.0 AS avg_elapsed_ms,
    qs.max_elapsed_time/1000.0 AS max_elapsed_ms,
    qs.last_execution_time,
    SUBSTRING(st.text, 1, 4000) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;