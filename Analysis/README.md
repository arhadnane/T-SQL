# Analysis Scripts

KPI and descriptive stats for the SampleToolkit database (`SSUSToolkit`). Run the SampleToolkit creators first.

- `descriptive-stats.sql` — Counts, min/max/avg/stdev, median/percentiles for products and orders; customers per region.
- `sales-kpis.sql` — Total revenue, AOV, items per order, active customers, and active days.
- `order-value-distribution.sql` — Histogram buckets and percentile cutpoints.

Notes:

- These scripts use `PERCENTILE_CONT`, available in modern SQL Server versions.
- If your `SSUSToolkit` has only seed data, results are small but useful as examples.
