---
trigger: always_on
description: "General task workflow for Database_Project: classify task, ground sources dynamically, scan existing skills, plan with two-way ripple check, execute surgically, sweep cross-artifact parity, and verify with evidence."
---

# 05. General Task Workflow

Every task in this workspace follows this structured execution pipeline. It complements Rules `00` through `04` and never overrides higher-ranked rules in Rule 00.

## 1. Phase 0: Classify & Ground

1. Classify the request into one primary type:

| Type | Scope |
| --- | --- |
| `SPECIFY` | Domain scope, entities, non-ERD business rules, database applications |
| `MODEL_ERD` | Conceptual ER/EER design, Draw.io diagrams, Mermaid ER overviews |
| `NORMALIZE` | Relational mapping, FDs, Candidate Keys, 1NF/2NF/3NF proofs |
| `SQL` | MySQL DDL, triggers, procedures, DML seed data, queries, relational algebra |
| `AUDIT` | Consistency checks across ERD, 3NF docs, SQL scripts, screenshots, and reports |
| `RESEARCH` | Verifying database theory in Tier 3 textbooks or official MySQL 8.0+ specs |
| `DEFENSE_PREP` | Phase 4 demonstration walkthrough, Socratic mock Q&A, rubric prep |
| `MAINTAIN` | File cleanup, formatting fixes, synchronization, commit organization |
| `MIXED` | Split into ordered single-concern units by type |

2. Check grounding sources in tier order (Rule 01) by listing the actual workspace directory tree at task start; map discovered files to Tiers 1–4 and mark sources sufficient or insufficient.
3. If an authoritative source is missing or two sources conflict (e.g., normalization docs vs. SQL DDL), STOP AND ASK per `[R2]` before modifying deliverables.

## 2. Phase 1: Dynamic Skill Check

1. Inspect the active session skill list and the workspace skill directory dynamically at task start (never rely on a remembered list).
2. Apply only skills whose `description` genuinely matches the task, announcing `"Using [skill] to [purpose]"`.
3. Never dispatch subagents automatically unless the user explicitly asks for subagent review or parallel subagents.

## 3. Phase 2: Plan & Impact Check

1. Break work into coherent units (Rule 00 `[R1]`), declaring the exact files touched and verification command for each unit.
2. **Bidirectional Ripple Check (`[R7]`):** Before changing any table, column, constraint, or rule, list affected upstream specs (requirements, ERD, normalization analysis) and downstream artifacts (SQL scripts, Workbench models, reports).
3. Classify risk:
   - **High Risk:** Changes PK/FK, candidate keys, 3NF structure, business rules, trigger conditions, or graded report claims -> present concise proposal & options table and obtain user approval before editing.
   - **Low Risk:** Typo fixes, SQL comments, formatting parity, read-only audits -> proceed cleanly after brief scope note.

## 4. Phase 3: Surgical Execution & Verification

For each approved unit:
1. Read the target file immediately before editing; modify only the smallest region required.
2. For new documents or multi-step SQL modules, follow scaffold/contract preview first (`[R8]`).
3. Run concrete verification immediately after the edit (e.g., Python cross-check script on schema/column parity or `mysql` execution + negative trigger tests).
4. Record actual command outputs and counts (`[R3]`). If verification fails, diagnose root cause before retrying.

## 5. Phase 4: Whole-Scope Sweep & Handover

1. After all units finish, search across documentation, diagrams, and SQL modules in the workspace for every renamed table, column, rule ID, or obsolete term to ensure `0` unhandled stale references remain in scope.
2. On Windows PowerShell, write multi-file scans or parity checks using pure Python or PowerShell cmdlets (`Select-String`) rather than assuming `rg` or `awk` exist in `PATH`.
3. Report per unit: changed files, exact verification command + output, open risks/conflicts outside scope, and recommended next step.

## 6. Safety Boundaries

1. Never delete, overwrite binary deliverables (`.docx`, `.pdf`, `.mwb`, `.png`), `git commit`, or `git push` without explicit user instruction.
2. Treat Tier 1 academic materials and Tier 3 textbooks as strictly read-only.
3. Do not silently edit working drafts when the user targeted finalized deliverables, and vice versa, unless explicitly part of an approved synchronization unit.
