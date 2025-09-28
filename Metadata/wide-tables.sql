/*
wide-tables.sql
Find wide tables by column count and total row size estimate.
*/

DECLARE @MinColumns int = 100; -- threshold for "wide" tables

;WITH cols AS (
    SELECT t.[object_id], COUNT(*) AS col_count
    FROM sys.columns c
    JOIN sys.tables t ON t.[object_id] = c.[object_id]
    GROUP BY t.[object_id]
), size_est AS (
    SELECT t.[object_id], SUM(CASE WHEN ty.is_user_defined = 0 THEN 
            CASE ty.name
                WHEN 'tinyint' THEN 1
                WHEN 'smallint' THEN 2
                WHEN 'int' THEN 4
                WHEN 'bigint' THEN 8
                WHEN 'bit' THEN 1
                WHEN 'real' THEN 4
                WHEN 'float' THEN 8
                WHEN 'money' THEN 8
                WHEN 'smallmoney' THEN 4
                WHEN 'date' THEN 3
                WHEN 'smalldatetime' THEN 4
                WHEN 'datetime' THEN 8
                WHEN 'datetime2' THEN 8
                WHEN 'time' THEN 5
                WHEN 'uniqueidentifier' THEN 16
                WHEN 'nchar' THEN c.max_length
                WHEN 'nvarchar' THEN CASE WHEN c.max_length = -1 THEN 2000 ELSE c.max_length END
                WHEN 'char' THEN c.max_length
                WHEN 'varchar' THEN CASE WHEN c.max_length = -1 THEN 4000 ELSE c.max_length END
                WHEN 'binary' THEN c.max_length
                WHEN 'varbinary' THEN CASE WHEN c.max_length = -1 THEN 8000 ELSE c.max_length END
                ELSE 8
            END
        ELSE 8 END) AS estimated_row_bytes
    FROM sys.columns c
    JOIN sys.tables t ON t.[object_id] = c.[object_id]
    JOIN sys.types ty ON ty.user_type_id = c.user_type_id
    GROUP BY t.[object_id]
)
SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.col_count,
    s.estimated_row_bytes
FROM sys.tables t
JOIN cols c ON c.[object_id] = t.[object_id]
JOIN size_est s ON s.[object_id] = t.[object_id]
WHERE c.col_count >= @MinColumns
ORDER BY c.col_count DESC, s.estimated_row_bytes DESC;