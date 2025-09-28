/*
08-table-sizes.sql
Returns row counts, reserved/used space per user table.
*/

DECLARE @DatabaseName sysname = N'SSUSToolkit';
EXEC('USE ' + QUOTENAME(@DatabaseName));

;WITH s AS (
    SELECT 
        sch.name AS SchemaName,
        t.name AS TableName,
        p.rows,
        a.total_pages,
        a.used_pages,
        a.data_pages
    FROM sys.tables t
    JOIN sys.schemas sch ON sch.schema_id = t.schema_id
    JOIN sys.indexes i ON i.object_id = t.object_id AND i.index_id IN (0,1)
    JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id = i.index_id
    JOIN sys.allocation_units a ON a.container_id = p.partition_id
)
SELECT 
    SchemaName,
    TableName,
    rows AS RowCount,
    CONVERT(decimal(12,2), total_pages*8.0/1024) AS TotalMB,
    CONVERT(decimal(12,2), used_pages*8.0/1024)  AS UsedMB,
    CONVERT(decimal(12,2), data_pages*8.0/1024)  AS DataMB
FROM s
ORDER BY UsedMB DESC;