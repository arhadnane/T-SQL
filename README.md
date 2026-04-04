# T-SQL Utilities

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2016%2B-blue)](https://www.microsoft.com/sql-server)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintenance-Active-brightgreen)](https://github.com/arhadnane/T-SQL)

## 📋 Overview

A curated collection of T-SQL scripts for database maintenance, optimization, diagnostics, and advanced scenarios. Designed for DBAs, developers, and architects working with SQL Server.

**Key Features:**
- Production-ready scripts with safety checks
- Comprehensive documentation and examples
- Sample database for testing and learning
- Advanced features: Partitioning, In-Memory OLTP, Columnstore
- Security audit and compliance tools

---

## 🗂️ Repository Structure

```
T-SQL/
├── Analysis/           📊 KPIs, descriptive statistics, reporting
├── Columnstore/        📦 Clustered/non-clustered columnstore indexes
├── Diagnostics/        🔍 Performance monitoring, troubleshooting
├── ImplicitConversions/⚡ Detect and fix implicit conversions
├── InMemoryOLTP/       ⚡ Memory-optimized tables (Hekaton)
├── Maintenance/        🔧 Index maintenance, upkeep tasks
├── Metadata/           📋 Schema exploration, object discovery
├── Partitioning/        📁 Table partitioning, archiving
├── Recovery/           🚨 Backup, restore, emergency repair
├── SampleToolkit/      🎓 Self-contained demo database
└── SecurityAudit/      🔒 Security auditing, permissions
```

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/arhadnane/T-SQL.git
cd T-SQL
```

### 2. Set Up Sample Database

```sql
-- Run in order:
SampleToolkit/01-create-database.sql      -- Creates SSUSToolkit database
SampleToolkit/02-seed-data.sql            -- Populates sample data
SampleToolkit/03-quick-search-proc.sql    -- Creates search procedure
SampleToolkit/04-audit-objects.sql        -- Sets up auditing
```

### 3. Try It Out

```sql
USE SSUSToolkit;

-- Quick search across all tables
EXEC dbo.usp_QuickSearch @Search = N'Laptop';

-- View audit trail
SELECT TOP 20 * FROM dbo.AuditLog ORDER BY AuditID DESC;

-- Check index usage
-- Open and run SampleToolkit/07-index-usage.sql in SSMS
-- Or, in SQLCMD mode, include it with:
-- :r SampleToolkit/07-index-usage.sql
```

---

## 📊 SQL Server Version Compatibility Matrix

### Core Scripts (All Editions)

| Module | SQL 2012 | SQL 2014 | SQL 2016 | SQL 2017 | SQL 2019 | SQL 2022 | Notes |
|--------|----------|----------|----------|----------|----------|----------|-------|
| **Analysis** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Standard T-SQL |
| **Maintenance** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Index maintenance |
| **Metadata** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | System views |
| **Recovery** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Backup/restore |
| **SampleToolkit** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Compatibility mode 110+ |
| **SecurityAudit** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Server permissions |

### Advanced Features (Enterprise/Developer Editions)

| Module | SQL 2012 | SQL 2014 | SQL 2016 | SQL 2017 | SQL 2019 | SQL 2022 | Notes |
|--------|----------|----------|----------|----------|----------|----------|-------|
| **Columnstore** | ⚠️ NCCI | ✅ CCI | ✅ CCI | ✅ CCI | ✅ CCI | ✅ CCI | Batch mode improvements over versions |
| **InMemoryOLTP** | ❌ | ⚠️ 2014 | ✅ | ✅ | ✅ | ✅ | Requires memory-optimized filegroup |
| **Partitioning** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Switch partition available all versions |
| **ImplicitConversions** | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ✅ | Query Store requires 2016+ |

### Feature Availability Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully supported |
| ⚠️ | Partial support / Limited features |
| ❌ | Not supported |

### Edition Requirements

| Feature | Express | Standard | Enterprise | Developer |
|---------|---------|----------|------------|-----------|
| **Partitioning** | ✅ | ✅ | ✅ | ✅ | All editions |
| **Columnstore** | ❌ | ✅ | ✅ | ✅ | Enterprise only (Standard limited) |
| **In-Memory OLTP** | ❌ | ❌ | ✅ | ✅ | Enterprise only |
| **Query Store** | ✅ | ✅ | ✅ | ✅ | All editions (2016+) |
| **Extended Events** | ✅ | ✅ | ✅ | ✅ | All editions |

---

## 🎯 Use Cases by Module

### 🔧 Maintenance & Monitoring
- **Index Maintenance** → Fragmentation detection and rebuild/reorganize
- **Diagnostics** → Active requests, wait stats, memory grants
- **Security Audit** → Orphaned users, permissions review

### ⚡ Performance Optimization
- **Implicit Conversions** → Find queries causing index scans
- **Columnstore** → Analytical workloads, aggregations
- **In-Memory OLTP** → High-throughput OLTP, low latency

### 📁 Data Management
- **Partitioning** → Large tables, sliding window archiving
- **Recovery** → Backup strategies, point-in-time restore
- **SampleToolkit** → Learning, demos, testing

---

## 🛡️ Safety Guidelines

⚠️ **Always test in development first!**

### High-Risk Scripts (Review Carefully)
| Script | Risk Level | Precaution |
|--------|------------|------------|
| `Recovery/repair-db.sql` | 🔴 Critical | `REPAIR_ALLOW_DATA_LOSS` may lose data |
| `Recovery/restore-*.sql` | 🟡 Medium | Verify backup chains before restore |
| `Maintenance/index-maintenance.sql` | 🟢 Low | Test impact on production during low traffic |
| `InMemoryOLTP/*.sql` | 🟡 Medium | Ensure sufficient RAM (2x table size) |

### Recommended Workflow
1. Read script header comments
2. Review in SSMS with "Parse" (Ctrl+F5)
3. Execute in dev/staging environment
4. Monitor with `SET STATISTICS IO/TIME ON`
5. Deploy to production during maintenance windows

---

## 📈 Performance Benchmarks

| Scenario | Improvement | Scripts |
|----------|-------------|---------|
| In-Memory vs Disk | 5x-30x | `InMemoryOLTP/02-inmemory-vs-disk-comparison.sql` |
| Columnstore Aggregations | 10x-100x | `Columnstore/02-columnstore-queries.sql` |
| Partition Elimination | Scan 1 partition vs full table | `Partitioning/02-partitioned-orders-table.sql` |
| Fix Implicit Conversions | Index Scan → Index Seek | `ImplicitConversions/01-detect-implicit-conversions.sql` |

---

## 🔧 Prerequisites

### Minimum Requirements
- **SQL Server**: 2012 SP4 or later
- **Permissions**: `VIEW SERVER STATE` for diagnostics
- **SSMS**: 2016+ recommended (for IntelliSense)

### For Advanced Features
- **RAM**: 8GB+ (16GB+ for In-Memory OLTP)
- **Disk**: SSD recommended for tempdb and data files
- **Edition**: Enterprise/Developer for Columnstore/In-Memory

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

**Contribution Guidelines:**
- Include header comments with purpose and usage
- Test on multiple SQL Server versions when possible
- Follow existing naming conventions
- Update compatibility matrix for new features

---

## 📚 Resources

- [SQL Server Documentation](https://docs.microsoft.com/sql/)
- [Query Store Best Practices](https://docs.microsoft.com/sql/relational-databases/performance/best-practice-with-the-query-store)
- [In-Memory OLTP Guidelines](https://docs.microsoft.com/sql/relational-databases/in-memory-oltp/)
- [Columnstore Index Overview](https://docs.microsoft.com/sql/relational-databases/indexes/columnstore-indexes-overview)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Author**: Adnane Arharbi
- **Contributors**: Aerix (AI Agent) - Advanced scripts
- **Community**: DBA Stack Exchange, SQL Server Central

---

*Last Updated: 2026-04-04*

*For questions or issues, please open a GitHub issue.*
