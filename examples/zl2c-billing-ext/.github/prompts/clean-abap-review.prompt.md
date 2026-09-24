---
agent: 'agent'
description: 'Review selected ABAP against Clean ABAP and ABAP Cloud compliance.'
argument-hint: 'class name (optional)'
---

<!--
  NOTE — prompt files are the sunsetting layer, as of 2026-09-16:
    * deprecated for Agent Host, auto-migrating to agent skills
    * never supported in the Eclipse Copilot extension, at any version
    * the frontmatter key `mode:` has been replaced by `agent:`
  Kept here because it still works in VS Code and because the filename-becomes-
  a-slash-command mechanic is worth seeing. Don't write new ones.
-->

Review the ABAP below against Clean ABAP and ABAP Cloud compliance.

Apply the rules in
[abap-clean-core.instructions.md](../instructions/abap-clean-core.instructions.md)
rather than restating them here.

Output format:

```
## Review Summary
Blockers: N   Major: N   Minor: N   Suggestions: N
Recommendation: Approve / Approve with comments / Request changes

## Findings
[severity] <line or method> — <what is wrong>
  Why it matters: <one line>
  Suggested fix: <concrete code>
```

Rules:

- ABAP Cloud violations — non-released object access, core modification,
  obsolete statements — are always Blockers, however clean the rest is.
- Every Blocker and Major finding needs a concrete suggested fix, not a complaint.
- Do not invent findings. If the code is clean, say so in one line.
- If this is a RAP behaviour pool, check the save-sequence contract and
  MAPPED/FAILED/REPORTED usage specifically.

Code:

${selection}
