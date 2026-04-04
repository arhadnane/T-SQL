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
    FROM (
        SELECT TOP 1
            ring.record.value('(/Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS avg_cpu_percent
        FROM (
            SELECT CAST(record AS xml) AS record
            FROM sys.dm_os_ring_buffers
            WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
        ) AS ring
        ORDER BY ring.record.value('(/Record/@id)[1]', 'bigint') DESC
    ) AS t;

    -- Memory Check
    INSERT INTO @Report
    SELECT 'Memory_Usage', CAST(memory_utilization_pct AS VARCHAR) + '%', 
           CASE WHEN memory_utilization_pct > 90 THEN 'WARNING' ELSE 'OK' END
    FROM (
        SELECT 100.0 * (1.0 - (CAST(available_physical_memory_kb AS float) / total_physical_memory_kb)) AS memory_utilization_pct
        FROM sys.dm_os_sys_memory
    ) AS t;

    -- Blocking Check
    INSERT INTO @Report
    SELECT 'Blocking_Sessions', CAST(blocking_count AS VARCHAR), 
           CASE WHEN blocking_count > 0 THEN 'CRITICAL' ELSE 'OK' END
    FROM (SELECT COUNT(*) AS blocking_count FROM sys.dm_exec_requests WHERE blocking_session_id <> 0) AS t;

    SELECT 
        (SELECT * FROM @Report FOR JSON PATH) AS HealthReport;
END;
GO
