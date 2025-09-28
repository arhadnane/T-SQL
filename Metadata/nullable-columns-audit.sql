/*
nullable-columns-audit.sql
Lists nullable columns and percentage per table.
*/

;WITH cols AS (
    SELECT s.name AS SchemaName, t.name AS TableName, COUNT(*) AS TotalCols
    FROM sys.columns c
    JOIN sys.tables t ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    GROUP BY s.name, t.name
), nul AS (
    SELECT s.name AS SchemaName, t.name AS TableName, COUNT(*) AS NullableCols
    FROM sys.columns c
    JOIN sys.tables t ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE c.is_nullable = 1
    GROUP BY s.name, t.name
)
SELECT 
    c.SchemaName,
    c.TableName,
    c.TotalCols,
    ISNULL(n.NullableCols,0) AS NullableCols,
    CONVERT(decimal(5,2), 100.0 * ISNULL(n.NullableCols,0) / NULLIF(c.TotalCols,0)) AS NullablePct
FROM cols c
LEFT JOIN nul n ON n.SchemaName = c.SchemaName AND n.TableName = c.TableName
ORDER BY NullablePct DESC, c.SchemaName, c.TableName;