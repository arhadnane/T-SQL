/*
dependencies.sql
Object dependencies using sys.sql_expression_dependencies.
*/

SELECT 
    sch_from.name + '.' + o_from.name AS ReferencingObject,
    d.referenced_schema_name + '.' + d.referenced_entity_name AS ReferencedObject,
    d.referencing_id,
    d.referenced_id,
    d.is_ambiguous
FROM sys.sql_expression_dependencies d
JOIN sys.objects o_from ON o_from.object_id = d.referencing_id
JOIN sys.schemas sch_from ON sch_from.schema_id = o_from.schema_id
WHERE d.referenced_id IS NOT NULL
ORDER BY ReferencingObject, ReferencedObject;