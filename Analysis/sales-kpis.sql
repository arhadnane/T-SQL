/*
sales-kpis.sql
Core sales KPIs over Orders/OrderItems: revenue, AOV, items per order, customer activity.
*/

USE SSUSToolkit;
GO

;WITH order_totals AS (
    SELECT o.OrderID, o.CustomerID, o.OrderDate,
           SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
           SUM(oi.Quantity) AS Items
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID
    GROUP BY o.OrderID, o.CustomerID, o.OrderDate
), by_day AS (
    SELECT CAST(OrderDate AS date) AS [Date],
           COUNT(*) AS Orders,
           SUM(Revenue) AS Revenue,
           AVG(Revenue) AS AOV,
           AVG(Items*1.0) AS ItemsPerOrder
    FROM order_totals
    GROUP BY CAST(OrderDate AS date)
)
SELECT 
    (SELECT SUM(Revenue) FROM order_totals) AS TotalRevenue,
    (SELECT AVG(Revenue) FROM order_totals) AS AvgOrderValue,
    (SELECT AVG(Items*1.0) FROM order_totals) AS AvgItemsPerOrder,
    (SELECT COUNT(DISTINCT CustomerID) FROM order_totals) AS ActiveCustomers,
    (SELECT COUNT(*) FROM order_totals) AS TotalOrders,
    (SELECT COUNT(*) FROM by_day WHERE Revenue > 0) AS ActiveDays
;