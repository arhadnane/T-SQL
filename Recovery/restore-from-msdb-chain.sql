/*
restore-from-msdb-chain.sql
Generate ordered RESTORE commands from msdb history for latest FULL (+DIFF) and subsequent LOGs.
*/

DECLARE @DbName sysname = N'MyDb'; -- EDIT

;WITH full_bak AS (
    SELECT TOP 1 b.backup_set_id, b.backup_finish_date, b.first_lsn, b.last_lsn
    FROM msdb.dbo.backupset b
    WHERE b.database_name = @DbName AND b.type = 'D'
    ORDER BY b.backup_finish_date DESC
), diff_bak AS (
    SELECT TOP 1 b.backup_set_id, b.first_lsn, b.last_lsn
    FROM msdb.dbo.backupset b
    JOIN full_bak f ON b.database_name = @DbName AND b.type = 'I' AND b.database_name = @DbName AND b.checkpoint_lsn >= f.first_lsn AND b.checkpoint_lsn <= f.last_lsn
    ORDER BY b.backup_finish_date DESC
), logs AS (
    SELECT b.backup_set_id, b.first_lsn, b.last_lsn, b.backup_finish_date
    FROM msdb.dbo.backupset b
    JOIN full_bak f ON b.database_name = @DbName AND b.type = 'L' AND b.first_lsn >= f.last_lsn
)
SELECT * FROM (
    SELECT 1 AS ord, '-- Restore FULL' AS Info, 'RESTORE DATABASE ' + QUOTENAME(@DbName) + ' FROM DISK = ''<FULL_FILE>'' WITH REPLACE, NORECOVERY;' AS Cmd
    UNION ALL
    SELECT 2, '-- Restore DIFF (if exists)', 'RESTORE DATABASE ' + QUOTENAME(@DbName) + ' FROM DISK = ''<DIFF_FILE>'' WITH NORECOVERY;' WHERE EXISTS (SELECT 1 FROM diff_bak)
    UNION ALL
    SELECT 3, '-- Restore LOGs', 'RESTORE LOG ' + QUOTENAME(@DbName) + ' FROM DISK = ''<LOG_FILES_IN_ORDER>'' WITH NORECOVERY;'
) x
ORDER BY ord;