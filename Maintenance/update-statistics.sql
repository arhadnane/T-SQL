/*
update-statistics.sql
Update statistics for all user tables with FULLSCAN option (configurable).
*/

DECLARE @FullScan bit = 0; -- set 1 for FULLSCAN

DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql +
    N'UPDATE STATISTICS ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + 
    CASE WHEN @FullScan = 1 THEN N' WITH FULLSCAN;' ELSE N';' END + CHAR(10)
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
ORDER BY s.name, t.name;

EXEC sp_executesql @sql, N'@FullScan bit', @FullScan=@FullScan;