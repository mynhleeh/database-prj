---
trigger: always_on
description: "Core collaboration charter for the A34Build Database Project: anti-one-shot incremental edits, source verification, evidence before assertion, bidirectional schema-doc sync, and bilingual contract."
---

# 00. Core Collaboration Charter

This charter sets mandatory collaboration and engineering discipline for all agents operating in this Database Systems workspace (A34Build Construction Enterprise Database).

## 1. Immutable Governance Principles

1. **[R1] Anti-One-Shot Hard Gate:**
   - In any turn modifying files or generating deliverables, execute at most **1 coherent unit** (1 database subsystem or table group, 1 trigger rule with its test cases, 1 query/report group, or 1 document subsection).
   - Follow the 4-step cycle:
     - *Step 1 - Scope & Coordinates:* State target file(s), exact line/section coordinates, and objective.
     - *Step 2 - Contract & Impact:* Present a concise diff/schema proposal and identify cross-artifact blast radius (`ERD <-> 3NF <-> DDL <-> Triggers <-> DML & Queries <-> Report`).
     - *Step 3 - Confirmation Checkpoint:* Pause for explicit user approval when modifying schemas, FDs, business rules, grading-facing deliverables, or resolving conflicts.
     - *Step 4 - Surgical Execution & Verification:* Apply minimal edits and run automated/SQL verification.

2. **[R2] Mandatory Source Verification & Clarify Gate:**
   - Before editing files, writing SQL, claiming schema structure, or answering domain/academic questions, actively inspect the workspace sources discovered under Rule 01, the exact target file(s), or actual tool output from the current session.
   - **Double-check and persistent ingestion:** Cross-check database theory (ER/EER notation, relational mapping, 1NF/2NF/3NF, relational algebra) against Tier 3 textbooks in the workspace. When external DBMS or domain specifications (e.g., MySQL 8.0+ behavior) are needed repeatedly, propose saving a reference note or official reference doc into the workspace reference/documentation collection.
   - **STOP AND ASK** when no repository source grounds the requirement, or when two repository files contradict each other (e.g., column drift between normalization docs and SQL DDL). Never silently pick one version or invent missing columns, FDs, or business rules.
   - **Partial coverage:** Proceed only on the grounded portion and explicitly flag ungrounded or conflicting items for user decision.

3. **[R3] Evidence Before Assertion:**
   - Never declare that schemas are "3NF compliant", "synchronized with ERD/report", "SQL runs without errors", or "triggers block invalid operations" without fresh quantitative evidence from the current session (diff counts, automated consistency checks, or actual DBMS execution output).

4. **[R4] User Sovereignty:**
   - The user holds final authority over scope, schema modeling choices, DBMS tradeoffs, and deliverable formatting. Present tradeoffs objectively, then execute the user's explicit decision.

5. **[R5] Bilingual Communication Contract:**
   - **Discussion, explanations, coaching, and defense drills:** Respond in natural Vietnamese with accurate technical terms.
   - **SQL, identifiers, comments, commits, and official submitted deliverables:** Use standard, idiomatic English per the course assignment specification ("All reports are prepared in English"). Keep table, column, constraint, and trigger identifiers consistent in English across all artifacts.

6. **[R6] Reasoning From Knowledge:**
   - Conclusions about business rules, functional dependencies, normal forms, constraint enforcement, or query logic must follow a 4-link chain stated in chat: (1) source, (2) what the source states, (3) how it applies to this table/rule, (4) conclusion.
   - State underlying assumptions and mark confidence as `direct`, `derived`, or `conjecture`. Never write an unconfirmed conjecture into SQL or deliverables.
   - When sources disagree, cite the conflict, rank by Rule 01 tiers, apply the higher tier when authoritative, and ask the user if an implementation artifact diverged from upstream docs.

7. **[R7] Bidirectional Lifecycle Synchronization (Two-Way Ripple):**
   - Database deliverables form an interconnected chain:
     `Requirements <-> Chen ERD <-> Relational Schema <-> 3NF Normalization <-> MySQL DDL & Triggers <-> Sample DML & Queries <-> Final Report`.
   - Every change requires checking both directions:
     - *Backward Impact (Upstream):* When DDL, triggers, or sample data reveal a missing attribute, constraint, or normalization defect, report and propagate the update back to ERD, normalization analysis, and requirements.
     - *Forward Impact (Downstream):* When requirements, FDs, or schema names change, propagate updates downstream across conceptual/logical diagrams, SQL scripts, and Word/PDF reports.
     - Never silently leave orphaned column names, mismatched rule numbers, or stale diagrams.

8. **[R8] Collaborative Authoring & Approval Gate:**
   - When creating or restructuring reports, SQL scripts, or documentation from scratch: build the structural scaffold first, align assumptions/scope with the user, preview the proposed structure or SQL contract in chat, and write files only after explicit user approval.

## 2. Action-First Communication Standards

1. **Zero Preamble:** Omit conversational filler ("Sure, here is...", "As requested..."). Lead with technical findings, proposals, or blocking questions.
2. **Never Echo Prompts:** Do not restate the user's prompt back to them.
3. **High Information Density:** Keep bullet points concise (max 3 key points per argument where practical) and prefer comparison tables over walls of text.

## 3. Precedence of Rules

When two rules conflict, apply the higher-ranked entry and report the conflict to the user.

| Order | Authority | Reason |
| --- | --- | --- |
| 1 | Explicit user instruction (R4), within course assignment constraints | User controls project scope and choices |
| 2 | R2 and R6 of this charter | Grounding and explicit reasoning protect correctness |
| 3 | R1, R3, R5, R7, R8 of this charter | Incremental safety, evidence, language, and lifecycle sync |
| 4 | Rules 01 through 05 in numeric order | Domain, writing, SQL/DB, citation, and workflow standards |
