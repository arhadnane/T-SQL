/*
partition-aware-index-maintenance.sql
Reorganize lightly fragmented partitions and rebuild heavily fragmented partitions.
*/

DECLARE @Low int = 5, @High int = 30;

;WITH ips AS (
    SELECT
        OBJECT_SCHEMA_NAME(i.[object_id]) AS SchemaName,
        OBJECT_NAME(i.[object_id]) AS TableName,
        i.name AS IndexName,
        ips.partition_number,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    JOIN sys.indexes i ON i.[object_id] = ips.[object_id] AND i.index_id = ips.index_id
    WHERE i.index_id > 0 AND ips.page_count > 8
)
SELECT 
    CASE WHEN ips.avg_fragmentation_in_percent >= @High THEN 'REBUILD'
         WHEN ips.avg_fragmentation_in_percent BETWEEN @Low AND @High THEN 'REORGANIZE'
         ELSE 'SKIP' END AS ActionNeeded,
    'ALTER INDEX ' + QUOTENAME(ips.IndexName) + ' ON ' + QUOTENAME(ips.SchemaName) + '.' + QUOTENAME(ips.TableName) +
    CASE WHEN ips.avg_fragmentation_in_percent >= @High
         THEN ' REBUILD PARTITION = ' + CAST(ips.partition_number AS nvarchar(10)) + ';'
         WHEN ips.avg_fragmentation_in_percent BETWEEN @Low AND @High
         THEN ' REORGANIZE PARTITION = ' + CAST(ips.partition_number AS nvarchar(10)) + ';'
         ELSE ';' END AS Cmd,
    ips.*
FROM ips
ORDER BY avg_fragmentation_in_percent DESC, page_count DESC;