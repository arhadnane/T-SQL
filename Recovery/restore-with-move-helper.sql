/*
restore-with-move-helper.sql
Generate RESTORE ... WITH MOVE commands by inspecting backup FILELIST and current default data/log paths.
*/

DECLARE @BackupFile nvarchar(4000) = N'C:\Backups\MyDb_20250101_010101_FULL.bak'; -- EDIT
DECLARE @DbName sysname = N'MyDb'; -- target database name (new or overwrite)

DECLARE @Filelist TABLE (
    LogicalName nvarchar(128),
    PhysicalName nvarchar(260),
    Type char(1),
    FileGroupName nvarchar(128),
    Size numeric(20,0),
    MaxSize numeric(20,0),
    FileId int,
    CreateLSN numeric(25,0),
    DropLSN numeric(25,0),
    UniqueId uniqueidentifier,
    ReadOnlyLSN numeric(25,0),
    ReadWriteLSN numeric(25,0),
    BackupSizeInBytes bigint,
    SourceBlockSize int,
    FilegroupId int,
    LogGroupGUID uniqueidentifier,
    DifferentialBaseLSN numeric(25,0),
    DifferentialBaseGUID uniqueidentifier,
    IsReadOnly bit,
    IsPresent bit,
    TDEThumbprint varbinary(32)
);

INSERT INTO @Filelist
EXEC('RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@BackupFile, ''''));

DECLARE @DefaultData nvarchar(260) = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(260));
DECLARE @DefaultLog  nvarchar(260) = CAST(SERVERPROPERTY('InstanceDefaultLogPath')  AS nvarchar(260));

IF @DefaultData IS NULL SET @DefaultData = (SELECT TOP 1 physical_name FROM sys.master_files WHERE database_id = 1 AND type = 0);
IF @DefaultLog  IS NULL SET @DefaultLog  = (SELECT TOP 1 physical_name FROM sys.master_files WHERE database_id = 1 AND type = 1);

;WITH mapped AS (
    SELECT *,
        CASE WHEN Type = 'L' THEN @DefaultLog ELSE @DefaultData END AS BasePath,
        RIGHT(PhysicalName, CHARINDEX('\\', REVERSE(PhysicalName) + '\\') - 1) AS FileOnly
    FROM @Filelist
)
SELECT TOP 100
    CASE WHEN Type = 'L'
         THEN 'MOVE N' + QUOTENAME(LogicalName, '''') + ' TO N' + QUOTENAME(BasePath + CASE WHEN RIGHT(BasePath,1) IN ('\\','/') THEN '' ELSE '\\' END + FileOnly, '''')
         ELSE 'MOVE N' + QUOTENAME(LogicalName, '''') + ' TO N' + QUOTENAME(BasePath + CASE WHEN RIGHT(BasePath,1) IN ('\\','/') THEN '' ELSE '\\' END + FileOnly, '''') END AS MoveClause
FROM mapped
ORDER BY Type;

-- Example usage to assemble full RESTORE:
-- RESTORE DATABASE [MyDb] FROM DISK = 'C:\Backups\MyDb_20250101_010101_FULL.bak'
-- WITH REPLACE, RECOVERY,
--      <paste MoveClause rows separated by commas> ;