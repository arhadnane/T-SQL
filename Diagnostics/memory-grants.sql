/*
memory-grants.sql
Current and pending memory grants.
*/

SELECT 
    mg.session_id,
    s.login_name,
    DB_NAME(s.database_id) AS DatabaseName,
    mg.requested_memory_kb,
    mg.granted_memory_kb,
    mg.used_memory_kb,
    mg.is_next_candidate,
    mg.wait_time_ms,
    mg.queue_id,
    text = SUBSTRING(t.text, 1, 4000)
FROM sys.dm_exec_query_memory_grants mg
JOIN sys.dm_exec_sessions s ON s.session_id = mg.session_id
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) t
ORDER BY mg.requested_memory_kb DESC;