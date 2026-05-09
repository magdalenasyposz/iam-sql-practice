# IAM SQL Practice 

A hands-on SQL Server project simulating a real environment at a financial institution. Built to practice SQL for recruitment tests and IAM analyst roles.

## What's Inside

### Database Schema
A realistic IAM data model covering:
- **Employees** — identities with status (Active / Terminated / Inactive) and employment type
- **Departments** — org structure with manager relationships
- **Applications** — systems like Active Directory, Core Banking, Trading Platform, SAP
- **Roles** — RBAC roles per application, with privileged flag
- **Permissions** — granular entitlements mapped to roles
- **UserRoles** — who has what access and when it was granted
- **AccessRequests** — joiner/mover/leaver request workflow with approval trail
- **AuditLog** — immutable record of login events and access changes
- **SoDConflicts** — Segregation of Duties conflict rules

### Practice Query Modules

| File | Topics |
|---|---|
| `01_basic_queries.sql` | SELECT, WHERE, ORDER BY, IN, BETWEEN, IS NULL |
| `02_joins.sql` | INNER, LEFT, RIGHT, FULL OUTER JOIN, self-join |
| `03_aggregations.sql` | GROUP BY, HAVING, COUNT, SUM, AVG, STRING_AGG |
| `04_subqueries_ctes.sql` | Subqueries, EXISTS, NOT EXISTS, CTEs, chained CTEs |
| `05_window_functions.sql` | ROW_NUMBER, RANK, LAG/LEAD, NTILE, running totals |
| `06_advanced_iam_reports.sql` | Real IAM analyst reports (see below) |

### Advanced IAM Reports (Module 6)
Real queries an IAM analyst runs day-to-day:
1. **Access Certification Report** — quarterly review: certify, review, or revoke
2. **Privilege Creep Detection** — risk-scored user access profiles
3. **Self-Approval Detection** — control violation: requestedBy = approvedBy
4. **SoD Violation Report** — users holding conflicting role pairs
5. **External IP Login Detection** — logins from outside corporate network
6. **Joiner/Mover/Leaver Lifecycle** — provisioning hygiene metrics

## Setup

### Prerequisites
- Docker Desktop
- VS Code with the [SQL Server (mssql) extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql)

### Run SQL Server locally
```bash
# Start (first time)
docker run -e "ACCEPT_EULA=1" -e "MSSQL_SA_PASSWORD=SqlPractice123!" \
  -p 1433:1433 --name sqlserver --hostname sqlserver \
  -d mcr.microsoft.com/azure-sql-edge

# Start after reboot
docker start sqlserver
```

### Connect in VS Code
| Field | Value |
|---|---|
| Server | `localhost` |
| Authentication | SQL Login |
| Username | `sa` |
| Password | `SqlPractice123!` |

### Load the database
Run scripts in order:
1. `schema/01_create_tables.sql`
2. `data/02_seed_data.sql`
3. Run any query from `queries/`

## Key IAM Concepts Practiced

| Concept | Where in project |
|---|---|
| RBAC (Role-Based Access Control) | Roles, RolePermissions, UserRoles tables |
| Least Privilege | Module 6 — privilege creep detection |
| Segregation of Duties | SoDConflicts table, Module 6 report |
| Access Certification | Module 6 — certification report |
| Joiner/Mover/Leaver | AccessRequests table, Module 6 lifecycle query |
| Orphaned Accounts | Module 1 Q6, Module 4 CTEs |
| Privileged Access | IsPrivileged flag, Module 6 risk scoring |
| Audit Trail | AuditLog table, Module 6 external IP detection |

## Intentional Findings in the Data
The seed data contains realistic IAM issues to find and remediate:
- Terminated employee (Lidia) with active CBS Teller access
- Contractor (Barbara) with AD Admin + CBS Admin — over-provisioned
- SoD violation: HR employee (Dominika) holds Finance GL Posting role
- Self-approved access request by IT Manager
- Login from external IP by terminated employee

---
*Built for ING Hubs IAM recruitment preparation | SQL Server (Azure SQL Edge)*
