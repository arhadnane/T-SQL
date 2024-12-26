SELECT 
    ROW_NUMBER() OVER (PARTITION BY t.name ORDER BY c.name) AS RowNum,
    t.name AS TableName,
    c.name AS ColumnName,
    c.column_id,
    c.is_nullable,
    ty.name AS DataType
FROM sys.tables AS t
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
ORDER BY t.name, RowNum;
