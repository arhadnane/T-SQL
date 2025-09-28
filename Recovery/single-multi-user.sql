/*
single-multi-user.sql
Switch database between SINGLE_USER and MULTI_USER with rollback immediate.
*/

DECLARE @DbName sysname = DB_NAME();

PRINT 'Setting SINGLE_USER for ' + @DbName;
EXEC('ALTER DATABASE ' + QUOTENAME(@DbName) + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');

PRINT 'Setting MULTI_USER for ' + @DbName;
EXEC('ALTER DATABASE ' + QUOTENAME(@DbName) + ' SET MULTI_USER;');