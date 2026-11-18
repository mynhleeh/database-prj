---
trigger: always_on
description: "Role-based 4-tier academic and domain grounding hierarchy discovered dynamically at session start (no hardcoded file paths), plus read-only protection for academic and textbook tiers."
---

# 01. Academic & Domain Knowledge Grounding

All analyses, ERD designs, normalization proofs, SQL scripts, and defense preparation must be grounded in verified repository sources. Never fabricate requirements, textbook definitions, or unverified DBMS behavior.

## 1. Role-Based 4-Tier Grounding Hierarchy

Repository directories and filenames may change as deliverables are refactored. Grounding tiers are defined **by role, never by fixed path**. At the start of each task, list the workspace root and active subdirectories, then explicitly map the files found on disk to the four tiers below before relying on them.

```text
[Tier 1: Academic Authority]       Assignment brief, phase weights, deadlines, team/topic allocation
               |
               v
[Tier 2: Requirements & Rules]     Authoritative requirements analysis & non-ERD business rules
               |
               v
[Tier 3: Technical Standards]      Database textbooks & official MySQL 8.0+ reference specs
               |
               v
[Tier 4: Project Deliverables]     Diagrams, normalization docs, SQL scripts, screenshots & reports
```

1. **Tier 1 - Academic Authority:**
   - **Role:** Official course assignment specification (phases, weights, submission rules, English-only report rule, individual demonstration & Q&A requirements) and team/topic allocation document.
   - **Permission:** Strictly read-only. Never modify academic assignment or topic documents.

2. **Tier 2 - Requirements & Business Rule Authority:**
   - **Role:** Defines domain entities, attributes, structural constraints, non-ERD business rules, and target database applications (loads, updates, queries, reports).
   - **Conflict Gate:** If multiple requirement files or phase drafts exist with differing length or content, verify with the user which document serves as the active baseline and flag any contradiction rather than guessing.

3. **Tier 3 - Technical & Textbook Standards:**
   - **Role:** Standard course textbooks (e.g., Elmasri & Navathe; Garcia-Molina et al.) and official DBMS documentation.
   - **Permission:** Strictly read-only.
   - **Use:** Ground formal definitions of Chen ER/EER notation, weak entities, aggregation/ternary mapping, Armstrong's axioms, 1NF/2NF/3NF/BCNF, lossless join, dependency preservation, and relational algebra.

4. **Tier 4 - Project Deliverables & Working Docs:**
   - **Role:** Conceptual ERD & relational schema sources (Draw.io and exported vector/PDF graphics), SQL modules (DDL, triggers/procedures, sample DML, operational/analytical queries, DBMS Workbench models), execution proof screenshots, normalization analyses, and submitted/draft phase reports.
   - **Physical SQL vs. Doc Drift Protocol:** Whenever SQL scripts diverge from normalization prose, diagrams, or report tables, inspect both, report the exact table/column/rule delta, and ask the user which artifact is authoritative before synchronizing (Rule 00 `[R2]`, `[R7]`).

## 2. Dynamic Discovery & Draft Hygiene

1. **Always discover before citing:** Re-list the workspace directory tree at session start and whenever a path changes. Never rely on remembered paths from earlier conversations or assume a markdown draft matches a compiled `.docx`/`.pdf` report.
2. **Separate drafts from finalized artifacts:** Inspect file timestamps and content rather than assuming draft status from folder names alone; flag unresolved placeholders or stale drafts explicitly.
3. **External literature & DBMS docs:** When MySQL 8.0+ specifics (e.g., `CHECK` + FK Error 3823, `WITH RECURSIVE` behavior, trigger timing) or domain rules are absent from Tier 3 textbooks, verify against official MySQL 8.0 Reference Manual documentation before concluding, and propose storing recurring notes in the workspace documentation or reference collection if helpful.
