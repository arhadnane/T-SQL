/*
adhoc-plan-cache-bloat.sql
Detect ad-hoc plan cache bloat (many single-use plans).
*/

SELECT TOP 50
    cp.cacheobjtype,
    cp.objtype,
    cp.usecounts,
    cp.size_in_bytes/1024 AS size_kb,
    SUBSTRING(t.text, 1, 4000) AS sql_text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) t
WHERE cp.objtype IN ('Adhoc','Prepared')
ORDER BY cp.usecounts ASC, cp.size_in_bytes DESC;