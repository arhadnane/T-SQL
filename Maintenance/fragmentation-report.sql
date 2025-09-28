/*
fragmentation-report.sql
Lists index fragmentation by table and index with page_count and avg_fragmentation_in_percent.
*/

DECLARE @DatabaseName sysname = DB_NAME();

SELECT 
    sch.name AS SchemaName,
    o.name AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(@DatabaseName), NULL, NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.schemas sch ON sch.schema_id = o.schema_id
WHERE i.index_id > 0 AND ips.page_count > 8 -- skip tiny indexes
ORDER BY ips.avg_fragmentation_in_percent DESC, ips.page_count DESC;