# Maintenance Scripts

Practical maintenance and upkeep tasks.

- `IndexMaintenanceScript.sql` — Cursor-driven rebuild/reorganize for fragmented indexes.
- `fragmentation-report.sql` — Fragmentation with page counts for decision-making.
- `rebuild-reorganize-setbased.sql` — Generates ALTER INDEX commands set-based.
- `update-statistics.sql` — Update stats for all user tables (optional FULLSCAN).
- `integrity-check.sql` — DBCC CHECKDB helper.
- `unused-indexes.sql` — Potentially unused nonclustered indexes.

- `online-resumable-rebuild.sql` — Template for ONLINE/RESUMABLE rebuilds with low-priority wait.
- `per-table-index-maintenance.sql` — Generate index maintenance commands for one table.

- `update-stats-by-modcounter.sql` — Suggest UPDATE STATISTICS for tables with large modification ratio.
- `partition-aware-index-maintenance.sql` — REBUILD/REORGANIZE at the partition level.

Tips:

- Run heavy operations (rebuild, CHECKDB) in a maintenance window.
- Consider ONLINE=ON/RESUMABLE=ON for Enterprise editions where appropriate.
- Verify unused indexes over time before dropping; usage resets on restart.
