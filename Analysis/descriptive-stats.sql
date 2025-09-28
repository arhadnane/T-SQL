/*
descriptive-stats.sql
Descriptive statistics (count, min, max, avg, stdev, median, percentiles) for sample toolkit tables.
Requires SSUSToolkit created by SampleToolkit scripts.
*/

USE SSUSToolkit;
GO

-- Customers per country/city (basic counts)
SELECT Country, City, COUNT(*) AS Customers
FROM dbo.Customers
GROUP BY Country, City
ORDER BY Country, City;

-- Product price stats
SELECT 
    COUNT(*) AS ProductCount,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    AVG(Price) AS AvgPrice,
    STDEV(Price) AS StdevPrice,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price) OVER() AS MedianPrice,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY Price) OVER() AS P90Price
FROM dbo.Products;

-- Order totals: compute order value then summarize
;WITH order_totals AS (
    SELECT oi.OrderID, SUM(oi.Quantity * oi.UnitPrice) AS OrderValue
    FROM dbo.OrderItems oi
    GROUP BY oi.OrderID
)
SELECT 
    COUNT(*) AS Orders,
    MIN(OrderValue) AS MinOrderValue,
    MAX(OrderValue) AS MaxOrderValue,
    AVG(OrderValue) AS AvgOrderValue,
    STDEV(OrderValue) AS StdevOrderValue,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY OrderValue) OVER() AS MedianOrderValue,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY OrderValue) OVER() AS P95OrderValue
FROM order_totals;