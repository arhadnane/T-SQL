/*
update-stats-by-modcounter.sql
Update statistics only when rowmodctr (or delta) suggests meaningful change.
Notes: rowmodctr is per-index; for column stats, use sys.dm_db_stats_properties.
*/

DECLARE @ThresholdPercent decimal(5,2) = 20.0; -- percent of rowcount changed
DECLARE @MinRows bigint = 1000; -- skip tiny tables

;WITH rc AS (
    SELECT t.[object_id], SUM(p.[rows]) AS row_count
    FROM sys.tables t
    JOIN sys.partitions p ON p.[object_id] = t.[object_id] AND p.index_id IN (0,1)
    GROUP BY t.[object_id]
), mods AS (
    SELECT i.[object_id], SUM(i.rowmodctr) AS rowmod
    FROM sys.sysindexes i -- legacy view but still useful
    WHERE i.indid IN (0,1)
    GROUP BY i.[object_id]
)
SELECT 'UPDATE STATISTICS ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) + ' WITH AUTO_DROP = OFF;' AS Cmd,
       rc.row_count, mods.rowmod,
       CONVERT(decimal(10,2), 100.0 * ISNULL(mods.rowmod,0) / NULLIF(rc.row_count,0)) AS pct_modified
FROM sys.tables t
JOIN rc ON rc.[object_id] = t.[object_id]
LEFT JOIN mods ON mods.[object_id] = t.[object_id]
WHERE rc.row_count >= @MinRows
  AND (100.0 * ISNULL(mods.rowmod,0) / NULLIF(rc.row_count,0)) >= @ThresholdPercent
ORDER BY pct_modified DESC;