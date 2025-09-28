/*
active-requests.sql
Shows active requests, waits, blocking session, and the current statement text.
Tip: Set @DatabaseName to filter to one DB, or leave NULL for all.
*/

DECLARE @DatabaseName sysname = NULL; -- e.g., N'SSUSToolkit'

SELECT 
    r.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(r.database_id) AS DatabaseName,
    r.status,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time,
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
  AND (@DatabaseName IS NULL OR DB_NAME(r.database_id) = @DatabaseName)
ORDER BY r.blocking_session_id DESC, r.session_id;