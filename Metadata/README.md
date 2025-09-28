# Metadata Scripts

Utility queries for exploring database schemas and objects.

- `ColumnsInfoWithRowNumber.sql` — List columns for all user tables with per-table row numbers, types, length/precision/scale, and optional filters.
- `tables-rowcounts.sql` — Row counts per table with heap/clustered indicator.
- `keys-constraints.sql` — Primary keys, unique constraints, and foreign keys with columns and mappings.
- `indexes-detail.sql` — Index keys and included columns with uniqueness and types.
- `dependencies.sql` — Dependencies between referencing and referenced objects.
- `column-search.sql` — Find columns by name pattern across schemas.
- `datatypes-usage.sql` — Frequency of data types and nullable counts.
- `identities-defaults.sql` — Identity columns and default constraints.
- `computed-columns.sql` — Computed columns with persistence and definitions.
- `collation-differences.sql` — Columns whose collation differs from DB default.

- `objects-modified.sql` — Recently created/modified user objects.
- `views-procedures.sql` — List views and stored procedures (optional definitions).
- `tables-without-pk.sql` — Tables that do not have a primary key.
- `nullable-columns-audit.sql` — Nullable columns per table with percentage.

- `wide-tables.sql` — Wide tables by column count and estimated row size.
- `constraints-trust-disabled.sql` — Disabled or not-trusted constraints (FK, CHECK).
- `synonyms-and-external-refs.sql` — Synonyms and modules referencing external sources.
