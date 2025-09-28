/*
indexes-detail.sql
Detailed view of indexes: keys, included columns, uniqueness, and type.
*/

;WITH keys AS (
    SELECT 
        i.object_id,
        i.index_id,
        i.name AS IndexName,
        i.type_desc,
        i.is_unique,
        sch.name AS SchemaName,
        o.name AS TableName,
        STRING_AGG(CASE WHEN ic.is_included_column = 0 THEN c.name END, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) AS KeyColumns,
        STRING_AGG(CASE WHEN ic.is_included_column = 1 THEN c.name END, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) AS IncludedColumns
    FROM sys.indexes i
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    JOIN sys.objects o ON o.object_id = i.object_id
    JOIN sys.schemas sch ON sch.schema_id = o.schema_id
    WHERE i.index_id > 0
    GROUP BY i.object_id, i.index_id, i.name, i.type_desc, i.is_unique, sch.name, o.name
)
SELECT 
    SchemaName,
    TableName,
    IndexName,
    type_desc,
    is_unique,
    KeyColumns,
    IncludedColumns
FROM keys
ORDER BY SchemaName, TableName, IndexName;