/*
orphaned-users-fix.sql
Fix orphaned users by remapping to matching logins or recreating.
*/

-- Map users to existing logins by name
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql + 'ALTER USER ' + QUOTENAME(dp.name) + ' WITH LOGIN = ' + QUOTENAME(dp.name) + ';' + CHAR(10)
FROM sys.database_principals dp
WHERE dp.type IN ('S','U') AND dp.sid IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.sid = dp.sid);

PRINT @sql;
-- EXEC sp_executesql @sql; -- uncomment after review

-- For cases where login doesn’t exist, create and map (manual step recommended)
-- CREATE LOGIN [user] FROM WINDOWS; -- or CREATE LOGIN ... WITH PASSWORD = '...';
-- CREATE USER [user] FOR LOGIN [user];