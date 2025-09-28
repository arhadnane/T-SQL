/*
integrity-check.sql
Run DBCC CHECKDB; adjust options for larger DBs.
*/

-- Tip: Run this during low activity windows.
DBCC CHECKDB WITH NO_INFOMSGS, ALL_ERRORMSGS;