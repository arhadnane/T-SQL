/*
tables-rowcounts.sql
Row counts per user table, including heap/clustered info.
*/

;WITH rc AS (
    SELECT 
        sch.name AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS RowCount,
        MAX(CASE WHEN i.index_id = 0 THEN 1 ELSE 0 END) AS IsHeap
    FROM sys.tables t
    JOIN sys.schemas sch ON sch.schema_id = t.schema_id
    JOIN sys.indexes i ON i.object_id = t.object_id AND i.index_id IN (0,1)
    JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id = i.index_id
    GROUP BY sch.name, t.name
)
SELECT 
    SchemaName,
    TableName,
    RowCount,
    CASE WHEN IsHeap = 1 THEN 'HEAP' ELSE 'CLUSTERED' END AS Storage
FROM rc
ORDER BY RowCount DESC, SchemaName, TableName;