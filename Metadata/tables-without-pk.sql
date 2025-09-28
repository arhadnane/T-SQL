/*
tables-without-pk.sql
User tables that do not have a PRIMARY KEY.
*/

SELECT 
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints kc
    WHERE kc.parent_object_id = t.object_id
      AND kc.type = 'PK'
)
ORDER BY s.name, t.name;