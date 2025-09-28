/*
03-quick-search-proc.sql
Creates a general-purpose search procedure that scans common columns or all nvarchar columns across tables.
*/

USE [SSUSToolkit];
GO

IF OBJECT_ID('dbo.usp_QuickSearch') IS NOT NULL
    DROP PROCEDURE dbo.usp_QuickSearch;
GO

CREATE PROCEDURE dbo.usp_QuickSearch
    @Search nvarchar(200),
    @Top int = 100,
    @Tables nvarchar(max) = NULL -- optional comma-separated list
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @like nvarchar(210) = N'%' + @Search + N'%';

    DECLARE @sql nvarchar(max) = N'';

    ;WITH t AS (
        SELECT s.name AS SchemaName, o.name AS TableName, c.name AS ColumnName
        FROM sys.objects o
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        JOIN sys.columns c ON c.object_id = o.object_id
        JOIN sys.types ty ON ty.user_type_id = c.user_type_id
        WHERE o.type = 'U'
          AND ty.name IN (N'nvarchar', N'varchar', N'nchar', N'char', N'text', N'ntext')
          AND (@Tables IS NULL OR CHARINDEX(',' + s.name + '.' + o.name + ',', ',' + @Tables + ',') > 0)
    )
    SELECT @sql = STRING_AGG(
        N'SELECT TOP(' + CAST(@Top AS nvarchar(10)) + N') ''' +
        t.SchemaName + N'.' + t.TableName + N''' AS [Table], ''' + t.ColumnName + N''' AS [Column], *
        FROM ' + QUOTENAME(t.SchemaName) + N'.' + QUOTENAME(t.TableName) +
        N' WITH (NOLOCK) WHERE ' + QUOTENAME(t.ColumnName) + N' LIKE @like',
        N' UNION ALL\n')
    FROM t;

    IF @sql IS NULL OR LEN(@sql) = 0
    BEGIN
        RAISERROR('No searchable columns found for the given table filter.', 11, 1);
        RETURN;
    END

    EXEC sp_executesql @sql, N'@like nvarchar(210)', @like=@like;
END
GO

PRINT 'dbo.usp_QuickSearch created.';