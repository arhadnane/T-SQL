/*
synonyms-and-external-refs.sql
List synonyms and detect external references (linked servers or 3/4-part names) in modules.
*/

-- Synonyms
SELECT 
    SCHEMA_NAME(s.schema_id) AS SchemaName,
    s.name AS SynonymName,
    s.base_object_name
FROM sys.synonyms s
ORDER BY SchemaName, SynonymName;

-- External references in module definitions (best-effort pattern search)
SELECT 
    SCHEMA_NAME(so.schema_id) AS SchemaName,
    so.name AS ObjectName,
    so.type_desc,
    CASE WHEN sm.definition LIKE '%\[[_]]%\.%\.%\.%'
         THEN 1 ELSE 0 END AS has_four_part_name,
    CASE WHEN sm.definition LIKE '%OPENQUERY(%' OR sm.definition LIKE '%OPENDATASOURCE(%' OR sm.definition LIKE '%OPENROWSET(%'
         THEN 1 ELSE 0 END AS uses_openquery_or_external,
    LEFT(sm.definition, 4000) AS definition_snippet
FROM sys.objects so
JOIN sys.sql_modules sm ON sm.object_id = so.object_id
WHERE so.type IN ('P','V','FN','IF','TF','TR')
ORDER BY has_four_part_name DESC, uses_openquery_or_external DESC, SchemaName, ObjectName;