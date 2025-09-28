/*
RepairDB.sql
Purpose: Attempt emergency repair on user databases (data loss possible!).
Notes: Use only as last resort. Consider backups and restore first.
*/

DECLARE @table nvarchar(50);
DECLARE @cnt int = 0;
DECLARE @i int = 1;
DECLARE @DatabaseName sysname;
DECLARE @sql nvarchar(2000);

SELECT @cnt = COUNT(d.database_id)
FROM master.sys.databases d
WHERE d.database_id > 4; -- user DBs only

WHILE (@i <= @cnt)
BEGIN
    SELECT TOP 1 @DatabaseName = d.name
    FROM master.sys.databases d
    WHERE d.database_id > 5 AND d.database_id = @i + 4;

    IF (@DatabaseName IS NOT NULL AND @DatabaseName <> '')
    BEGIN
        SET @table = @DatabaseName;
        SET @sql = 'ALTER DATABASE ' + QUOTENAME(@table) + ' SET EMERGENCY; ' +
                   'ALTER DATABASE ' + QUOTENAME(@table) + ' SET SINGLE_USER; ' +
                   'DBCC CHECKDB (' + QUOTENAME(@table) + ', REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS; ' +
                   'ALTER DATABASE ' + QUOTENAME(@table) + ' SET MULTI_USER;';
        EXEC sp_executesql @sql;
    END

    SET @i = @i + 1;
END
