-- ======================================================================================
-- Name: vw_ServerHealth
-- Description: Unified health view for SQL Server. 
-- Combines CPU, Memory, Disk, and Blocking indicators into a single status card.
-- ======================================================================================

CREATE OR ALTER VIEW dbo.vw_ServerHealth
AS
WITH CPU_Stats AS (
    SELECT TOP 1
        ring.record.value('(/Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS avg_cpu_percent
    FROM (
        SELECT CAST(record AS xml) AS record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
    ) AS ring
    ORDER BY ring.record.value('(/Record/@id)[1]', 'bigint') DESC
),
Memory_Stats AS (
    SELECT 
        total_physical_memory_kb = total_physical_memory_kb,
        available_physical_memory_kb = available_physical_memory_kb,
        memory_utilization_pct = 100.0 * (1.0 - (CAST(available_physical_memory_kb AS float) / total_physical_memory_kb))
    FROM sys.dm_os_sys_memory
),
Blocking_Stats AS (
    SELECT 
        blocking_count = COUNT(*) 
    FROM sys.dm_exec_requests 
    WHERE blocking_session_id <> 0
),
Backup_Stats AS (
    SELECT 
        last_backup_date = MAX(backup_finish_date) 
    FROM msdb.dbo.backupset
)
SELECT 
    GETDATE() AS CheckTime,
    ISNULL(CAST(CPU_Stats.avg_cpu_percent AS VARCHAR), 'N/A') AS CPU_Load,
    CAST(Memory_Stats.memory_utilization_pct AS DECIMAL(5,2)) AS Mem_Utilization_Pct,
    Blocking_Stats.blocking_count AS Active_Blocks,
    Backup_Stats.last_backup_date AS Last_Full_Backup,
    CASE 
        WHEN Blocking_Stats.blocking_count > 0 THEN 'CRITICAL'
        WHEN Memory_Stats.memory_utilization_pct > 90 THEN 'WARNING'
        ELSE 'HEALTHY' 
    END AS Overall_Status
FROM CPU_Stats, Memory_Stats, Blocking_Stats, Backup_Stats;
GO
