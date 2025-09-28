/*
05-find-objects.sql
Search for objects by name pattern across schemas (tables, views, procs, functions, triggers).
*/

DECLARE @DatabaseName sysname = N'SSUSToolkit';
DECLARE @Pattern nvarchar(200) = N'%Product%'; -- edit

EXEC('USE ' + QUOTENAME(@DatabaseName));

SELECT 
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type AS ObjectType,
    o.type_desc AS ObjectTypeDesc
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.name LIKE @Pattern
ORDER BY o.type, s.name, o.name;