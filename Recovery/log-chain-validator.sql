/*
log-chain-validator.sql
Validate backup chain (FULL/DIFF/LOG) continuity from msdb for a database.
*/

DECLARE @DbName sysname = N'MyDb'; -- EDIT

;WITH bak AS (
    SELECT backup_set_id, type, first_lsn, last_lsn, checkpoint_lsn, database_backup_lsn, backup_finish_date
    FROM msdb.dbo.backupset
    WHERE database_name = @DbName
)
SELECT TOP 200
    type,
    backup_finish_date,
    first_lsn,
    last_lsn,
    checkpoint_lsn,
    database_backup_lsn,
    CASE WHEN LAG(last_lsn) OVER (ORDER BY backup_finish_date, backup_set_id) = first_lsn THEN 'OK'
         WHEN type = 'D' THEN 'FULL'
         WHEN type = 'I' THEN 'DIFF'
         WHEN type = 'L' THEN CASE WHEN LAG(last_lsn) OVER (ORDER BY backup_finish_date, backup_set_id) <= first_lsn THEN 'OK-ish' ELSE 'GAP?' END
         ELSE 'UNKNOWN' END AS continuity
FROM bak
ORDER BY backup_finish_date, backup_set_id;