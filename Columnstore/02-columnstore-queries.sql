/*
02-columnstore-queries.sql
Purpose: Demonstrate columnstore-optimized queries
*/

USE SSUSToolkit;
GO

-- ====== Aggregation query (columnstore excels at this) ======
/*
-- This query benefits from batch mode execution on columnstore:
SELECT 
    OrderDateKey,
    COUNT(*) AS OrderCount,
    SUM(LineTotal) AS TotalRevenue,
    AVG(UnitPrice) AS AvgPrice,
    MAX(Quantity) AS MaxQuantity
FROM dbo.FactOrders
WHERE OrderDateKey BETWEEN 20240101 AND 20241231
GROUP BY OrderDateKey
ORDER BY OrderDateKey;
*/

-- ====== Check for batch mode execution ======
/*
-- Include actual execution plan (Ctrl+M in SSMS)
-- Look for "Columnstore Index Scan" and "Batch Mode" operators
-- Row mode = one row at a time (slower)
-- Batch mode = thousands of rows at once (faster)
*/

-- ====== Compare rowstore vs columnstore performance ======
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Rowstore table (disk-based)
PRINT '-- Rowstore query --';
SELECT 
    YEAR(o.OrderDate) AS Year,
    COUNT(*) AS Orders,
    SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM dbo.Orders o
JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY YEAR(o.OrderDate);

-- Columnstore table
PRINT '-- Columnstore query --';
SELECT 
    OrderDateKey / 10000 AS Year,
    COUNT(*) AS Orders,
    SUM(LineTotal) AS Revenue
FROM dbo.FactOrders
GROUP BY OrderDateKey / 10000;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- ====== Memory grant optimization ======
/*
-- Columnstore queries may need large memory grants
-- Check for spills to tempdb:
SELECT 
    query_plan_hash,
    query_hash,
    avg_query_max_used_memory,
    avg_dop,
    last_dop
FROM sys.dm_exec_query_stats
WHERE query_plan LIKE '%Columnstore%'
ORDER BY avg_query_max_used_memory DESC;
*/

-- ====== Archiving strategy with columnstore ======
/*
-- Columnstore is great for archive tables:
-- 1. Create archive table with columnstore
-- 2. Switch old partitions to archive
-- 3. Keep hot data in rowstore for OLTP
-- 4. Keep cold data in columnstore for analytics
*/

PRINT 'Columnstore queries complete. Check execution plans for batch mode indicators.';
