# Recovery Scripts

Danger zone: many scripts affect database state. Review and test in non‑production first.

- `RepairDB.sql` — Emergency repair (data loss possible). Use as last resort.
- `backup-full-diff-log.sql` — Quick backup helpers (FULL/DIFF/LOG) to disk.
- `restore-script-generator.sql` — Generate RESTORE commands from a directory listing.
- `single-multi-user.sql` — Switch SINGLE_USER/MULTI_USER with rollback immediate.
- `offline-online.sql` — Set DB OFFLINE then ONLINE again.
- `suspect-databases.sql` — List SUSPECT and RECOVERY_PENDING databases.
- `checkdb-report.sql` — Run CHECKDB with detailed errors.
- `verify-backup.sql` — Validate a backup file with VERIFYONLY.
- `orphaned-users-fix.sql` — Map orphaned users to logins or prepare create/map commands.
- `backup-history.sql` — Recent backup history from msdb.

- `backup-header-filelist.sql` — Inspect backup metadata (HEADERONLY, FILELISTONLY).
- `restore-from-msdb-chain.sql` — Generate ordered restore commands from msdb history.
- `tail-log-backup.sql` — Take a tail-log backup before restore operations.

- `restore-with-move-helper.sql` — Suggest MOVE clauses by inspecting FILELIST and default paths.
- `log-chain-validator.sql` — Validate continuity of FULL/DIFF/LOG backups from msdb.

Notes:

- For `restore-script-generator.sql`, consider replacing xp_cmdshell listing with msdb history for tighter security.
- Always keep recent FULL and LOG backups if running in FULL recovery model.
- Review generated scripts before execution.
