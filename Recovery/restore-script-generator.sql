/*
restore-script-generator.sql
Generates RESTORE commands in order (FULL -> DIFF -> LOG) for files in @BackupDir matching @DbName.
*/

DECLARE @DbName sysname = N'MyDb'; -- EDIT
DECLARE @BackupDir nvarchar(4000) = N'C:\Backups'; -- EDIT

-- This script assumes backups follow the naming pattern created by backup-full-diff-log.sql
-- For production, consider reading msdb backup history instead of filesystem.

DECLARE @cmd nvarchar(max) = N'xp_cmdshell ''dir /b "' + @BackupDir + '\' + @DbName + '*"''';
DECLARE @files TABLE(line nvarchar(4000));
INSERT @files EXEC(@cmd);

;WITH f AS (
    SELECT line,
           CASE WHEN line LIKE '%_FULL.bak' THEN 1 WHEN line LIKE '%_DIFF.bak' THEN 2 WHEN line LIKE '%_LOG.trn' THEN 3 END AS kind
    FROM @files
)
SELECT '-- Review and execute in order' AS Info, * FROM (
SELECT 1 AS ord, 'RESTORE DATABASE ' + QUOTENAME(@DbName) + ' FROM DISK = N''' + @BackupDir + '\' + line + ''' WITH REPLACE, NORECOVERY, STATS = 10;' AS Cmd FROM f WHERE kind = 1
UNION ALL
SELECT 2, 'RESTORE DATABASE ' + QUOTENAME(@DbName) + ' FROM DISK = N''' + @BackupDir + '\' + line + ''' WITH NORECOVERY, STATS = 10;' FROM f WHERE kind = 2
UNION ALL
SELECT 3, 'RESTORE LOG ' + QUOTENAME(@DbName) + ' FROM DISK = N''' + @BackupDir + '\' + line + ''' WITH NORECOVERY, STATS = 10;' FROM f WHERE kind = 3
) x
ORDER BY ord;