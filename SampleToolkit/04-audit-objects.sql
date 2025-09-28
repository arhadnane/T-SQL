/*
04-audit-objects.sql
Sets up a simple audit table and triggers for Customers and Products.
*/

USE [SSUSToolkit];
GO

IF OBJECT_ID('dbo.AuditLog') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLog (
        AuditID      bigint IDENTITY(1,1) PRIMARY KEY,
        EventTime    datetime2(3) NOT NULL CONSTRAINT DF_AuditLog_EventTime DEFAULT SYSUTCDATETIME(),
        EventType    nvarchar(10) NOT NULL, -- INSERT/UPDATE/DELETE
        TableName    sysname NOT NULL,
        KeyValues    nvarchar(4000) NULL,
        ChangedCols  nvarchar(4000) NULL,
        OldValues    nvarchar(max) NULL,
        NewValues    nvarchar(max) NULL,
        LoginName    nvarchar(256) NULL,
        HostName     nvarchar(256) NULL
    );
END
GO

-- Helper: generic pattern for simple tables without JSON
CREATE OR ALTER TRIGGER dbo.trg_Customers_Audit ON dbo.Customers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Login nvarchar(256) = ORIGINAL_LOGIN();
    DECLARE @Host  nvarchar(256) = HOST_NAME();

    -- INSERTS
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, NewValues, LoginName, HostName)
    SELECT 'INSERT', 'dbo.Customers',
           CONCAT('CustomerID=', i.CustomerID),
           CONCAT('FirstName=', i.FirstName, ';LastName=', i.LastName, ';Email=', i.Email, ';Phone=', i.Phone),
           @Login, @Host
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted);

    -- DELETES
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, OldValues, LoginName, HostName)
    SELECT 'DELETE', 'dbo.Customers',
           CONCAT('CustomerID=', d.CustomerID),
           CONCAT('FirstName=', d.FirstName, ';LastName=', d.LastName, ';Email=', d.Email, ';Phone=', d.Phone),
           @Login, @Host
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted);

    -- UPDATES
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, ChangedCols, OldValues, NewValues, LoginName, HostName)
    SELECT 'UPDATE', 'dbo.Customers',
           CONCAT('CustomerID=', i.CustomerID),
           NULL,
           CONCAT('FirstName=', d.FirstName, ';LastName=', d.LastName, ';Email=', d.Email, ';Phone=', d.Phone),
           CONCAT('FirstName=', i.FirstName, ';LastName=', i.LastName, ';Email=', i.Email, ';Phone=', i.Phone),
           @Login, @Host
    FROM inserted i
    JOIN deleted d ON d.CustomerID = i.CustomerID
    WHERE EXISTS (SELECT i.CustomerID) AND EXISTS (SELECT d.CustomerID);
END
GO

CREATE OR ALTER TRIGGER dbo.trg_Products_Audit ON dbo.Products
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Login nvarchar(256) = ORIGINAL_LOGIN();
    DECLARE @Host  nvarchar(256) = HOST_NAME();

    -- INSERTS
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, NewValues, LoginName, HostName)
    SELECT 'INSERT', 'dbo.Products',
           CONCAT('ProductID=', i.ProductID),
           CONCAT('SKU=', i.SKU, ';Name=', i.Name, ';Category=', i.Category, ';Price=', i.Price),
           @Login, @Host
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted);

    -- DELETES
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, OldValues, LoginName, HostName)
    SELECT 'DELETE', 'dbo.Products',
           CONCAT('ProductID=', d.ProductID),
           CONCAT('SKU=', d.SKU, ';Name=', d.Name, ';Category=', d.Category, ';Price=', d.Price),
           @Login, @Host
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted);

    -- UPDATES
    INSERT dbo.AuditLog(EventType, TableName, KeyValues, ChangedCols, OldValues, NewValues, LoginName, HostName)
    SELECT 'UPDATE', 'dbo.Products',
           CONCAT('ProductID=', i.ProductID),
           NULL,
           CONCAT('SKU=', d.SKU, ';Name=', d.Name, ';Category=', d.Category, ';Price=', d.Price),
           CONCAT('SKU=', i.SKU, ';Name=', i.Name, ';Category=', i.Category, ';Price=', i.Price),
           @Login, @Host
    FROM inserted i
    JOIN deleted d ON d.ProductID = i.ProductID
    WHERE EXISTS (SELECT i.ProductID) AND EXISTS (SELECT d.ProductID);
END
GO

PRINT 'Audit table and triggers created.';