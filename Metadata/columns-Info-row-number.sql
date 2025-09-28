/*
ColumnsInfoWithRowNumber.sql
Purpose: List columns for all user tables with a row number per table.
Notes: Optional filters by schema/table; includes data length/precision/scale.
*/

DECLARE @SchemaName sysname = NULL; -- e.g., N'dbo'
DECLARE @TableName  sysname = NULL; -- e.g., N'Products'

SELECT 
    ROW_NUMBER() OVER (PARTITION BY t.name ORDER BY c.name) AS RowNum,
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    c.column_id,
    c.is_nullable,
    ty.name AS DataType,
    c.max_length,
    c.precision,
    c.scale
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
WHERE (@SchemaName IS NULL OR s.name = @SchemaName)
  AND (@TableName  IS NULL OR t.name = @TableName)
ORDER BY s.name, t.name, RowNum;
