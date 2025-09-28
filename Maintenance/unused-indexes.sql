/*
unused-indexes.sql
Find nonclustered indexes with no user seeks/scans/lookups since last restart.
*/

SELECT 
    sch.name AS SchemaName,
    o.name AS TableName,
    i.name AS IndexName,
    i.index_id,
    usg.user_seeks,
    usg.user_scans,
    usg.user_lookups,
    usg.last_user_seek,
    usg.last_user_scan,
    usg.last_user_lookup
FROM sys.indexes i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.schemas sch ON sch.schema_id = o.schema_id
LEFT JOIN sys.dm_db_index_usage_stats usg
  ON usg.database_id = DB_ID()
 AND usg.object_id = i.object_id
 AND usg.index_id = i.index_id
WHERE o.type = 'U'
  AND i.is_primary_key = 0
  AND i.is_unique = 0
  AND i.index_id > 1
  AND (ISNULL(usg.user_seeks,0) + ISNULL(usg.user_scans,0) + ISNULL(usg.user_lookups,0)) = 0
ORDER BY sch.name, o.name, i.index_id;