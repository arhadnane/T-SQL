/*
README.md - Additional Scripts
Contributeur: Aerix (Agent IA)
Date: 2026-04-04
Branche: feature/additional-scripts
*/

# Scripts Additionnels T-SQL

Ce dossier contient des scripts complémentaires pour des scénarios avancés SQL Server.

## 📁 Nouveaux Modules

### Partitioning/
Gestion de tables partitionnées pour grandes volumétries.
- `01-create-partition-function-scheme.sql` - Infrastructure de partitionnement mensuel
- `02-partitioned-orders-table.sql` - Table partitionnée exemple
- `03-switch-partition-out.sql` - Archivage par switching (metadata-only)

**Use case**: Tables > 10M lignes avec données historiques (logs, commandes, événements)

### InMemoryOLTP/
Tables optimisées en mémoire pour haute performance OLTP.
- `01-setup-inmemory-oltp.sql` - Configuration filegroup + tables
- `02-inmemory-vs-disk-comparison.sql` - Benchmark performance

**Use case**: Faible latence, haut débit transactionnel (10x-30x plus rapide)

### Columnstore/
Index columnstore pour workloads analytiques.
- `01-columnstore-index-setup.sql` - Création CCI/NCCI
- `02-columnstore-queries.sql` - Requêtes optimisées batch mode

**Use case**: Data warehouse, agrégations massives (10x-100x compression)

### ImplicitConversions/
Détection et correction des conversions implicites (killers de performance).
- `01-detect-implicit-conversions.sql` - Identification via Query Store
- `02-fix-common-implicit-conversions.sql` - Patterns et corrections

**Use case**: Optimisation requêtes lentes, index scan → index seek

### SecurityAudit/
Audit complet de sécurité SQL Server.
- `01-security-audit.sql` - Permissions, orphaned users, sysadmin

**Use case**: Revue sécurité, compliance, hardening

---

## 🎯 Matrice de Sélection

| Problème | Solution | Scripts |
|----------|----------|---------|
| Table trop grande, queries lentes sur anciennes données | Partitionnement | `Partitioning/` |
| Latence élevée, besoin throughput extrême | In-Memory OLTP | `InMemoryOLTP/` |
| Reporting lent sur gros volumes | Columnstore | `Columnstore/` |
| Index scans inexpliqués, queries lentes | Implicit Conversions | `ImplicitConversions/` |
| Audit sécurité, revue permissions | Security Audit | `SecurityAudit/` |

---

## ⚠️ Prérequis

| Feature | Version SQL Server | Édition |
|---------|-------------------|---------|
| Partitionnement | 2005+ | Toutes |
| In-Memory OLTP | 2016+ | Enterprise/Developer* |
| Columnstore | 2012+ | Enterprise/Developer* |
| Query Store | 2016+ | Toutes |

*Developer edition gratuite pour développement/tests

---

## 🔧 Intégration SampleToolkit

Les scripts utilisent la base `SSUSToolkit` créée par les scripts originaux.

```sql
-- Ordre d'exécution recommandé:
1. SampleToolkit/01-create-database.sql (original)
2. SampleToolkit/02-seed-data.sql (original)
3. Partitioning/01-create-partition-function-scheme.sql (nouveau)
4. Partitioning/02-partitioned-orders-table.sql (nouveau)
5. InMemoryOLTP/01-setup-inmemory-oltp.sql (nouveau)
-- etc.
```

---

## 📊 Benchmarks Attendus

| Scénario | Amélioration |
|----------|--------------|
| In-Memory vs Disk | 5x-30x plus rapide |
| Columnstore aggregations | 10x-100x plus rapide |
| Partition elimination | Scan 1 partition vs table entière |
| Fix implicit conversions | Index scan → Index seek |

---

*Généré par Aerix - Agent d'Intelligence Technologique*
*Architecture SQL Server avancée*
