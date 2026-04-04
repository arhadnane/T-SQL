# Observability

This directory contains tools for proactive monitoring and server health dashboards.

## Components
- `vw_ServerHealth.sql`: A unified view providing a snapshot of CPU, Memory, Blocking, and Backup status.
- `sp_CheckServerHealth.sql`: A stored procedure that outputs a JSON health report for integration with external monitoring tools.

## Usage
1. Run the scripts on the target database.
2. Query `SELECT * FROM dbo.vw_ServerHealth` for a quick check.
3. Execute `EXEC dbo.sp_CheckServerHealth` to get a machine-readable JSON report.
