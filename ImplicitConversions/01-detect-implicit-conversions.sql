/*
01-detect-implicit-conversions.sql
Purpose: Identify queries causing implicit conversions (performance killers)
Source: Query Store execution plans
Impact: Implicit conversions prevent index usage, cause full scans
*/

USE SSUSToolkit;
GO

-- ====== Check if Query Store is enabled ======
IF EXISTS (SELECT 1 FROM sys.database_query_store_options WHERE actual_state_desc = 'READ_WRITE')
BEGIN
    ;WITH ImplicitConversionQueries AS (
        SELECT 
            qsq.query_id,
            qsq.query_hash,
            qsq.query_sql_text,
            qsrs.avg_duration,
            qsrs.count_executions,
            -- Look for Convert operators in plan XML
            qp.query_plan,
            CASE 
                WHEN qp.query_plan LIKE '%\u003cConvert%Implicit%\u003e%' 
                     OR qp.query_plan LIKE '%CONVERT_IMPLICIT%'
                THEN 1 ELSE 0 
            END AS HasImplicitConversion
        FROM sys.query_store_query qsq
        JOIN sys.query_store_plan qp ON qp.query_id = qsq.query_id
        JOIN sys.query_store_runtime_stats qsrs 
            ON qsrs.plan_id = qp.plan_id
        WHERE qp.query_plan IS NOT NULL
    )
    SELECT TOP 20
        query_id,
        query_hash,
        LEFT(query_sql_text, 200) AS QueryPreview,
        avg_duration AS AvgDurationMicroseconds,
        count_executions AS ExecutionCount,
        CASE WHEN HasImplicitConversion = 1 
             THEN 'YES - Fix data type mismatch!' 
             ELSE 'No implicit conversion found' 
        END AS ImplicitConversionDetected
    FROM ImplicitConversionQueries
    WHERE HasImplicitConversion = 1
    ORDER BY avg_duration * count_executions DESC;
END
ELSE
BEGIN
    SELECT 'Query Store is not enabled. Enable it to detect implicit conversions.' AS Info;
END
GO

-- ====== Alternative: DMVs for currently cached plans ======
SELECT 
    st.text AS QueryText,
    qs.execution_count,
    qs.total_elapsed_time / 1000 AS TotalElapsedTime_ms,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qp.query_plan LIKE '%CONVERT_IMPLICIT%'
   OR qp.query_plan LIKE '%\u003cConvert%Implicit%\u003e%'
ORDER BY qs.total_elapsed_time DESC;
GO

-- ====== Common implicit conversion patterns ======
/*
-- NVARCHAR column compared with VARCHAR literal:
WHERE NVARCHAR_Column = 'string'  -- BAD: Implicit conversion
WHERE NVARCHAR_Column = N'string' -- GOOD: Unicode literal

-- INT column compared with BIGINT:
WHERE INT_Column = 123456789012  -- BAD: BIGINT literal on INT column
WHERE INT_Column = 123456        -- GOOD: Within INT range

-- DATE compared with string:
WHERE Date_Column = '2024-01-01' -- BAD: String literal
WHERE Date_Column = '20240101' -- GOOD: ANSI date format (no conversion)
WHERE Date_Column = CAST('2024-01-01' AS DATE) -- GOOD: Explicit cast

-- VARCHAR compared with NVARCHAR parameter:
DECLARE @Param NVARCHAR(50) = N'value';
WHERE VARCHAR_Column = @Param -- BAD: Implicit conversion to NVARCHAR
-- Fix: DECLARE @Param VARCHAR(50) = 'value';
*/

PRINT 'Review queries with implicit conversions. Fix data type mismatches to enable index seeks.';
