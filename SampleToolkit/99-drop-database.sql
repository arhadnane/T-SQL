/*
99-drop-database.sql
Safely drops the SSUSToolkit database: puts it in SINGLE_USER with ROLLBACK IMMEDIATE,
switches context away if needed, and drops it with simple error handling.
*/

SET NOCOUNT ON;

DECLARE @DatabaseName sysname = N'SSUSToolkit';

IF DB_ID(@DatabaseName) IS NULL
BEGIN
    PRINT 'Database not found: ' + QUOTENAME(@DatabaseName);
    RETURN;
END

PRINT 'Setting database to SINGLE_USER WITH ROLLBACK IMMEDIATE...';
EXEC('ALTER DATABASE ' + QUOTENAME(@DatabaseName) + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');

-- If we are currently connected to the target DB, switch to master before DROP
IF DB_ID(@DatabaseName) = DB_ID()
BEGIN
    EXEC('USE master;');
END

BEGIN TRY
    PRINT 'Dropping database ' + QUOTENAME(@DatabaseName) + '...';
    EXEC('DROP DATABASE ' + QUOTENAME(@DatabaseName) + ';');
    PRINT 'Database dropped: ' + QUOTENAME(@DatabaseName) + '.';
END TRY
BEGIN CATCH
    DECLARE @ErrMsg nvarchar(4000) = ERROR_MESSAGE();
    PRINT 'Drop failed: ' + @ErrMsg;
    PRINT 'Attempting to revert database to MULTI_USER...';
    BEGIN TRY
        EXEC('ALTER DATABASE ' + QUOTENAME(@DatabaseName) + ' SET MULTI_USER;');
    END TRY
    BEGIN CATCH
        PRINT 'Revert to MULTI_USER also failed: ' + ERROR_MESSAGE();
    END CATCH
    THROW;
END CATCH