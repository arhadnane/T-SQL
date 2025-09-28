/*
backup-full-diff-log.sql
Convenience backups for FULL/DIFF/LOG with dated filenames. Edit @DbName and @BackupDir.
*/

DECLARE @DbName sysname = DB_NAME();
DECLARE @BackupDir nvarchar(4000) = N'C:\Backups'; -- EDIT
DECLARE @Stamp nvarchar(32) = CONVERT(nvarchar(32), GETDATE(), 112) + '_' + REPLACE(CONVERT(nvarchar(8), GETDATE(), 108), ':','');

DECLARE @Full nvarchar(4000) = @BackupDir + N'\' + @DbName + '_' + @Stamp + N'_FULL.bak';
DECLARE @Diff nvarchar(4000) = @BackupDir + N'\' + @DbName + '_' + @Stamp + N'_DIFF.bak';
DECLARE @Log  nvarchar(4000) = @BackupDir + N'\' + @DbName + '_' + @Stamp + N'_LOG.trn';

-- FULL
PRINT 'Backing up FULL to ' + @Full;
BACKUP DATABASE @DbName TO DISK = @Full WITH INIT, COPY_ONLY, STATS = 10;

-- DIFF
PRINT 'Backing up DIFF to ' + @Diff;
BACKUP DATABASE @DbName TO DISK = @Diff WITH DIFFERENTIAL, INIT, STATS = 10;

-- LOG (requires FULL/BULK_LOGGED recovery model)
IF (SELECT recovery_model_desc FROM sys.databases WHERE name = @DbName) IN ('FULL','BULK_LOGGED')
BEGIN
    PRINT 'Backing up LOG to ' + @Log;
    BACKUP LOG @DbName TO DISK = @Log WITH INIT, STATS = 10;
END
ELSE
BEGIN
    PRINT 'Skipping LOG backup: recovery model is SIMPLE.';
END