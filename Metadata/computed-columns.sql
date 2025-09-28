/*
computed-columns.sql
Lists computed columns with persistence and definition.
*/

SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    cc.is_persisted,
    cc.definition
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.computed_columns cc ON cc.object_id = c.object_id AND cc.column_id = c.column_id
WHERE c.is_computed = 1
ORDER BY s.name, t.name, c.name;