# Functional Spec Review — Architect's Report

> Produced by `functional-spec-reviewer`. Two audiences: the FS author (findings
> to act on) and the build team (the design position that becomes the TDD).

## 1. Header

| Field | Value |
|---|---|
| FS reviewed (ID / title / version) | |
| Author | |
| Reviewer (architect) | |
| Review date | |
| Process area | Lead-to-Cash / SD / Invoicing |
| Target platform | S/4HANA Cloud Private Edition — S/4HANA 2025 |
| Related SDD / ADRs | |

## 2. Verdict

| | |
|---|---|
| 🔴 Blockers | |
| 🟠 Major | |
| 🟡 Minor | |
| 🔵 Suggestions | |
| **Verdict** | Approve / Approve with changes / **Rework — not signable** |

One-paragraph summary: what this FS is asking for, the single most important
thing wrong with it, and what happens next.

## 3. Fit-to-Standard Challenge

*The core of the review. One row per requirement.*

| Req | What the FS proposes | Standard mechanism that may cover it (named) | Question to the author | Verdict |
|---|---|---|---|---|
| R1 | | e.g. item category billing relevance `FKREL` = `G` + copy control | | Standard covers it / Partial / Genuine gap / Unclear |

**Summary:** N of M requirements are covered by standard configuration,
N partial, N genuine gaps, N unclear pending answers.

## 4. S/4HANA Red Flags

*Empty is a good outcome — write "None found" rather than deleting the section.*

| Sev | FS reference | Spotted | S/4HANA 2025 reality | Replacement design |
|---|---|---|---|---|
| 🔴 | §7, R4 | e.g. "SD rebate agreement VBO1" | Condition Contract Settlement Management | Condition contract with business volume determination and delta accrual settlement |

## 5. Findings

*Most severe first. Every 🔴/🟠 carries a concrete fix.*

```
[🔴] §<section> / R<n> — <what's wrong>
  Why it matters: <one line — build impact, upgrade risk, or ambiguity cost>
  Fix: <the concrete change the author must make>
```

## 6. Completeness for Build

| Item a developer needs | Stated in FS? | Gap |
|---|---|---|
| Document type(s) / item categories | Yes / No / Partial | |
| Billing type and billing relevance (`FKREL`) | | |
| Pricing procedure / condition types | | |
| Org scope (sales org, distribution channel, plant, country) | | |
| Output framework and channel | | |
| Master data ownership / source system | | |
| Volumes and frequency | | |
| Unhappy paths (return, cancellation, credit memo, partial delivery, reversal) | | |
| Authorization expectations | | |

## 7. Clean Core Assessment Review

| Check | Result |
|---|---|
| Extensibility tier stated and justified? | |
| Mechanism named concretely (not "use BTP")? | |
| Any non-released object assumed? | |
| Tier-4 items carry justification + owner + remediation target? | |
| Anti-patterns present (VOFM routine, user exit, append + implicit enhancement, Z-table replacing condition records)? | |

**Architect's Clean Core position:** *(one paragraph — the tier this work should
land in and why)*

## 8. Testability

| Business rule | Test scenario present? | Gap |
|---|---|---|
| R1 | | |

Unhappy paths with no scenario: …

## 9. Architect's Solution Position

*What the solution should actually be. This section becomes the input to the TDD.*

| Req | Recommended solution | Tier | Named mechanism | What must change in the FS | Build objects implied | Effort |
|---|---|---|---|---|---|---|
| R1 | | 0–4 | | | | S/M/L/XL |

**Ready for Technical Design Document:** R… 
**Blocked pending answers:** R… (see §10)

## 10. Questions Back to the Author

*Written so they can be answered without a meeting.*

| # | Question | Relates to | Blocking? | Owner | Due |
|---|---|---|---|---|---|
| 1 | | R1 | Yes/No | | |

## 11. Sign-off

| Role | Name | Date | Position |
|---|---|---|---|
| Architect (reviewer) | | | Approve / with changes / rework |
| FS author | | | Findings accepted / disputed |
