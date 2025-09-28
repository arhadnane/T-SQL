/*
02-seed-data.sql
Seeds sample data into the SSUSToolkit database. Safe to re-run: uses MERGE/IF NOT EXISTS.
*/

USE [SSUSToolkit];

-- Customers
MERGE dbo.Customers AS tgt
USING (
    VALUES
        (N'Ada',  N'Lovelace', N'ada@example.com',  N'+44 7000 0001'),
        (N'Grace',N'Hopper',   N'grace@example.com',N'+1 202 555 0102'),
        (N'Alan', N'Turing',   N'alan@example.com', N'+44 7000 0003')
) AS src(FirstName, LastName, Email, Phone)
ON tgt.Email = src.Email
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FirstName, LastName, Email, Phone)
    VALUES (src.FirstName, src.LastName, src.Email, src.Phone);

-- Products
MERGE dbo.Products AS tgt
USING (
    VALUES
        (N'SKU-001', N'Laptop 13"',     N'Computers', 999.99, 1),
        (N'SKU-002', N'Mechanical KB',  N'Peripherals', 129.99, 1),
        (N'SKU-003', N'HD Monitor 27"', N'Displays',   299.99, 1)
) AS src(SKU, Name, Category, Price, IsActive)
ON tgt.SKU = src.SKU
WHEN NOT MATCHED BY TARGET THEN
    INSERT (SKU, Name, Category, Price, IsActive)
    VALUES (src.SKU, src.Name, src.Category, src.Price, src.IsActive);

-- Orders + Items (insert simple order if not exists)
IF NOT EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    DECLARE @c int = (SELECT TOP 1 CustomerID FROM dbo.Customers ORDER BY CustomerID);
    INSERT dbo.Orders(CustomerID, Status) VALUES (@c, N'Pending');
    DECLARE @o int = SCOPE_IDENTITY();

    INSERT dbo.OrderItems(OrderID, ProductID, Quantity, UnitPrice)
    SELECT @o, ProductID, 1, Price FROM dbo.Products;
END

PRINT 'Seed data ensured.';