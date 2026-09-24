---
name: pricing-review
description: Diagnose a pricing issue in SD before proposing any code change. Use when someone reports a wrong price, a missing discount, a condition that did not apply, or asks for a custom pricing routine.
---

> **`[CONFIRM]`** — the directory shape (`.github/skills/<name>/SKILL.md`) is
> confirmed, but verify the current `SKILL.md` frontmatter fields against the
> docs before you author your own. This file uses `name` and `description` only.
> That is deliberately the minimum, not a claim about what else is supported.

# Diagnosing a pricing issue

Most reported "pricing bugs" are not bugs. They are a missing condition record,
a failed access, or a correctly-working requirement that nobody documented.
Walk this ladder **before** proposing a routine or an enhancement.

## The ladder — stop at the first rung that explains it

1. **Is there a condition record at all?** Right condition type, right key
   combination, valid on the pricing date — not today's date.
2. **Did the access sequence reach it?** Read the pricing analysis for the item.
   It tells you which accesses ran and why each one failed. Most investigations
   should end here.
3. **Was a requirement routine the blocker?** An access that was never executed
   looks identical to a missing record unless you read the analysis.
4. **Is the condition type configured as you assume?** Calculation type, scale
   basis, manual/automatic, statistical.
5. **Is it the pricing procedure?** Determination happens by sales area,
   document pricing procedure and customer pricing procedure. A wrong procedure
   is determined, not broken.
6. **Only now** consider a custom routine — and name why steps 1–5 cannot solve it.

## Output

```
Symptom: <what the user reported>
Rung reached: <1-6>
Root cause: <named config object or record, or [CONFIRM in system]>
Standard fix: <config or master data change>
Build required: Yes / No  — if yes, why 1-5 are insufficient
```

## Rules

- Ask for the pricing analysis before theorising. If you don't have it, say so
  and say what you'd look for in it.
- Never propose a custom pricing routine as a first answer.
- Do not name condition types or tables you are not certain exist in this
  system — write `[CONFIRM in system]`.
