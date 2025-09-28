/*
top-memory-consumers.sql
Reports top memory consumers by memory clerks and sessions.
*/

-- Top memory clerks
SELECT TOP (20)
    mc.type, mc.name, 
    SUM(mc.pages_kb) AS pages_kb,
    SUM(mc.virtual_memory_reserved_kb) AS vm_reserved_kb,
    SUM(mc.virtual_memory_committed_kb) AS vm_committed_kb,
    SUM(mc.awe_allocated_kb) AS awe_kb,
    SUM(mc.shared_memory_committed_kb) AS shared_committed_kb
FROM sys.dm_os_memory_clerks AS mc
GROUP BY mc.type, mc.name
ORDER BY pages_kb DESC;

-- Top sessions by memory usage (approx = memory_usage * 8 KB)
SELECT TOP (50)
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    s.memory_usage * 8 AS memory_kb,
    s.cpu_time,
    s.total_elapsed_time
FROM sys.dm_exec_sessions AS s
WHERE s.is_user_process = 1
ORDER BY memory_kb DESC;