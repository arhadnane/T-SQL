-- ======================================================================================
-- Name: 03-encryption-compliance.sql
-- Description: Audits the encryption status of the database instance (TDE, SSL, Certificates).
-- ======================================================================================

SET NOCOUNT ON;

PRINT '--- [1] TDE STATUS ---';
SELECT 
    db.name AS DatabaseName, 
    encryption_state, 
    CASE encryption_state
        WHEN 0 THEN 'Not Encrypted'
        WHEN 1 THEN 'Encrypted'
        WHEN 2 THEN 'Encryption in Progress'
        WHEN 3 THEN 'Decryption in Progress'
        ELSE 'Unknown'
    END AS EncryptionStatus
FROM sys.dm_database_encryption_keys dek
JOIN sys.databases db ON dek.database_id = db.database_id;

PRINT '--- [2] SSL/TLS CONNECTION AUDIT ---';
SELECT 
    session_id, 
    net_transport, 
    encrypt_option, 
    auth_scheme
FROM sys.dm_exec_connections
WHERE encrypt_option = 0; -- Find non-encrypted connections

PRINT '--- [3] CERTIFICATE EXPIRY CHECK ---';
SELECT 
    name AS CertificateName, 
    expiry_date 
FROM sys.certificates
WHERE expiry_date << DATE DATEADD(day, 30, GETDATE());
GO
