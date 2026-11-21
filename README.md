# A34Build_DB: Construction Enterprise Database

This repository holds the full database design and implementation for **A34Build**, a construction company that runs many projects at the same time. It was built by Team 5 for the **Database [E24-Class 5]** course at PTIT.

Use this page as a quick map to see what the project covers, how each phase was built, and which file to open for details.

| Item | Summary |
| :--- | :--- |
| Target DBMS | MySQL 8.0+ (`InnoDB`, `utf8mb4_unicode_ci`) |
| Schema Size | 29 tables in `3NF` across 6 business areas (15 indexes) |
| Logic & Rules | 7 business rules enforced by 14 `TRIGGER` objects |
| Sample Data & Queries | Seed data for all 29 tables, 10 queries and reports, 1 verification script |
| Team 5 | Lê Anh Minh (`B24DCCE180`), Ứng Trọng Trình (`B24DCCE271`), Nguyễn Đinh Anh Quân (`B24DCCE222`) |

---

## 1. System Overview

The database replaces spreadsheets and paper logs for a multi-project contractor. It tracks six main business areas inside `A34Build_DB`:

| Area | Tables | What It Tracks |
| :--- | :---: | :--- |
| Organization & HR | 5 | Departments, staff hierarchy, phones, certificates, dependents |
| Project Management & WBS | 8 | Clients, projects, job sites, phases, tasks, task dependencies, work hours |
| Heavy Machinery & Maintenance | 3 | Equipment fleet, maintenance logs, site deployments, operators |
| Procurement & Site Inventory | 9 | Suppliers, materials, purchase orders, deliveries, site stock, usage |
| Trade Subcontractors | 2 | External contractors, contracts, warranty holdback rates |
| Health, Safety & Environment (HSE) | 2 | Safety inspections, safety scores, workplace incident reports |

Notes:
- Full table columns, `FD` sets, and `3NF` checks are in [docs/phase3/report.md](docs/phase3/report.md) (§2.2) and [sql/01_schema_ddl.sql](sql/01_schema_ddl.sql).
- In [sql/01_schema_ddl.sql](sql/01_schema_ddl.sql), Subcontractors and HSE share one SQL comment block, while the reports list them separately.

---

## 2. Project Lifecycle by Phase

The work follows the four phases defined in [academic/asignment.pdf](academic/asignment.pdf):

| Phase | Goal | Key Output in This Repo | Main Files |
| :--- | :--- | :--- | :--- |
| Phase 1 | Form team and get assigned topic | Topic 5: Construction company with multiple projects | [teams-topic.pdf](academic/teams-topic.pdf) |
| Phase 2 | Requirements, conceptual design, initial logical mapping | 17 entity sets (13 strong, 4 weak), 30 relationships, 7 non-ERD rules, initial relational schema | [Phase 2 Report](docs/phase2/report.md), [Phase 2 PDF](docs/phase2/latex/report.pdf), [erd.pdf](docs/phase2/erd/erd.pdf), [schema.pdf](docs/phase2/schema/schema.pdf) |
| Phase 3 | Normalization (`3NF`) and physical MySQL build | Fixed `2NF` defect in `EQUIPMENT_DEPLOYMENT` and `3NF` defect in `DELIVERY_DISPATCH`; wrote DDL, triggers, DML, queries, and test proofs | [Phase 3 Report](docs/phase3/report.md), [Phase 3 PDF](docs/phase3/latex/report.pdf), [schema-3nf.pdf](docs/phase3/schema-3nf/schema-3nf.pdf), [sql/](sql/) |
| Phase 4 | In-class system demo and Q&A | Run SQL scripts live and walk through schemas, rules, and reports | [sql/](sql/), [Phase 3 Report](docs/phase3/report.md) |

---

## 3. Repository Structure

```text
Database_Project/
├── .agents/               # AI rules, subagents, and workflow skills
├── academic/
│   ├── books/             # 3 database textbooks
│   ├── slide/             # 6 lecture slide PDFs
│   ├── asignment.pdf      # Course brief and grading rules
│   └── teams-topic.pdf    # Team list and assigned topics
├── docs/
│   ├── phase2/
│   │   ├── erd/           # Chen ERD (.drawio, .png, .pdf)
│   │   ├── schema/        # Initial relational schema (.drawio, .png, .pdf)
│   │   ├── latex/         # Pandoc/XeLaTeX files and Phase 2 report.pdf
│   │   └── report.md      # Phase 2 report source
│   └── phase3/
│       ├── schema-3nf/    # Final 3NF schema (.drawio, .png, .pdf)
│       ├── media/         # 23 MySQL Workbench screenshots
│       ├── latex/         # Pandoc/XeLaTeX files and Phase 3 report.pdf
│       └── report.md      # Phase 3 report source
└── sql/
    ├── 01_schema_ddl.sql              # DDL: 29 tables, constraints, 15 indexes
    ├── 02_triggers_procedures.sql     # 14 triggers for Business Rules 1 to 7
    ├── 03_sample_data_dml.sql         # Sample data for all 29 tables
    ├── 04_business_queries.sql        # 4 operational queries, 4 management reports
    ├── 05_user_queries.sql            # 2 multi-table user queries
    ├── 06_rule_verification_tests.sql # Verification queries and negative tests
    └── SQL_workbench.mwb              # MySQL Workbench EER model
```

---

## 4. Quick Start: Running the Database

Execute the SQL scripts in order inside **MySQL 8.0+** (command line or MySQL Workbench). `01_schema_ddl.sql` drops and recreates `A34Build_DB`, so the sequence is safe to re-run from scratch:

1. [sql/01_schema_ddl.sql](sql/01_schema_ddl.sql): build tables, `PK`/`FK`/`CHECK`/`UNIQUE` constraints, and indexes.
2. [sql/02_triggers_procedures.sql](sql/02_triggers_procedures.sql): register the 14 business rule triggers.
3. [sql/03_sample_data_dml.sql](sql/03_sample_data_dml.sql): populate sample data across all 29 tables.
4. [sql/04_business_queries.sql](sql/04_business_queries.sql) and [sql/05_user_queries.sql](sql/05_user_queries.sql): run operational queries, recursive `CTE` hierarchy checks, and `EVM`/cost reports.
5. [sql/06_rule_verification_tests.sql](sql/06_rule_verification_tests.sql): verify Rules 1 to 7. Run the `SELECT` checks together, then run each invalid `INSERT` or `UPDATE` test one by one to observe `Error 1644 (SQLSTATE '45000')`.

---

## 5. Workspace AI Agents

The `.agents/` folder also stores two specialized AI agents built for this project:

| Agent | Role | Definition |
| :--- | :--- | :--- |
| `db-architect` | Designs `ERD` and `3NF` schemas, writes MySQL scripts, and audits doc-SQL sync | [agent.md](.agents/agents/db-architect/agent.md) |
| `db-academic-mentor` | Read-only tutor for theory Q&A, schema review, and Phase 4 demo prep | [agent.md](.agents/agents/db-academic-mentor/agent.md) |
