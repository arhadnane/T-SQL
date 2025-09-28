/*
rebuild-reorganize-setbased.sql
Set-based index maintenance: REORGANIZE for 5-30%, REBUILD for >=30%.
*/

DECLARE @Low int = 5, @High int = 30;

;WITH fr AS (
    SELECT 
        sch.name AS SchemaName,
        o.name AS TableName,
        i.name AS IndexName,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
    JOIN sys.objects o ON o.object_id = i.object_id
    JOIN sys.schemas sch ON sch.schema_id = o.schema_id
    WHERE i.index_id > 0 AND ips.page_count > 8
)
SELECT 
    CASE WHEN fr.avg_fragmentation_in_percent >= @High THEN 'REBUILD'
         WHEN fr.avg_fragmentation_in_percent BETWEEN @Low AND @High THEN 'REORGANIZE'
         ELSE 'SKIP' END AS ActionNeeded,
    fr.*,
    Cmd = CASE WHEN fr.avg_fragmentation_in_percent >= @High
               THEN 'ALTER INDEX [' + fr.IndexName + '] ON [' + fr.SchemaName + '].[' + fr.TableName + '] REBUILD;'
               WHEN fr.avg_fragmentation_in_percent BETWEEN @Low AND @High
               THEN 'ALTER INDEX [' + fr.IndexName + '] ON [' + fr.SchemaName + '].[' + fr.TableName + '] REORGANIZE;'
               ELSE NULL END
FROM fr
ORDER BY 
    CASE WHEN fr.avg_fragmentation_in_percent >= @High THEN 1
         WHEN fr.avg_fragmentation_in_percent BETWEEN @Low AND @High THEN 2
         ELSE 3 END,
    fr.avg_fragmentation_in_percent DESC;