/*
02-fix-common-implicit-conversions.sql
Purpose: Demonstrate fixes for common implicit conversion scenarios
*/

USE SSUSToolkit;
GO

-- ====== Scenario 1: NVARCHAR column with VARCHAR literal ======
/*
-- BAD (causes implicit conversion):
SELECT * FROM dbo.Customers WHERE Email = 'john@example.com'

-- GOOD (explicit unicode literal):
SELECT * FROM dbo.Customers WHERE Email = N'john@example.com'

-- VERIFY: Check column data types
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers' AND COLUMN_NAME = 'Email';
*/

-- ====== Scenario 2: Date comparisons ======
/*
-- BAD (string literal):
SELECT * FROM dbo.Orders WHERE OrderDate = '2024-01-01'

-- GOOD (ANSI format - no conversion needed):
SELECT * FROM dbo.Orders WHERE OrderDate = '20240101'

-- GOOD (explicit cast):
SELECT * FROM dbo.Orders WHERE OrderDate = CAST('2024-01-01' AS DATE)

-- GOOD (date literal):
SELECT * FROM dbo.Orders WHERE OrderDate = DATEFROMPARTS(2024, 1, 1)
*/

-- ====== Scenario 3: Stored procedure parameter mismatch ======
/*
-- Table definition:
CREATE TABLE dbo.Products (SKU VARCHAR(50), Name NVARCHAR(200))

-- BAD procedure (NVARCHAR param on VARCHAR column):
CREATE PROC usp_GetProduct @SKU NVARCHAR(50)
AS SELECT * FROM dbo.Products WHERE SKU = @SKU

-- GOOD procedure (VARCHAR param matches column):
CREATE PROC usp_GetProduct @SKU VARCHAR(50)
AS SELECT * FROM dbo.Products WHERE SKU = @SKU
*/

-- ====== Helper: Find columns prone to conversion issues ======
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length,
    c.collation_name,
    CASE 
        WHEN ty.name LIKE '%char%' AND c.collation_name LIKE '%CI_AS%'
        THEN 'Check: Case-insensitive comparisons may cause issues'
        WHEN ty.name IN ('nvarchar', 'nchar') 
        THEN 'Tip: Use N'' prefix for literals'
        WHEN ty.name IN ('date', 'datetime', 'datetime2')
        THEN 'Tip: Use explicit CAST or ANSI format (YYYYMMDD)'
    END AS Recommendation
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE t.is_ms_shipped = 0
    AND ty.name IN ('nvarchar', 'varchar', 'nchar', 'char', 'date', 'datetime', 'datetime2')
ORDER BY t.name, c.name;
GO

-- ====== Scenario 4: Calculated columns causing conversion ======
/*
-- BAD (LineTotal computed from different types):
LineTotal AS (Quantity * UnitPrice) -- If Quantity is INT and UnitPrice is DECIMAL

-- GOOD (ensure consistent types):
LineTotal AS (CAST(Quantity AS DECIMAL(18,2)) * UnitPrice) PERSISTED
*/

-- ====== Audit: Check existing computed columns ======
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    cc.definition AS ComputedDefinition,
    CASE 
        WHEN cc.definition LIKE '%*%' 
            AND (cc.definition LIKE '%int%' OR cc.definition LIKE '%decimal%')
        THEN 'Review: Mixed types in calculation'
        ELSE 'OK'
    END AS ReviewFlag
FROM sys.computed_columns cc
JOIN sys.tables t ON t.object_id = cc.object_id
JOIN sys.columns c ON c.object_id = cc.object_id AND c.column_id = cc.column_id
WHERE t.is_ms_shipped = 0;
GO

PRINT 'Review output for potential implicit conversion sources. Fix data type mismatches in application code.';
