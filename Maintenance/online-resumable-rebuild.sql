/*
online-resumable-rebuild.sql
Template for online/resumable index rebuild (Enterprise) with MAXDOP and WAIT_AT_LOW_PRIORITY.
*/

DECLARE @Schema sysname = N'dbo';
DECLARE @Table  sysname = N'Orders';
DECLARE @Index  sysname = N'IX_Orders_Date';
DECLARE @MaxDOP int = 4;

DECLARE @cmd nvarchar(max) = N'ALTER INDEX ' + QUOTENAME(@Index) + ' ON ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) +
    ' REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = ' + CAST(@MaxDOP AS nvarchar(10)) + ', WAIT_AT_LOW_PRIORITY (MAX_DURATION = 30 MINUTES, ABORT_AFTER_WAIT = SELF));';

PRINT @cmd;
-- EXEC sp_executesql @cmd;