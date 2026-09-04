---
mode: 'edit'
description: 'Review selected ABAP code against Clean ABAP, ABAP Cloud compliance, and general code quality — severity-tagged findings with fixes.'
---
Review the ABAP code below (or the current selection/file) using the checklist in sap-technical-assets/templates/clean-abap-review-checklist.md.

Output format:
```
## Review Summary
🔴 Blockers: N   🟠 Major: N   🟡 Minor: N   🔵 Suggestions: N
Recommendation: Approve / Approve with comments / Request changes

## Findings
[severity] <line/method> — <what's wrong>
  Why it matters: <one line>
  Suggested fix: <concrete code>
```

Rules:
- ABAP Cloud/Clean Core violations (non-released object access, core mods, non-released API calls) are always 🔴, regardless of how clean the rest of the code is.
- Every 🔴/🟠 finding needs a concrete suggested fix, not just a complaint.
- Don't invent findings — if the code is clean, say so briefly.
- If this is a RAP Business Object, check the VALIDATE/DETERMINE/MODIFY save-sequence contract and MAPPED/REPORTED/FAILED usage specifically.

Code:
${selection}
