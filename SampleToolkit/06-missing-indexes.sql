/*
06-missing-indexes.sql
Reports missing index recommendations from DMVs. Weighs impact by avg user impact and improvements.
*/

DECLARE @DatabaseName sysname = N'SSUSToolkit';
EXEC('USE ' + QUOTENAME(@DatabaseName));

SELECT TOP 50
    DB_NAME(mid.database_id) AS DatabaseName,
    OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) AS SchemaName,
    OBJECT_NAME(mid.object_id, mid.database_id) AS TableName,
    migs.avg_total_user_cost * (migs.avg_user_impact/100.0) * (migs.user_seeks + migs.user_scans) AS Impact,
    migs.user_seeks, migs.user_scans,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID(@DatabaseName)
ORDER BY Impact DESC;