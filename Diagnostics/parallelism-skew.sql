/*
parallelism-skew.sql
Highlights active parallel requests with basic skew indicators.
Notes: Uses task counts vs. plan DOP; approximate. Live Query Stats offers deeper insight.
*/

;WITH req AS (
    SELECT r.session_id, r.request_id, r.status, r.start_time,
           r.cpu_time, r.total_elapsed_time, r.wait_type, r.scheduler_id,
           r.plan_handle
    FROM sys.dm_exec_requests r
    WHERE r.session_id > 50 -- user sessions
), tasks AS (
    SELECT t.session_id, t.request_id, COUNT(*) AS active_tasks
    FROM sys.dm_os_tasks t
    WHERE t.session_id > 50
    GROUP BY t.session_id, t.request_id
), dop AS (
    SELECT DISTINCT r.session_id, r.request_id,
        TRY_CAST(
            REPLACE(
                TRY_CONVERT(nvarchar(10),
                    (SELECT TOP 1 qp.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; (//QueryPlan/@DegreeOfParallelism)[1]','int'))
                ),'','')
        AS int) AS degree_of_parallelism
    FROM req r
    CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qp
)
SELECT TOP (50)
    r.session_id,
    r.request_id,
    COALESCE(d.degree_of_parallelism, 0) AS DOP,
    COALESCE(t.active_tasks, 0) AS active_tasks,
    CASE WHEN COALESCE(d.degree_of_parallelism, 0) > 0 
         THEN CAST(1.0 * COALESCE(t.active_tasks, 0) / NULLIF(d.degree_of_parallelism, 0) AS decimal(10,2))
         ELSE NULL END AS task_to_dop_ratio,
    r.status, r.wait_type, r.cpu_time, r.total_elapsed_time,
    SUBSTRING(st.text, 1, 4000) AS sql_text
FROM req r
LEFT JOIN tasks t ON t.session_id = r.session_id AND t.request_id = r.request_id
LEFT JOIN dop d ON d.session_id = r.session_id AND d.request_id = r.request_id
CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) st
WHERE COALESCE(d.degree_of_parallelism, 0) > 1
ORDER BY task_to_dop_ratio DESC, r.total_elapsed_time DESC;