USE [YourDatabaseName]; -- Replace with your database name
GO

SET NOCOUNT ON;

-- Declare variables for iteration
DECLARE @object_id INT;
DECLARE @index_id INT;
DECLARE @partition_number INT;
DECLARE @index_name NVARCHAR(256);
DECLARE @schema_name NVARCHAR(256);
DECLARE @table_name NVARCHAR(256);
DECLARE @fragmentation FLOAT;

-- Temporary table to store index fragmentation details
IF OBJECT_ID('tempdb..#IndexStats') IS NOT NULL
    DROP TABLE #IndexStats;

CREATE TABLE #IndexStats (
    ObjectID INT,
    IndexID INT,
    PartitionNumber INT,
    IndexName NVARCHAR(256),
    SchemaName NVARCHAR(256),
    TableName NVARCHAR(256),
    Fragmentation FLOAT
);

-- Populate the temporary table with fragmentation data
INSERT INTO #IndexStats
SELECT 
    s.object_id AS ObjectID,
    s.index_id AS IndexID,
    s.partition_number AS PartitionNumber,
    i.name AS IndexName,
    sch.name AS SchemaName,
    o.name AS TableName,
    s.avg_fragmentation_in_percent AS Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') AS s
JOIN sys.indexes AS i
    ON s.object_id = i.object_id AND s.index_id = i.index_id
JOIN sys.objects AS o
    ON s.object_id = o.object_id
JOIN sys.schemas AS sch
    ON o.schema_id = sch.schema_id
WHERE i.type > 0 -- Only include non-heap indexes
    AND s.avg_fragmentation_in_percent > 5; -- Only fragmented indexes

-- Cursor to iterate through fragmented indexes
DECLARE IndexCursor CURSOR FOR
SELECT 
    ObjectID, IndexID, PartitionNumber, IndexName, SchemaName, TableName, Fragmentation
FROM #IndexStats;

OPEN IndexCursor;

FETCH NEXT FROM IndexCursor
INTO @object_id, @index_id, @partition_number, @index_name, @schema_name, @table_name, @fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processing Index: ' + @index_name + ' on Table: ' + @schema_name + '.' + @table_name + 
          ' (Fragmentation: ' + CAST(@fragmentation AS NVARCHAR(10)) + '%)';

    IF @fragmentation >= 30
    BEGIN
        PRINT 'Rebuilding index...';
        EXEC ('ALTER INDEX [' + @index_name + '] ON [' + @schema_name + '].[' + @table_name + '] REBUILD');
    END
    ELSE IF @fragmentation BETWEEN 5 AND 30
    BEGIN
        PRINT 'Reorganizing index...';
        EXEC ('ALTER INDEX [' + @index_name + '] ON [' + @schema_name + '].[' + @table_name + '] REORGANIZE');
    END

    FETCH NEXT FROM IndexCursor
    INTO @object_id, @index_id, @partition_number, @index_name, @schema_name, @table_name, @fragmentation;
END;

CLOSE IndexCursor;
DEALLOCATE IndexCursor;

-- Clean up
DROP TABLE #IndexStats;

PRINT 'Index maintenance completed.';
GO
