
--By Adnane ARHARBI
SELECT 
		c.Session_id
		,login_name
		,connect_time
		,login_time
		,client_net_address
		,client_tcp_port
		,local_net_address
		,local_tcp_port
		,host_name
		,program_name
		,host_process_id
		,status
		,cpu_time
		,last_read
		,last_write
		,last_request_start_time
		,last_request_end_time
		,T.text AS 'SQLQuery'
		,c.parent_connection_id
		,s.memory_usage
	
FROM
	sys.dm_exec_connections c
	INNER JOIN sys.dm_exec_sessions s on s.session_id=c.session_id
	CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS T
