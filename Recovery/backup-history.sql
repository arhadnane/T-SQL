/*
backup-history.sql
Shows recent backup history from msdb for a database.
*/

DECLARE @DbName sysname = DB_NAME();

SELECT TOP 200
    b.database_name,
    b.backup_start_date,
    b.backup_finish_date,
    DATEDIFF(second, b.backup_start_date, b.backup_finish_date) AS duration_s,
    b.type,
    CASE b.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFF' WHEN 'L' THEN 'LOG' ELSE b.type END AS backup_type,
    mf.physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily mf ON b.media_set_id = mf.media_set_id
WHERE b.database_name = @DbName
ORDER BY b.backup_finish_date DESC;