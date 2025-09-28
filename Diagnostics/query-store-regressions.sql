/*
query-store-regressions.sql
Requires Query Store enabled. Finds queries with worse recent performance vs. previous interval.
*/

IF EXISTS (SELECT 1 FROM sys.database_query_store_options WHERE actual_state_desc = 'READ_WRITE')
BEGIN
    ;WITH recent AS (
        SELECT rs.query_id,
               SUM(rs.avg_duration) AS dur,
               SUM(rs.count_executions) AS execs
        FROM sys.query_store_runtime_stats rs
        JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
        WHERE rsi.end_time > DATEADD(hour, -24, SYSUTCDATETIME())
        GROUP BY rs.query_id
    ), prev AS (
        SELECT rs.query_id,
               SUM(rs.avg_duration) AS dur,
               SUM(rs.count_executions) AS execs
        FROM sys.query_store_runtime_stats rs
        JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
        WHERE rsi.end_time BETWEEN DATEADD(hour, -48, SYSUTCDATETIME()) AND DATEADD(hour, -24, SYSUTCDATETIME())
        GROUP BY rs.query_id
    )
    SELECT TOP 50
        qsq.object_id,
        OBJECT_SCHEMA_NAME(qsq.object_id) AS SchemaName,
        OBJECT_NAME(qsq.object_id) AS ObjectName,
        qsq.query_sql_text,
        recent.dur/recent.execs AS recent_avg_duration,
        prev.dur/prev.execs AS prev_avg_duration,
        (recent.dur/recent.execs) - (prev.dur/prev.execs) AS delta
    FROM recent
    JOIN prev ON prev.query_id = recent.query_id
    JOIN sys.query_store_query qsq ON qsq.query_id = recent.query_id
    WHERE recent.execs >= 5 AND prev.execs >= 5
    ORDER BY delta DESC;
END
ELSE
BEGIN
    SELECT 'Query Store is not enabled (READ_WRITE). Enable it to use this report.' AS Info;
END;