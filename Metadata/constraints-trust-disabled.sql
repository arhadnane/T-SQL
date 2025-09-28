/*
constraints-trust-disabled.sql
List disabled and/or not trusted constraints (FK and CHECK).
*/

SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ConstraintName,
    c.type_desc,
    c.is_disabled,
    c.is_not_trusted
FROM sys.check_constraints cc
JOIN sys.objects c ON c.object_id = cc.object_id
JOIN sys.tables t ON t.object_id = cc.parent_object_id
UNION ALL
SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    fk.name AS ConstraintName,
    'FOREIGN_KEY_CONSTRAINT' AS type_desc,
    fk.is_disabled,
    fk.is_not_trusted
FROM sys.foreign_keys fk
JOIN sys.tables t ON t.object_id = fk.parent_object_id
ORDER BY SchemaName, TableName, ConstraintName;