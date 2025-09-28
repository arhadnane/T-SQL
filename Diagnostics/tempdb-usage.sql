/*
tempdb-usage.sql
Shows session and task tempdb allocations and deallocations in MB.
*/

;WITH s AS (
    SELECT
        session_id,
        user_objects_alloc_page_count + internal_objects_alloc_page_count AS alloc_pages,
        user_objects_dealloc_page_count + internal_objects_dealloc_page_count AS dealloc_pages
    FROM sys.dm_db_session_space_usage
), t AS (
    SELECT
        session_id,
        SUM(user_objects_alloc_page_count + internal_objects_alloc_page_count) AS task_alloc_pages,
        SUM(user_objects_dealloc_page_count + internal_objects_dealloc_page_count) AS task_dealloc_pages
    FROM sys.dm_db_task_space_usage
    GROUP BY session_id
)
SELECT 
    s.session_id,
    se.login_name,
    se.host_name,
    (s.alloc_pages - s.dealloc_pages) * 8.0 / 1024 AS session_tempdb_mb,
    (t.task_alloc_pages - t.task_dealloc_pages) * 8.0 / 1024 AS task_tempdb_mb
FROM s
LEFT JOIN t ON t.session_id = s.session_id
LEFT JOIN sys.dm_exec_sessions se ON se.session_id = s.session_id
WHERE s.session_id <> @@SPID
ORDER BY session_tempdb_mb DESC;