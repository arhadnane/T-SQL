/*
blocking-tree.sql
Builds a blocking tree using a recursive CTE starting from head blockers.
*/

;WITH requests AS (
    SELECT r.session_id, r.blocking_session_id
    FROM sys.dm_exec_requests r
    WHERE r.session_id <> @@SPID
), heads AS (
    SELECT r.session_id, r.blocking_session_id, 0 AS Lvl, CAST(CONVERT(varchar(10), r.session_id) AS varchar(max)) AS Path
    FROM requests r
    WHERE r.blocking_session_id = 0
    UNION ALL
    SELECT r.session_id, r.blocking_session_id, h.Lvl + 1,
           CAST(h.Path + ' > ' + CONVERT(varchar(10), r.session_id) AS varchar(max))
    FROM requests r
    JOIN heads h ON r.blocking_session_id = h.session_id
)
SELECT h.Lvl,
       REPLICATE('  ', h.Lvl) + CONVERT(varchar(10), h.session_id) AS SessionIdIndented,
       h.blocking_session_id,
       s.login_name,
       s.host_name,
       s.status,
       r.wait_type,
       r.wait_time,
       DB_NAME(r.database_id) AS DatabaseName,
       h.Path
FROM heads h
LEFT JOIN sys.dm_exec_requests r ON r.session_id = h.session_id
LEFT JOIN sys.dm_exec_sessions s ON s.session_id = h.session_id
ORDER BY h.Path
OPTION (MAXRECURSION 100);