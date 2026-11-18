---
trigger: glob
globs: "**/*.md, **/*.markdown"
description: "Technical writing standards for database documentation and reports: abstraction purity, anti-AI prose discipline, table parity, and deliverable hygiene."
---

# 02. Technical Writing & Documentation Discipline

This rule enforces clear, authentic engineering prose, valid Markdown tables, and clean deliverable readiness across all `.md` documentation and report drafts.

## 1. Abstraction Layer Discipline

1. **Requirements & Conceptual Design Layer (Requirements analysis, ERD narratives — WHAT):**
   - Describe construction-domain entities, attributes, cardinalities, participation constraints, and business rules in technology-agnostic terms.
   - Forbid MySQL-specific syntax (`ENGINE=InnoDB`, `VARCHAR(150)`, `SIGNAL SQLSTATE '45000'`, `AUTO_INCREMENT`) inside conceptual requirements or ER descriptions.
2. **Logical Normalization Layer (Relational Schema, FDs, 3NF — LOGIC):**
   - Express functional dependencies, candidate keys, prime/non-prime attributes, and normal form proofs rigorously using consistent schema/attribute names synchronized with both conceptual models and DDL.
3. **Physical Implementation & Report Layer (DDL, Triggers, Queries — HOW):**
   - Document concrete DBMS choices (MySQL 8.0+, InnoDB, `utf8mb4`), constraint names, trigger mechanics, relational algebra mappings, and verified execution proofs.

## 2. Anti-AI Tells & Stylistic Rules

1. **No Redundant Bilingual Tagging:**
   - When writing Vietnamese in notes/discussions, do not append redundant English translations in parentheses (forbid `Phân tích yêu cầu (Requirement Analysis)`). Keep official SQL identifiers and standard database terms (`Primary Key`, `3NF`, `InnoDB`, `CTE`) cleanly in English.
   - Official submitted reports must be 100% natural, direct academic/engineering English per the course assignment specification.
2. **Restrained Punctuation & Zero Em-Dash Spam:**
   - Avoid chaining sentences with em-dashes (`—`) or double hyphens (`--`). Use periods, commas, colons, or parentheses naturally.
3. **No Mechanical Bold-Prefix Bullet Lists:**
   - Avoid repeating `- **Label:** Sentence.` across every bullet when a compact Markdown table or plain numbered/bulleted sentence is clearer.
4. **No Fake Contrasts & Forced Triplets:**
   - Eliminate rhetorical filler ("Not only X, but also Y", "This is not just a schema, it is a blueprint", forced 3-adjective lists like "robust, scalable, and seamless"). State concrete mechanisms and numbers directly.
5. **Zero Stock AI Vocabulary:**
   - Forbid: `delve`, `tapestry`, `landscape` (metaphorical), `pivotal`, `seamless`, `leverage`, `game-changer`, `holistic`, `comprehensive and insightful`, `bức tranh tổng thể`, `đòn bẩy`, `chìa khóa vàng`.

## 3. Markdown Table & Math Integrity

1. **Strict Column Count Parity:**
   - Header columns = Delimiter row columns (`| :--- |`) = Data row columns on every row.
2. **Pipe Escaping & Empty Cells:**
   - Escape any `|` inside inline math or code inside table cells as `\|`.
   - Use a single space `|  |` or explicit `*None*` for empty table cells; never use bare `||`.
3. **Readable Presentation Form:**
   - Use tables for repeating multi-attribute items (attribute lists, FD/3NF matrices, constraint matrices); use numbered lists for ordered procedures or relational algebra steps; avoid narrative paragraphs exceeding 8 consecutive lines.
   - Never drop or paraphrase rule numbers (`Rule 1`..`Rule 10`), query identifiers, or exact table/column identifiers.

## 4. Deliverable Readiness Hygiene

Before finalizing any report or guide for Word/PDF export:
1. **Zero leftover placeholders:** Scan for unfilled markers (e.g., screenshot placeholders, export notes, `TODO`, `TBD`). Count must equal `0`.
2. **Zero local machine paths:** Never leave developer local filesystem or drive paths inside deliverable guides or reports; omit internal repository pointers from formal submitted report prose (Rule 04).
3. **Verify screenshot uniqueness:** Confirm every referenced evidence image exists in the workspace screenshot directory and is not an accidental duplicate capture of another rule or query.
