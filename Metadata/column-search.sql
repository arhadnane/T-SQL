/*
column-search.sql
Search for a column name pattern across tables and schemas.
*/

DECLARE @Pattern nvarchar(200) = N'%name%';

SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE c.name LIKE @Pattern
ORDER BY s.name, t.name, c.name;