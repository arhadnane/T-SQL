/*
tail-log-backup.sql
Backup the tail of the log before restore operations.
*/

DECLARE @DbName sysname = N'MyDb'; -- EDIT
DECLARE @BackupFile nvarchar(4000) = N'C:\Backups\MyDb_tail.trn'; -- EDIT

-- If database is damaged or offline, consider WITH NO_TRUNCATE (older versions)
-- Otherwise, standard tail-log backup with NORECOVERY to prepare for restore
BACKUP LOG @DbName TO DISK = @BackupFile WITH NORECOVERY, STATS = 10;