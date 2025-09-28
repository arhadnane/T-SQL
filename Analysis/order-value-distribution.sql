/*
order-value-distribution.sql
Distribution of order values: histogram buckets and percentile cutpoints.
*/

USE SSUSToolkit;
GO

;WITH order_totals AS (
    SELECT oi.OrderID, SUM(oi.Quantity * oi.UnitPrice) AS OrderValue
    FROM dbo.OrderItems oi
    GROUP BY oi.OrderID
), buckets AS (
    SELECT OrderValue,
           CASE 
             WHEN OrderValue < 50 THEN '< 50'
             WHEN OrderValue < 100 THEN '50-100'
             WHEN OrderValue < 250 THEN '100-250'
             WHEN OrderValue < 500 THEN '250-500'
             ELSE '>= 500'
           END AS Bucket
    FROM order_totals
)
SELECT Bucket, COUNT(*) AS Orders
FROM buckets
GROUP BY Bucket
ORDER BY MIN(CASE Bucket 
  WHEN '< 50' THEN 1 WHEN '50-100' THEN 2 WHEN '100-250' THEN 3 WHEN '250-500' THEN 4 ELSE 5 END);

-- Percentiles table
SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY OrderValue) OVER() AS P25,
    PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY OrderValue) OVER() AS P50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY OrderValue) OVER() AS P75,
    PERCENTILE_CONT(0.9)  WITHIN GROUP (ORDER BY OrderValue) OVER() AS P90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY OrderValue) OVER() AS P95
FROM (SELECT TOP 1 OrderValue FROM order_totals ORDER BY OrderValue) x;