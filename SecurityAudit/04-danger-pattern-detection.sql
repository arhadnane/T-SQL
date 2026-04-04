-- ======================================================================================
-- Name: 04-danger-pattern-detection.sql
-- Description: Scans the plan cache for dangerous SQL patterns (potential injections or bad practices).
-- ======================================================================================

SET NOCOUNT ON;

PRINT '--- [1] POTENTIAL SQL INJECTION PATTERNS ---';
SELECT 
    st.text AS QueryText, 
    cp.use_counts, 
    cp.objtype
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.text LIKE '%EXEC(%' 
   OR st.text LIKE '%sp_executesql%' 
   OR st.text LIKE '%DROP TABLE%' 
   OR st.text LIKE '%TRUNCATE TABLE%';

PRINT '--- [2] CROSS-DATABASE QUERIES (Potential Leakage) ---';
SELECT 
    st.text AS QueryText
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.text LIKE '%.%.%' AND st.text NOT LIKE '%sys.%';
GO
