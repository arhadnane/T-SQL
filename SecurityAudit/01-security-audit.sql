/*
01-security-audit.sql
Purpose: Comprehensive security audit for SQL Server instance
Checklist: Logins, permissions, orphaned users, SQL Audit status
*/

-- ====== Server-level security summary ======
SELECT 
    'Server Logins' AS Category,
    COUNT(*) AS Count,
    SUM(CASE WHEN is_disabled = 0 THEN 1 ELSE 0 END) AS Active,
    SUM(CASE WHEN is_disabled = 1 THEN 1 ELSE 0 END) AS Disabled
FROM sys.sql_logins
WHERE sid != 0x01; -- Exclude sa

-- ====== Sysadmin members (highest privilege) ======
SELECT 
    'Sysadmin Members' AS Category,
    l.name AS LoginName,
    l.type_desc AS LoginType,
    l.is_disabled,
    l.create_date,
    l.modify_date
FROM sys.server_role_members rm
JOIN sys.server_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.server_principals l ON l.principal_id = rm.member_principal_id
WHERE r.name = 'sysadmin'
ORDER BY l.name;

-- ====== Logins with password policy off ======
SELECT 
    'Password Policy Off' AS Risk,
    name AS LoginName,
    type_desc AS LoginType,
    is_policy_checked,
    is_expiration_checked
FROM sys.sql_logins
WHERE is_policy_checked = 0
    AND sid != 0x01
    AND is_disabled = 0;

-- ====== Orphaned Windows logins ======
SELECT 
    'Orphaned Logins' AS Issue,
    name AS LoginName,
    type_desc AS LoginType,
    create_date
FROM sys.server_principals
WHERE type IN ('U', 'G')  -- Windows users/groups
    AND SID NOT IN (
        SELECT SID FROM sys.server_principals 
        WHERE type IN ('U', 'G')
    );

-- ====== Database-level orphaned users ======
EXEC sp_MSforeachdb '
USE [?];
SELECT 
    DB_NAME() AS DatabaseName,
    dp.name AS OrphanedUser,
    dp.type_desc AS UserType,
    dp.create_date
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.type IN (''S'', ''U'', ''G'')
    AND dp.principal_id > 4
    AND sp.sid IS NULL
    AND dp.name NOT IN (''public'', ''guest'', ''INFORMATION_SCHEMA'', ''sys'')
';

-- ====== Users with db_owner (per database) ======
EXEC sp_MSforeachdb '
USE [?];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''db_owner'')
SELECT 
    DB_NAME() AS DatabaseName,
    u.name AS UserName,
    u.type_desc AS UserType,
    r.name AS RoleName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
WHERE r.name = ''db_owner''
    AND u.name != ''dbo''
';

-- ====== SQL Server Audit status ======
SELECT 
    name AS AuditName,
    type_desc AS AuditType,
    status_desc AS Status,
    is_state_enabled,
    file_path AS AuditFilePath
FROM sys.server_file_audits
UNION ALL
SELECT 
    name,
    'SERVER AUDIT',
    status_desc,
    is_state_enabled,
    NULL
FROM sys.server_audits
WHERE type = 'SL'; -- Server-level audit

-- ====== Recent failed logins ======
/*
-- Requires SQL Server Error Log access
EXEC xp_readerrorlog 0, 1, N'Login failed';
*/

PRINT 'Security audit complete. Review results and address high-risk findings.';
