/*
checkdb-report.sql
Run DBCC CHECKDB for current DB and output messages.
*/

DBCC CHECKDB WITH NO_INFOMSGS, ALL_ERRORMSGS;