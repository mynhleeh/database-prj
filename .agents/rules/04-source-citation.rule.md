---
trigger: always_on
description: "Source attribution discipline: separates chat-level repo pointers and labeled inferences from formal citations inside academic deliverables."
---

# 04. Source Attribution & Citation Discipline

This rule governs how sources, reasoning inferences, and formal citations are presented across chat responses and deliverables. It complements Rule 00 (`[R2]`, `[R3]`, `[R6]`) and Rule 01.

## 1. Three Separate Channels

Keep each kind of attribution in its proper channel and never mix their formats:

| Channel | Where it lives | Content | Format |
| --- | --- | --- | --- |
| Chat pointer | Chat reply only | Workspace path, section, page, SQL line, or verified URL where a fact was observed | Informal clickable link or path + line/section |
| Inference and notes | Chat reply only | Agent analysis, schema tradeoffs, assumptions, discrepancy flags | Explicitly labeled as `Inference:` or `Note:` |
| Formal citation | Deliverable's references section | Bibliographic record for textbooks, standards, or external DBMS docs | Standard academic format (APA / course style) |

## 2. Chat Pointers & Inference Hygiene

1. Every factual claim in chat about table names, columns, triggers, query results, or course deadlines must point to a file or command output actually inspected in the current session.
2. Never blend quoted source facts and derived inferences in the same sentence without marking the inference clearly.
3. Never copy chat-style repository paths or local filesystem paths into the body prose of formal submitted reports (Word or PDF deliverables).

## 3. Formal Deliverable Citations

1. Ground database theory claims (e.g., ER/EER notation, 1NF/2NF/3NF definitions, Relational Algebra) in the course textbooks located in the Tier 3 reference tier (Elmasri & Navathe, Garcia-Molina et al.), checking exact edition and chapter before writing.
2. Never invent edition numbers, chapter numbers, page numbers, authors, or URLs. When a bibliographic field is unverified, read the textbook frontmatter/chapter or ask the user before recording it.
3. Verify every in-text citation maps to an entry in the deliverable's references list with zero unused or broken entries.
