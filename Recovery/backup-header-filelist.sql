/*
backup-header-filelist.sql
Read metadata from a backup file: HEADERONLY and FILELISTONLY.
*/

DECLARE @BackupFile nvarchar(4000) = N'C:\Backups\MyDb_20250101_010101_FULL.bak'; -- EDIT

RESTORE HEADERONLY FROM DISK = @BackupFile;
RESTORE FILELISTONLY FROM DISK = @BackupFile;