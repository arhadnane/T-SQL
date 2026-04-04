-- ======================================================================================
-- Name: sp_CheckServerHealth
-- Description: Master health check procedure.
-- Returns a JSON report of the server's current state.
-- ======================================================================================

CREATE OR ALTER PROCEDURE dbo.sp_CheckServerHealth
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Report TABLE (
        Metric VARCHAR(100),
        Value VARCHAR(MAX),
        Status VARCHAR(20)
    );

    -- CPU Check
    INSERT INTO @Report
    SELECT 'CPU_Load', CAST(avg_cpu_percent AS VARCHAR), 
           CASE WHEN avg_cpu_percent > 80 THEN 'WARNING' ELSE 'OK' END
    FROM (SELECT 0 AS avg_cpu_percent) AS t; -- Placeholder for actual logic in vw_ServerHealth

    -- Memory Check
    INSERT INTO @Report
    SELECT 'Memory_Usage', CAST(memory_utilization_pct AS VARCHAR) + '%', 
           CASE WHEN memory_utilization_pct > 90 THEN 'WARNING' ELSE 'OK' END
    FROM (SELECT 70.0 AS memory_utilization_pct) AS t; -- Placeholder

    -- Blocking Check
    INSERT INTO @Report
    SELECT 'Blocking_Sessions', CAST(blocking_count AS VARCHAR), 
           CASE WHEN blocking_count > 0 THEN 'CRITICAL' ELSE 'OK' END
    FROM (SELECT 0 AS blocking_count) AS t; -- Placeholder

    SELECT 
        (SELECT * FROM @Report FOR JSON PATH) AS HealthReport;
END;
GO
