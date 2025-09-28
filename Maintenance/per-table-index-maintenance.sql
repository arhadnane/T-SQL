/*
per-table-index-maintenance.sql
Generate maintenance for a single table: REORGANIZE 5–30%, REBUILD ≥30%.
*/

DECLARE @Schema sysname = N'dbo';
DECLARE @Table  sysname = N'Products';
DECLARE @Low int = 5, @High int = 30;

;WITH fr AS (
    SELECT i.name AS IndexName, ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(QUOTENAME(@Schema)+'.'+QUOTENAME(@Table)), NULL, NULL, 'SAMPLED') ips
    JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
    WHERE i.index_id > 0 AND ips.page_count > 8
)
SELECT 
    CASE WHEN fr.avg_fragmentation_in_percent >= @High THEN 'REBUILD'
         WHEN fr.avg_fragmentation_in_percent BETWEEN @Low AND @High THEN 'REORGANIZE'
         ELSE 'SKIP' END AS ActionNeeded,
    'ALTER INDEX ' + QUOTENAME(fr.IndexName) + ' ON ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + ' ' +
    CASE WHEN fr.avg_fragmentation_in_percent >= @High THEN 'REBUILD;'
         WHEN fr.avg_fragmentation_in_percent BETWEEN @Low AND @High THEN 'REORGANIZE;'
         ELSE '--' END AS Cmd,
    fr.*
FROM fr
ORDER BY fr.avg_fragmentation_in_percent DESC;