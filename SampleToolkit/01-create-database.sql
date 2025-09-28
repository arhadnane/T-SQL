/*
01-create-database.sql
Creates a lightweight sample database with a dbo schema and a few tables.
Safe to re-run: drops existing DB (optional toggle) and recreates.
*/

-- ====== Parameters (edit before running) ======
DECLARE @DatabaseName sysname = N'SSUSToolkit';
DECLARE @DropIfExists bit = 0; -- set to 1 to drop and recreate

-- ====== Safety: block if running on master/msdb/tempdb/model ======
IF DB_NAME() IN (N'master', N'msdb', N'model', N'tempdb')
BEGIN
    PRINT 'Tip: Run from any user DB; script will switch to target DB automatically.';
END

-- ====== Optional drop ======
IF @DropIfExists = 1 AND DB_ID(@DatabaseName) IS NOT NULL
BEGIN
    DECLARE @kill nvarchar(max) = N'';
    SELECT @kill = @kill + N'KILL ' + CAST(session_id AS nvarchar(10)) + N';'
    FROM sys.dm_exec_sessions s
    JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
    WHERE r.database_id = DB_ID(@DatabaseName);

    EXEC sp_executesql @kill;
    EXEC('ALTER DATABASE ' + QUOTENAME(@DatabaseName) + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');
    EXEC('DROP DATABASE ' + QUOTENAME(@DatabaseName));
END

-- ====== Create DB if needed ======
IF DB_ID(@DatabaseName) IS NULL
BEGIN
    EXEC('CREATE DATABASE ' + QUOTENAME(@DatabaseName));
END
GO

-- Switch context
USE [SSUSToolkit];
GO

-- Idempotent objects
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo')
    EXEC('CREATE SCHEMA dbo');
GO

-- Tables: Customers, Products, Orders, OrderItems
IF OBJECT_ID('dbo.Customers') IS NULL
BEGIN
    CREATE TABLE dbo.Customers (
        CustomerID int IDENTITY(1,1) PRIMARY KEY,
        FirstName  nvarchar(50) NOT NULL,
        LastName   nvarchar(50) NOT NULL,
        Email      nvarchar(255) UNIQUE,
        Phone      nvarchar(25),
        CreatedAt  datetime2(0) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END

IF OBJECT_ID('dbo.Products') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        ProductID  int IDENTITY(1,1) PRIMARY KEY,
        SKU        nvarchar(50) NOT NULL UNIQUE,
        Name       nvarchar(200) NOT NULL,
        Category   nvarchar(100),
        Price      decimal(12,2) NOT NULL,
        IsActive   bit NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT 1,
        CreatedAt  datetime2(0) NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END

IF OBJECT_ID('dbo.Orders') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        OrderID     int IDENTITY(1,1) PRIMARY KEY,
        CustomerID  int NOT NULL FOREIGN KEY REFERENCES dbo.Customers(CustomerID),
        OrderDate   datetime2(0) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT SYSUTCDATETIME(),
        Status      nvarchar(30) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT N'Pending'
    );
END

IF OBJECT_ID('dbo.OrderItems') IS NULL
BEGIN
    CREATE TABLE dbo.OrderItems (
        OrderItemID int IDENTITY(1,1) PRIMARY KEY,
        OrderID     int NOT NULL FOREIGN KEY REFERENCES dbo.Orders(OrderID),
        ProductID   int NOT NULL FOREIGN KEY REFERENCES dbo.Products(ProductID),
        Quantity    int NOT NULL CHECK(Quantity > 0),
        UnitPrice   decimal(12,2) NOT NULL,
        LineTotal   AS (Quantity * UnitPrice) PERSISTED
    );
END

PRINT 'Database and core tables ready in ' + @DatabaseName + '.';