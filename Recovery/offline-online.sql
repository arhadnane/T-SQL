/*
offline-online.sql
Set database OFFLINE and back ONLINE.
*/

DECLARE @DbName sysname = DB_NAME();

PRINT 'Setting OFFLINE for ' + @DbName;
EXEC('ALTER DATABASE ' + QUOTENAME(@DbName) + ' SET OFFLINE WITH ROLLBACK IMMEDIATE;');

PRINT 'Setting ONLINE for ' + @DbName;
EXEC('ALTER DATABASE ' + QUOTENAME(@DbName) + ' SET ONLINE;');