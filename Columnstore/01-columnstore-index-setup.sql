/*
01-columnstore-index-setup.sql
Purpose: Create clustered columnstore index for analytical workloads
Use case: Data warehousing, large aggregations, reporting
*/

USE SSUSToolkit;
GO

-- ====== Create columnstore-optimized table ======
IF OBJECT_ID('dbo.FactOrders') IS NULL
BEGIN
    CREATE TABLE dbo.FactOrders (
        OrderID         bigint NOT NULL,
        CustomerID      int NOT NULL,
        ProductID       int NOT NULL,
        OrderDateKey    int NOT NULL,  -- YYYYMMDD format
        Quantity        int NOT NULL,
        UnitPrice       decimal(18,2) NOT NULL,
        LineTotal       decimal(18,2) NOT NULL,
        DiscountPct     decimal(5,2) NULL
    );
    
    -- Create clustered columnstore index
    CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactOrders 
    ON dbo.FactOrders;
    
    PRINT 'Table FactOrders created with clustered columnstore index.';
END
ELSE
BEGIN
    PRINT 'Table FactOrders already exists.';
END
GO

-- ====== Alternative: Nonclustered columnstore on rowstore table ======
/*
-- If you want to keep rowstore for OLTP but add columnstore for reporting:
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders_Analytics
ON dbo.Orders (CustomerID, OrderDate, Status, TotalAmount)
WHERE Status = 'Completed';  -- Optional: filtered columnstore
*/

-- ====== Load sample data (bulk insert pattern) ======
/*
-- For best performance with columnstore, insert in batches >= 100K rows
-- or use bulk insert operations

INSERT INTO dbo.FactOrders WITH (TABLOCK)
SELECT 
    o.OrderID,
    o.CustomerID,
    oi.ProductID,
    CONVERT(int, FORMAT(o.OrderDate, 'yyyyMMdd')) AS OrderDateKey,
    oi.Quantity,
    oi.UnitPrice,
    oi.LineTotal,
    0.00 AS DiscountPct
FROM dbo.Orders o
JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID;
*/

-- ====== Columnstore health check ======
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    partition_number,
    row_group_id,
    state_desc AS RowgroupState,
    total_rows,
    size_in_bytes / 1024 / 1024 AS SizeMB
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE OBJECT_NAME(object_id) = 'FactOrders'
ORDER BY row_group_id;
GO

-- ====== Rebuild if fragmentation detected ======
/*
-- If you see many OPEN/CLOSED rowgroups with small row counts:
ALTER INDEX CCI_FactOrders ON dbo.FactOrders REBUILD;

-- Or reorganize (lighter):
ALTER INDEX CCI_FactOrders ON dbo.FactOrders REORGANIZE;
*/

PRINT 'Columnstore index ready. Optimize with bulk inserts and periodic rebuilds.';
