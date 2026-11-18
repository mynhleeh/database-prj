---
trigger: glob
globs: "**/*.sql, **/*.drawio, **/*.mwb, **/*.md"
description: "Database engineering standards for A34Build: Chen EER fidelity, 3NF normalization proofs, MySQL 8.0+ DDL/Trigger discipline, exact DECIMAL arithmetic, and SQL verification."
---

# 03. Database Design & MySQL Implementation Standards

This rule governs conceptual modeling (ER/EER), logical normalization (3NF), and physical MySQL 8.0+ SQL implementation across the A34Build project.

## 1. Conceptual & Logical Modeling Discipline (Elmasri & Navathe)

1. **Chen ER/EER Fidelity:**
   - Distinguish Strong Entities vs. Weak Entities (identifying owner, identifying relationship, partial key discriminator).
   - Distinguish Simple, Composite (decomposed in relational mapping), Multi-valued (mapped to separate 1:N tables), and Derived attributes (never stored redundantly unless explicitly justified as cached/denormalized ledger fields).
   - Document exact Cardinality Ratios (`1:1`, `1:N`, `M:N`, ternary/aggregation) and Participation Constraints (`Total` vs. `Partial`) in the relationship matrix.
2. **Normalization Analysis (1NF -> 2NF -> 3NF):**
   - Every table specification must declare: (a) Relational Schema with underlined PK, (b) non-trivial Functional Dependencies ($F$), (c) all Candidate Keys (PK + Alternate Keys), (d) Prime vs. Non-Prime attributes, and (e) step-by-step evaluation through 1NF, 2NF (no partial dependencies on proper subsets of any CK), and 3NF (no transitive dependencies of non-prime attributes on any CK).
   - Decompositions must preserve **Lossless Join** and **Dependency Preservation** (such as composite-key refinement for 2NF on deployment intervals or eliminating transitive vendor FKs for 3NF on delivery dispatches).

## 2. Physical MySQL 8.0+ Implementation Standards

1. **Engine & Character Encoding:**
   - Use `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci` on all tables to guarantee ACID transactions, foreign key enforcement, and full Vietnamese Unicode support.
2. **Exact Arithmetic & Domain Types:**
   - Use `DECIMAL(p, s)` for all monetary values (`Budget`, `Salary`, `EstimatedBudget`, `ActualCost`, `HourlyRate`, `StandardPrice`, `UnitPrice`, `ContractValue`), percentages (`ProgressPercentage`, `WarrantyHoldRate`, `OverallScore`), quantities (`OrderQuantity`, `UsedQuantity`, `DeliveredQuantity`, `CurrentStockQuantity`), and logged hours (`HoursLogged`, `OperatingHours`, `TotalRunHours`). Strictly forbid `FLOAT` or `DOUBLE` for financial or inventory quantities.
   - Use `DATE` / `DATETIME` with explicit `CHECK` constraints for chronological invariants (`ScheduledEndDate >= StartDate`, `HireDate >= DOB`, `EndDate >= StartDate`).
3. **Constraint, Index & Trigger Naming Contract:**
   - Maintain uniform prefixes across DDL and trigger scripts:
     - Primary Key: `PK_<TABLE>`
     - Foreign Key: `FK_<TABLE>_<ColumnOrRole>`
     - Unique: `UQ_<TABLE>_<ColumnOrScope>`
     - Check: `CK_<TABLE>_<Rule>`
     - Index: `IDX_<TABLE>_<ColumnOrScope>`
     - Trigger: `TRG_<ACTION>_<RULE_SUMMARY>`
4. **Referential Integrity & Circular Dependencies:**
   - Choose explicit `ON UPDATE` and `ON DELETE` actions (`CASCADE` for weak entities and multivalued attribute tables; `RESTRICT` for operational parent records with history; `SET NULL` for optional links such as supervisor or department head references).
   - Resolve mutual cycles (e.g., `DEPARTMENT` head reference <-> `EMPLOYEE` department reference) by creating the table with a nullable FK first and adding the closing FK via deferred `ALTER TABLE`.
5. **Trigger & Stored Program Discipline:**
   - Use `SIGNAL SQLSTATE '45000'` with explicit rule-numbered messages (`'Rule N Violation: ...'`) so enforcement errors are testable and unambiguous.
   - Enforce invariant triggers symmetrically on both `BEFORE INSERT` and `BEFORE UPDATE` (excluding the current row via PK inequality on `UPDATE` so updates do not false-trigger against themselves).
   - Watch MySQL 8.0 constraints explicitly (e.g., Error 3823 forbids `CHECK` constraints referencing columns used in FK referential actions on recursive precedence tables; enforce self-loop prevention in the trigger alongside `WITH RECURSIVE` cycle detection).
   - Keep DDL, trigger, seed DML, and query scripts strictly re-runnable in sequence (`DROP DATABASE IF EXISTS ...` / `DROP TRIGGER IF EXISTS ...`).

## 3. SQL Verification Matrix (Evidence Required)

Before claiming any schema, trigger, or query change is complete, verify across 5 categories:
1. **Clean Sequential Execution:** Full sequential run from schema DDL through triggers, seed DML, and all query scripts completes with 0 SQL errors.
2. **Boundary & Precision:** Exact boundary inputs pass or reject as specified (e.g., daily hours totaling `12.00` pass; `12.01` rejected; `DECIMAL` totals without floating-point drift).
3. **Constraint & FK Rejections:** Invalid domain values (`CHECK`), duplicate alternate keys (`UNIQUE`), and invalid parent references (`FK RESTRICT`) fail cleanly.
4. **Trigger Enforcement & Bypass Audit:** Every enforced business rule trigger has at least one negative test case triggering `SQLSTATE '45000'` on `INSERT` and is checked for `UPDATE`/`DELETE` bypass gaps.
5. **Cross-Artifact Parity:** Table names, column names, PKs, FKs, and rule numbering in SQL match normalization specs, Draw.io schemas, and submitted report tables 100%.
