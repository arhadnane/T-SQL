# Diagnostics Scripts

Quick, actionable diagnostics for SQL Server.

- `SQL-Session.sql` — Current sessions with last SQL per session.
- `active-requests.sql` — Active requests with waits, blocking, and current statement.
- `blocking-tree.sql` — Recursive view of blocking chains.
- `long-running-queries.sql` — Requests exceeding a configurable duration.
- `top-cpu-queries.sql` — Top cached queries by total CPU.
- `wait-stats.sql` — Server-level waits excluding benign categories.
- `tempdb-usage.sql` — Per-session tempdb allocation usage.
- `io-file-stats.sql` — I/O statistics per data/log file.
- `memory-grants.sql` — Current and pending memory grants.
- `adhoc-plan-cache-bloat.sql` — Single-use ad-hoc plan bloat detector.
- `query-store-regressions.sql` — Requires Query Store; highlights regressions.

- `deadlock-xe-capture.sql` — Create/start XE session for deadlock graphs; includes a reader.
- `top-memory-consumers.sql` — Top memory clerks and sessions by memory usage.
- `parallelism-skew.sql` — Active parallel requests with task-to-DOP ratio.
- `latch-hotspots.sql` — Latch stats plus page latch waits summary.

Tip: Many scripts support simple parameters at the top (e.g., @MinSeconds, @DatabaseName). Open in SSMS, adjust, and execute.
