/*
02-partitioned-orders-table.sql
Purpose: Create partitioned Orders table for demonstration
Benefits: Fast queries by date, efficient data archiving
*/

USE SSUSToolkit;
GO

-- ====== Create partitioned Orders table ======
IF OBJECT_ID('dbo.OrdersPartitioned') IS NULL
BEGIN
    CREATE TABLE dbo.OrdersPartitioned (
        OrderID     bigint IDENTITY(1,1),
        CustomerID  int NOT NULL,
        OrderDate   datetime2(0) NOT NULL,
        Status      nvarchar(30) NOT NULL DEFAULT N'Pending',
        TotalAmount decimal(18,2) NOT NULL,
        CONSTRAINT PK_OrdersPartitioned PRIMARY KEY CLUSTERED (OrderDate, OrderID)
        ON PS_Monthly(OrderDate)  -- Partitioned by OrderDate
    ) ON PS_Monthly(OrderDate);
    
    PRINT 'Table OrdersPartitioned created with monthly partitioning.';
END
ELSE
BEGIN
    PRINT 'Table OrdersPartitioned already exists.';
END
GO

-- ====== Helper: View partition statistics ======
SELECT 
    OBJECT_SCHEMA_NAME(p.object_id) + '.' + OBJECT_NAME(p.object_id) AS TableName,
    p.partition_number AS PartitionNumber,
    prv.value AS BoundaryValue,
    p.rows AS RowCount,
    a.total_pages * 8 / 1024 AS SizeMB,
    ds.name AS Filegroup
FROM sys.partitions p
JOIN sys.indexes ix ON ix.object_id = p.object_id AND ix.index_id = p.index_id
JOIN sys.partition_schemes ps ON ps.data_space_id = ix.data_space_id
JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
LEFT JOIN sys.partition_range_values prv 
    ON prv.function_id = pf.function_id 
    AND prv.boundary_id = p.partition_number
LEFT JOIN sys.allocation_units a ON a.container_id = p.hobt_id
LEFT JOIN sys.data_spaces ds ON ds.data_space_id = a.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'OrdersPartitioned'
    AND p.index_id IN (0, 1)
ORDER BY p.partition_number;
GO

-- ====== Sample query leveraging partition elimination ======
/*
-- This query will only scan relevant partitions:
SELECT * FROM dbo.OrdersPartitioned
WHERE OrderDate >= '2025-01-01' AND OrderDate < '2025-02-01';

-- Check partition elimination:
SET STATISTICS IO ON;
-- Look for "Number of partitions accessed" in execution plan
*/

PRINT 'Partitioned table ready. Query by date range for partition elimination.';
