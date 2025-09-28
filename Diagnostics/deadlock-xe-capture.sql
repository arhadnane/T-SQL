/*
deadlock-xe-capture.sql
Creates (if not exists) and starts a lightweight Extended Events session to capture deadlock graphs.
Default target: ring_buffer. Optional event_file target is shown commented.
Run the "read captured deadlocks" section to view XML graphs.
*/

-- Create or start XE session
IF NOT EXISTS (
    SELECT 1 FROM sys.server_event_sessions WHERE name = N'CaptureDeadlocks'
)
BEGIN
    EXEC('CREATE EVENT SESSION [CaptureDeadlocks] ON SERVER 
        ADD EVENT sqlserver.xml_deadlock_report
        ADD TARGET package0.ring_buffer
        --, ADD TARGET package0.event_file(SET filename = N''C:\\XE\\deadlocks.xel'', max_file_size = (50), max_rollover_files = (4))
        WITH (STARTUP_STATE = OFF, MAX_MEMORY = 10 MB, TRACK_CAUSALITY = OFF);');
END

IF NOT EXISTS (
    SELECT 1 FROM sys.dm_xe_sessions WHERE name = N'CaptureDeadlocks'
)
BEGIN
    ALTER EVENT SESSION [CaptureDeadlocks] ON SERVER STATE = START;
END

PRINT 'Deadlock capture XE session is running (CaptureDeadlocks).';

/* Read captured deadlocks (ring_buffer target) */
;WITH rb AS (
    SELECT CAST(xet.target_data AS xml) AS x
    FROM sys.dm_xe_sessions xes
    JOIN sys.dm_xe_session_targets xet 
      ON xes.address = xet.event_session_address
    WHERE xes.name = N'CaptureDeadlocks'
      AND xet.target_name = N'ring_buffer'
)
SELECT TOP (50)
    xed.value('(event/@timestamp)[1]', 'datetime2') AS [utc_time],
    xed.value('(event/data/value/deadlock)[1]', 'xml') AS deadlock_graph
FROM rb
CROSS APPLY x.nodes('//RingBufferTarget/event') AS t(xed)
WHERE xed.value('(event/@name)[1]', 'nvarchar(100)') = N'xml_deadlock_report'
ORDER BY [utc_time] DESC;

/* Optional: Stop and drop the session when done */
-- ALTER EVENT SESSION [CaptureDeadlocks] ON SERVER STATE = STOP;
-- DROP EVENT SESSION [CaptureDeadlocks] ON SERVER;