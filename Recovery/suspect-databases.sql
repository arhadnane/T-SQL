/*
suspect-databases.sql
List databases in suspect or recovery_pending state.
*/

SELECT name, state_desc, user_access_desc, recovery_model_desc
FROM sys.databases
WHERE state_desc IN ('SUSPECT','RECOVERY_PENDING')
ORDER BY name;