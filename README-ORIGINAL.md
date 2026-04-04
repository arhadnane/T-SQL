# T-SQL
# SQL Utilities Project

## Overview
This project contains a collection of SQL scripts designed for various database maintenance, optimization, and analysis tasks. Each script serves a specific purpose, ranging from index maintenance to performance tuning, data cleanup, and reporting...

### Structure

- `Metadata/` — schema and object exploration queries (e.g., ColumnsInfoWithRowNumber)
- `Maintenance/` — upkeep tasks such as index maintenance
- `Diagnostics/` — monitoring and troubleshooting (sessions, active requests)
- `Recovery/` — high-risk repair or recovery helpers
- `Analysis/` — KPI and descriptive stats over the SampleToolkit data
- `SampleToolkit/` — a self-contained sample database with utilities

## Getting Started

1. Clone or download the repository.
2. Navigate to the folder corresponding to the task you want to perform.
3. Open the SQL file in a SQL Server Management Studio (SSMS) or another database client.
4. Execute the script against the appropriate database.

### New: Sample Toolkit for SSMS

For a lightweight, reusable starting point, see `SampleToolkit/`:

1. Run `SampleToolkit/01-create-database.sql`
2. Run `SampleToolkit/02-seed-data.sql`
3. Run `SampleToolkit/03-quick-search-proc.sql`
4. Run `SampleToolkit/04-audit-objects.sql`

Then try:

```sql
USE SSUSToolkit;
EXEC dbo.usp_QuickSearch @Search = N'Laptop';
SELECT TOP 20 * FROM dbo.AuditLog ORDER BY AuditID DESC;
```

## Prerequisites

- SQL Server (or the appropriate database management system for your environment)
- Permissions to execute scripts on the database
- A backup of your database is highly recommended before running any script

## Notes

- Each script is designed for SQL Server, but you may need to modify them for other database systems (e.g., MySQL, PostgreSQL).
- Always test scripts in a development environment before executing them in production.

## Contributing

Feel free to contribute by adding new SQL scripts or improving existing ones. Please follow these guidelines:

1. Fork the repository.
2. Create a branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License.
