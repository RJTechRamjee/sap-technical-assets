---
mode: 'ask'
description: 'Review a selected Solution Design Document (or one of its sections) for fit-to-standard evidence, Clean Core tiering, integration completeness, and NFR coverage.'
---
Review the Solution Design Document text below against sap-technical-assets/templates/solution-design-document.md and sap-technical-assets/skills/solution-architect/SKILL.md (Mode 3), for S/4HANA Cloud Private Edition (S/4HANA 2025).

Output findings most severe first:
```
## Review Summary
🔴 Blockers: N   🟠 Major: N   🟡 Minor: N   🔵 Suggestions: N
Verdict: Approve / Approve with changes / Rework

## Findings
[severity] <section> — <what's wrong>
  Why it matters: <one line>
  Fix: <concrete change>
```

Blocker triggers: a gap routed to classic (Tier 4) with no dated exception record/owner/remediation release; a non-released API in a dependency table; an interface with no error/replay/monitoring design; an NFR with no supporting mechanism; a persistent entity writing to SAP-owned tables.
Major triggers: fit-to-standard asserted but not evidenced with a named SAP mechanism; a key decision with only one option considered; a touched Clean Core dimension with no stated position; requirements register rows with no FS target or tier.

Rules:
- Judge against released-API and tier rules in sap-technical-assets/reference/sap-project-standards.md §3–§4, §7.
- Don't invent SAP mechanism names; if a claim can't be checked, flag it as unverified rather than accepting it.

SDD text:
${selection}
