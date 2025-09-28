/*
views-procedures.sql
List views and stored procedures; optionally include definitions (first 4000 chars).
*/

DECLARE @IncludeDefinition bit = 0;

SELECT 
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type_desc,
    CASE WHEN @IncludeDefinition = 1 THEN LEFT(sm.definition, 4000) END AS Definition
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.sql_modules sm ON sm.object_id = o.object_id
WHERE o.type IN ('V','P')
ORDER BY o.type, s.name, o.name;