/*
02-inmemory-vs-disk-comparison.sql
Purpose: Compare performance between memory-optimized and disk-based tables
*/

USE SSUSToolkit;
GO

-- ====== Setup: Populate tables for comparison ======
SET NOCOUNT ON;

DECLARE @i int = 1;
DECLARE @start datetime2;
DECLARE @end datetime2;

-- Ensure we have data
IF (SELECT COUNT(*) FROM dbo.Orders) < 1000
BEGIN
    PRINT 'Populating Orders table with sample data...';
    WHILE @i <= 1000
    BEGIN
        INSERT INTO dbo.Orders (CustomerID, Status)
        VALUES (@i % 100 + 1, CASE WHEN @i % 2 = 0 THEN N'Pending' ELSE N'Completed' END);
        SET @i = @i + 1;
    END
END

IF (SELECT COUNT(*) FROM dbo.OrdersInMemory) < 1000
BEGIN
    PRINT 'Populating OrdersInMemory table with sample data...';
    SET @i = 1;
    WHILE @i <= 1000
    BEGIN
        INSERT INTO dbo.OrdersInMemory (CustomerID, Status, TotalAmount)
        VALUES (@i % 100 + 1, CASE WHEN @i % 2 = 0 THEN N'Pending' ELSE N'Completed' END, @i * 10.00);
        SET @i = @i + 1;
    END
END
GO

-- ====== Comparison: INSERT performance ======
DECLARE @start datetime2 = SYSUTCDATETIME();
DECLARE @i int = 1;

-- Disk-based insert
WHILE @i <= 1000
BEGIN
    INSERT INTO dbo.Orders (CustomerID, Status) VALUES (@i % 100 + 1, N'Test');
    SET @i = @i + 1;
END

DECLARE @diskInsertTime int = DATEDIFF(MILLISECOND, @start, SYSUTCDATETIME());

-- Memory-optimized insert
SET @start = SYSUTCDATETIME();
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dbo.OrdersInMemory (CustomerID, Status, TotalAmount) 
    VALUES (@i % 100 + 1, N'Test', @i * 10.00);
    SET @i = @i + 1;
END

DECLARE @memInsertTime int = DATEDIFF(MILLISECOND, @start, SYSUTCDATETIME());

-- ====== Results ======
SELECT 
    'INSERT 1000 rows' AS Test,
    @diskInsertTime AS DiskBased_ms,
    @memInsertTime AS InMemory_ms,
    CAST(@diskInsertTime * 1.0 / NULLIF(@memInsertTime, 0) AS decimal(10,2)) AS SpeedupFactor;
GO

-- ====== Comparison: SELECT performance ======
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '--- Disk-based table ---';
SELECT COUNT(*) FROM dbo.Orders WHERE Status = N'Pending';

PRINT '--- Memory-optimized table ---';
SELECT COUNT(*) FROM dbo.OrdersInMemory WHERE Status = N'Pending';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- ====== Memory report ======
SELECT 
    'Memory Usage' AS Report,
    SUM(CASE WHEN t.is_memory_optimized = 1 THEN ms.memory_used_by_table_kb ELSE 0 END) / 1024.0 AS InMemoryTablesMB,
    SUM(CASE WHEN t.is_memory_optimized = 1 THEN ms.memory_used_by_indexes_kb ELSE 0 END) / 1024.0 AS InMemoryIndexesMB
FROM sys.dm_db_xtp_table_memory_stats ms
JOIN sys.tables t ON t.object_id = ms.object_id;
GO

PRINT 'Comparison complete. Memory-optimized tables typically show 5x-30x speedup for OLTP workloads.';
