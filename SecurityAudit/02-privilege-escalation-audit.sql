-- ======================================================================================
-- Name: 02-privilege-escalation-audit.sql
-- Description: Detects users with excessive privileges (sysadmin, db_owner) 
-- and identifies potential privilege escalation vectors.
-- ======================================================================================

SET NOCOUNT ON;

PRINT '--- [1] SYSADMIN USERS ---';
SELECT 
    p.name AS UserName, 
    p.type_desc AS UserType, 
    p.create_date, 
    p.modify_date
FROM sys.server_principals p
WHERE p.is_fixed_role_member('sysadmin = 1')
ORDER BY p.name;

PRINT '--- [2] DATABASE OWNERS ---';
SELECT 
    p.name AS UserName, 
    p.type_desc AS UserType,
    'db_owner' AS Role
FROM sys.database_principals p
JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE r.name = 'db_owner';

PRINT '--- [3] UNMAPPED LOGINS ---';
SELECT 
    p.name AS OrphanedUser, 
    p.type_desc
FROM sys.database_principals p
LEFT JOIN sys.server_principals sp ON p.sid = sp.sid
WHERE sp.sid IS NULL 
AND p.type IN ('S', 'U', 'G') 
AND p.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys');
GO
