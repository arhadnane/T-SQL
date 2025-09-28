/*
collation-differences.sql
Columns whose collation differs from the database collation.
*/

DECLARE @DbCollation sysname = CAST(DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS sysname);

SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    c.collation_name,
    @DbCollation AS DatabaseCollation
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE c.collation_name IS NOT NULL
  AND c.collation_name <> @DbCollation
ORDER BY s.name, t.name, c.name;