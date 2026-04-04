/*
01-create-partition-function-scheme.sql
Purpose: Create partition function and scheme for large tables (Orders, Logs)
Recommended for: Tables > 10M rows with date-based queries
*/

USE SSUSToolkit;
GO

-- ====== Partition Function: Monthly ranges ======
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'PF_Monthly')
BEGIN
    CREATE PARTITION FUNCTION PF_Monthly (datetime2(0))
    AS RANGE RIGHT FOR VALUES (
        '2024-01-01', '2024-02-01', '2024-03-01', '2024-04-01',
        '2024-05-01', '2024-06-01', '2024-07-01', '2024-08-01',
        '2024-09-01', '2024-10-01', '2024-11-01', '2024-12-01',
        '2025-01-01', '2025-02-01', '2025-03-01', '2025-04-01',
        '2025-05-01', '2025-06-01', '2025-07-01', '2025-08-01',
        '2025-09-01', '2025-10-01', '2025-11-01', '2025-12-01'
    );
    PRINT 'Partition function PF_Monthly created.';
END
ELSE
BEGIN
    PRINT 'Partition function PF_Monthly already exists.';
END
GO

-- ====== Partition Scheme ======
IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'PS_Monthly')
BEGIN
    CREATE PARTITION SCHEME PS_Monthly
    AS PARTITION PF_Monthly
    ALL TO ([PRIMARY]);
    PRINT 'Partition scheme PS_Monthly created.';
END
ELSE
BEGIN
    PRINT 'Partition scheme PS_Monthly already exists.';
END
GO

-- ====== Helper: View partition ranges ======
SELECT 
    pf.name AS PartitionFunction,
    prv.boundary_id AS PartitionNumber,
    prv.value AS BoundaryValue,
    CASE WHEN pf.boundary_value_on_right = 1 THEN 'RIGHT' ELSE 'LEFT' END AS RangeType
FROM sys.partition_functions pf
JOIN sys.partition_range_values prv ON prv.function_id = pf.function_id
WHERE pf.name = N'PF_Monthly'
ORDER BY prv.boundary_id;
GO

PRINT 'Partition infrastructure ready. Use PS_Monthly when creating partitioned tables.';
