/*
03-switch-partition-out.sql
Purpose: Switch out old partitions for archiving (sliding window scenario)
Use case: Archive data older than 13 months while keeping recent data
*/

USE SSUSToolkit;
GO

-- ====== Parameters ======
DECLARE @PartitionToArchive int = 1;  -- Oldest partition to archive
DECLARE @ArchiveTableName nvarchar(128) = N'dbo.OrdersArchive_2024_01';

-- ====== Create staging table matching partitioned table structure ======
IF OBJECT_ID(@ArchiveTableName) IS NULL
BEGIN
    DECLARE @sql nvarchar(max) = N'
    CREATE TABLE ' + @ArchiveTableName + N' (
        OrderID     bigint NOT NULL,
        CustomerID  int NOT NULL,
        OrderDate   datetime2(0) NOT NULL,
        Status      nvarchar(30) NOT NULL,
        TotalAmount decimal(18,2) NOT NULL,
        CONSTRAINT PK_' + REPLACE(REPLACE(@ArchiveTableName, 'dbo.', ''), '.', '_') + N' PRIMARY KEY CLUSTERED (OrderDate, OrderID)
    ) ON [PRIMARY];';
    
    EXEC sp_executesql @sql;
    PRINT 'Archive table ' + @ArchiveTableName + ' created.';
END
GO

-- ====== Switch partition out ======
/*
-- Pre-check: Ensure partition is empty of active data or move data first
-- This is a metadata-only operation (fast!)

ALTER TABLE dbo.OrdersPartitioned
SWITCH PARTITION @PartitionToArchive
TO dbo.OrdersArchive_2024_01;

-- After switch:
-- 1. Verify data in archive table
-- 2. TRUNCATE or DROP archive table after backup
-- 3. MERGE RANGE to remove old boundary from partition function
*/

-- ====== Helper: Identify partition to archive ======
SELECT 
    p.partition_number,
    prv.value AS BoundaryValue,
    p.rows AS RowCount,
    CASE 
        WHEN p.rows = 0 THEN 'Empty - Safe to archive'
        WHEN p.rows > 0 AND prv.value < DATEADD(month, -13, GETDATE()) 
        THEN 'Old data - Consider archiving'
        ELSE 'Recent data - Keep'
    END AS Recommendation
FROM sys.partitions p
JOIN sys.partition_schemes ps ON p.partition_id = ps.data_space_id
JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
LEFT JOIN sys.partition_range_values prv 
    ON prv.function_id = pf.function_id AND prv.boundary_id = p.partition_number
WHERE OBJECT_NAME(p.object_id) = 'OrdersPartitioned'
    AND p.index_id IN (0, 1)
ORDER BY p.partition_number;
GO

PRINT 'Review partition statistics before archiving. Switch partition is metadata-only operation.';
