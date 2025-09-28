/*
datatypes-usage.sql
Frequency of data types used across user tables.
*/

SELECT 
    ty.name AS DataType,
    COUNT(*) AS ColumnCount,
    SUM(CASE WHEN c.is_nullable = 1 THEN 1 ELSE 0 END) AS NullableCount
FROM sys.columns c
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
JOIN sys.tables t ON t.object_id = c.object_id
GROUP BY ty.name
ORDER BY ColumnCount DESC, ty.name;