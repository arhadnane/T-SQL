/*
io-file-stats.sql
I/O stats per data/log file.
*/

SELECT 
    DB_NAME(mf.database_id) AS DatabaseName,
    mf.type_desc AS FileType,
    mf.name AS LogicalName,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    (vfs.size_on_disk_bytes/1024.0/1024.0) AS SizeOnDiskMB
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
JOIN sys.master_files mf
  ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY (vfs.io_stall_read_ms + vfs.io_stall_write_ms) DESC;