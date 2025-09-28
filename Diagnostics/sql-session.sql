/*
SQL-Session.sql
Purpose: Inspect current connections and last executed SQL per session.
*/

SELECT 
    c.Session_id,
    s.login_name,
    c.connect_time,
    s.login_time,
    c.client_net_address,
    c.client_tcp_port,
    c.local_net_address,
    c.local_tcp_port,
    s.host_name,
    s.program_name,
    s.host_process_id,
    s.status,
    s.cpu_time,
    s.last_read,
    s.last_write,
    s.last_request_start_time,
    s.last_request_end_time,
    T.text AS SQLQuery,
    c.parent_connection_id,
    s.memory_usage
FROM sys.dm_exec_connections c
JOIN sys.dm_exec_sessions s ON s.session_id = c.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS T;
