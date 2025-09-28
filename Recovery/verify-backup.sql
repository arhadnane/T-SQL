/*
verify-backup.sql
VERIFYONLY on a backup file to validate header and checksums.
*/

DECLARE @BackupFile nvarchar(4000) = N'C:\Backups\MyDb_20250101_010101_FULL.bak'; -- EDIT

RESTORE VERIFYONLY FROM DISK = @BackupFile WITH CHECKSUM;