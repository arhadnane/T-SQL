/*
objects-modified.sql
Recently created/modified objects.
*/

DECLARE @Top int = 100;

SELECT TOP (@Top)
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type_desc,
    o.create_date,
    o.modify_date
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY o.modify_date DESC, o.create_date DESC;