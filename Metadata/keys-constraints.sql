/*
keys-constraints.sql
Lists primary keys, unique constraints, and foreign keys with columns.
*/

-- Primary and Unique Constraints
;WITH k AS (
    SELECT 
        sch.name AS SchemaName,
        t.name AS TableName,
        kc.name AS ConstraintName,
        kc.type_desc AS ConstraintType,
        ic.key_ordinal,
        c.name AS ColumnName
    FROM sys.key_constraints kc
    JOIN sys.tables t ON t.object_id = kc.parent_object_id
    JOIN sys.schemas sch ON sch.schema_id = t.schema_id
    JOIN sys.index_columns ic ON ic.object_id = t.object_id AND ic.index_id = kc.unique_index_id
    JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = ic.column_id
)
SELECT 
    SchemaName,
    TableName,
    ConstraintName,
    ConstraintType,
    STRING_AGG(ColumnName, ',') WITHIN GROUP (ORDER BY key_ordinal) AS Columns
FROM k
GROUP BY SchemaName, TableName, ConstraintName, ConstraintType
ORDER BY SchemaName, TableName, ConstraintType, ConstraintName;

-- Foreign Keys
;WITH fk AS (
    SELECT 
        sch.name AS SchemaName,
        t.name AS TableName,
        f.name AS ForeignKeyName,
        sch2.name AS RefSchemaName,
        rt.name AS RefTableName,
        c.name AS ColumnName,
        rc.name AS RefColumnName,
        fc.constraint_column_id
    FROM sys.foreign_keys f
    JOIN sys.tables t ON t.object_id = f.parent_object_id
    JOIN sys.schemas sch ON sch.schema_id = t.schema_id
    JOIN sys.tables rt ON rt.object_id = f.referenced_object_id
    JOIN sys.schemas sch2 ON sch2.schema_id = rt.schema_id
    JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = f.object_id
    JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = fc.parent_column_id
    JOIN sys.columns rc ON rc.object_id = rt.object_id AND rc.column_id = fc.referenced_column_id
)
SELECT 
    SchemaName,
    TableName,
    ForeignKeyName,
    RefSchemaName + '.' + RefTableName AS References,
    STRING_AGG(ColumnName + '=' + RefColumnName, ',') WITHIN GROUP (ORDER BY constraint_column_id) AS ColumnMapping
FROM fk
GROUP BY SchemaName, TableName, ForeignKeyName, RefSchemaName, RefTableName
ORDER BY SchemaName, TableName, ForeignKeyName;