/*
long-running-queries.sql
Lists requests running longer than @MinSeconds with current statement and wait info.
*/

DECLARE @MinSeconds int = 30;

SELECT 
    r.session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.wait_type,
    r.cpu_time,
    r.total_elapsed_time/1000 AS elapsed_s,
    DB_NAME(r.database_id) AS DatabaseName,
    SUBSTRING(st.text,
        CASE WHEN r.statement_start_offset >= 0 THEN (r.statement_start_offset/2) + 1 ELSE 1 END,
        CASE WHEN r.statement_end_offset = -1 OR r.statement_end_offset < r.statement_start_offset
             THEN (LEN(CONVERT(nvarchar(max), st.text)) - (r.statement_start_offset/2)) + 1
             ELSE (r.statement_end_offset - r.statement_start_offset)/2 + 1 END) AS CurrentStatement,
    st.text AS BatchText
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id <> @@SPID
  AND r.total_elapsed_time/1000 >= @MinSeconds
ORDER BY r.total_elapsed_time DESC;