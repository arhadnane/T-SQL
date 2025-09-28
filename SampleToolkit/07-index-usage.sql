/*
07-index-usage.sql
Shows seek/scan/lookup/update counts per index with last user seek/scan/update times.
*/

DECLARE @DatabaseName sysname = N'SSUSToolkit';
EXEC('USE ' + QUOTENAME(@DatabaseName));

SELECT 
    sch.name AS SchemaName,
    o.name AS TableName,
    i.name AS IndexName,
    i.type_desc,
    usg.user_seeks,
    usg.user_scans,
    usg.user_lookups,
    usg.user_updates,
    usg.last_user_seek,
    usg.last_user_scan,
    usg.last_user_lookup,
    usg.last_user_update
FROM sys.indexes i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.schemas sch ON sch.schema_id = o.schema_id
LEFT JOIN sys.dm_db_index_usage_stats usg
  ON usg.database_id = DB_ID(@DatabaseName)
 AND usg.object_id = i.object_id
 AND usg.index_id = i.index_id
WHERE o.type = 'U' AND i.index_id > 0
ORDER BY sch.name, o.name, i.index_id;