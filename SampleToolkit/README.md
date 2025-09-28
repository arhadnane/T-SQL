# SSUS Sample T-SQL Toolkit

A lightweight, reusable starting point for learning and building SQL Server utilities. Designed for quick execution in SSMS.

## What you get

- Create a sample database with common tables (Customers, Products, Orders, OrderItems)
- Seed test data
- Quick search procedure for fuzzy lookups across text columns
- Simple audit table and triggers for change tracking

## Files

### Cleanup

- To remove the sample database, run `99-drop-database.sql`. It will:
  - Set the DB to SINGLE_USER with ROLLBACK IMMEDIATE
  - Switch context away if you’re connected to the DB
  - Drop the database with basic error handling

1. `01-create-database.sql` — Creates the `SSUSToolkit` database and tables.
2. `02-seed-data.sql` — Inserts sample data; safe to re-run.
3. `03-quick-search-proc.sql` — Creates `dbo.usp_QuickSearch` to search across tables.
4. `04-audit-objects.sql` — Creates `dbo.AuditLog` and triggers on key tables.
5. `05-find-objects.sql` — Search objects by name pattern across schemas and types.
6. `06-missing-indexes.sql` — Report missing index suggestions by impact.
7. `07-index-usage.sql` — Show seek/scan/lookup/update counts and last usage timestamps.
8. `08-table-sizes.sql` — Table row counts and storage usage in MB.
9. `09-active-requests.sql` — Current requests, waits, and blocking details.
10. `99-drop-database.sql` — Optional cleanup to drop the sample database.

## How to run (SSMS)

Run each script in order:

1. Open `01-create-database.sql` and execute.
2. Open `02-seed-data.sql` and execute.
3. Open `03-quick-search-proc.sql` and execute.
4. Open `04-audit-objects.sql` and execute.

## Try it

- Search for a term:

  ```sql
  USE SSUSToolkit;
  EXEC dbo.usp_QuickSearch @Search = N'Laptop';
  ```

- See the audit log:

  ```sql
  USE SSUSToolkit;
  UPDATE dbo.Products SET Price = Price + 10 WHERE SKU = 'SKU-001';
  SELECT TOP 50 * FROM dbo.AuditLog ORDER BY AuditID DESC;
  ```

## Notes

- Scripts are idempotent where reasonable.
- Modify database name via the variable at the top of each script.
- Triggers are illustrative and concatenate values; for production, consider JSON or XML with column-difference detection.
