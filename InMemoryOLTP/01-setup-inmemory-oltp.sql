/*
01-setup-inmemory-oltp.sql
Purpose: Enable In-Memory OLTP and create memory-optimized objects
Use case: High-throughput OLTP, low-latency transactions
Requirements: SQL Server 2016+ (Express edition limited)
*/

USE SSUSToolkit;
GO

-- ====== Check if In-Memory OLTP is supported ======
SELECT 
    SERVERPROPERTY('Edition') AS ServerEdition,
    SERVERPROPERTY('ProductVersion') AS Version,
    CASE 
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS varchar(20)) >= '13.0' THEN 'Supported'
        ELSE 'Not supported - Requires SQL Server 2016+'
    END AS InMemorySupport;
GO

-- ====== Add memory-optimized filegroup ======
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE type = 'FX')
BEGIN
    DECLARE @DataPath nvarchar(260) = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(260));

    ALTER DATABASE SSUSToolkit 
    ADD FILEGROUP MemoryOptimizedFG CONTAINS MEMORY_OPTIMIZED_DATA;
    
    EXEC(N'ALTER DATABASE SSUSToolkit ADD FILE (NAME = N''MemoryOptimizedData'', FILENAME = N''' 
         + @DataPath + N'SSUSToolkit_MemoryOptimized'') TO FILEGROUP MemoryOptimizedFG;');
    
    PRINT 'Memory-optimized filegroup added.';
END
ELSE
BEGIN
    PRINT 'Memory-optimized filegroup already exists.';
END
GO

-- ====== Create memory-optimized table ======
IF OBJECT_ID('dbo.OrdersInMemory') IS NULL
BEGIN
    CREATE TABLE dbo.OrdersInMemory (
        OrderID         int IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
        CustomerID      int NOT NULL,
        OrderDate       datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        Status          nvarchar(30) NOT NULL DEFAULT N'Pending',
        TotalAmount     decimal(18,2) NOT NULL,
        
        INDEX IX_CustomerID NONCLUSTERED (CustomerID)
    ) WITH (
        MEMORY_OPTIMIZED = ON,
        DURABILITY = SCHEMA_AND_DATA
    );
    
    PRINT 'Memory-optimized table OrdersInMemory created.';
END
ELSE
BEGIN
    PRINT 'Memory-optimized table already exists.';
END
GO

-- ====== Create natively compiled stored procedure ======
IF OBJECT_ID('dbo.usp_InsertOrderInMemory') IS NOT NULL
    DROP PROCEDURE dbo.usp_InsertOrderInMemory;
GO

CREATE PROCEDURE dbo.usp_InsertOrderInMemory
    @CustomerID int,
    @Status nvarchar(30),
    @TotalAmount decimal(18,2)
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'English'
)
    INSERT INTO dbo.OrdersInMemory (CustomerID, Status, TotalAmount)
    VALUES (@CustomerID, @Status, @TotalAmount);
    
    SELECT SCOPE_IDENTITY() AS NewOrderID;
END
GO

PRINT 'Natively compiled stored procedure usp_InsertOrderInMemory created.';
GO

-- ====== Memory usage report ======
SELECT 
    t.name AS TableName,
    ISNULL(t.type_desc, 'memory_optimized') AS TableType,
    ms.memory_used_by_indexes_kb / 1024.0 AS IndexMemoryMB,
    ms.memory_used_by_table_kb / 1024.0 AS TableMemoryMB
FROM sys.dm_db_xtp_table_memory_stats ms
JOIN sys.tables t ON t.object_id = ms.object_id
WHERE t.is_memory_optimized = 1
ORDER BY ms.memory_used_by_table_kb DESC;
GO

PRINT 'In-Memory OLTP infrastructure ready. Tables are stored in memory with durability to disk.';
