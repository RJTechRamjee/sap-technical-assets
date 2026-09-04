# Technical Development Effort Estimate

> Build effort only (analysis → unit test → SIT/defect support) for ABAP / RAP /
> integration / conversion objects. Excludes commercials, rate cards, staffing
> model, licensing, functional-consultant effort, infra, PM overhead — see §6.
> Fill with `rfp-effort-estimator`.

## 1. Header

| Field | Value |
|---|---|
| RFP / opportunity | |
| Solution area | Lead-to-Cash / SD / Invoicing / cross |
| Target platform | S/4HANA Cloud Private Edition — S/4HANA 2025 |
| Prepared by | |
| Date / version | |
| Estimate confidence | Rough order of magnitude / Budgetary / Firm |

## 2. Estimating Basis (day ranges per object type — tune once, keep visible)

Days = analysis + design + build + unit test + defect fixing for one object.

| Object type | S (low–high) | M (low–high) | L (low–high) | XL |
|---|---|---|---|---|
| CDS read/analytical model | 1–2 | 3–5 | 6–10 | split |
| RAP Business Object | 4–6 | 8–14 | 16–28 | split |
| OData service + binding | 0.5–1 | 1–2 | 2–4 | — |
| Fiori elements app | 2–3 | 4–7 | 8–14 | split |
| Freestyle UI5 app | 5–8 | 10–18 | 20–35 | split |
| Released-BAdI implementation | 2–3 | 4–8 | 9–15 | split |
| Form (Adobe / DPP) | 2–4 | 5–9 | 10–18 | — |
| Interface — outbound event | 1–2 | 3–5 | 6–12 | split |
| Interface — inbound API (sync) | 2–4 | 5–9 | 10–20 | split |
| Interface — orchestrated (retry/replay) | — | 8–14 | 16–30 | split |
| Conversion / migration object | 2–4 | 5–10 | 12–22 | split |
| Report | 1–2 | 3–5 | 6–10 | — |
| Enhancement (Tier-4 exception) | +2 design overhead | +3 | +5 | — |
| BRFplus decision | 1–2 | 3–5 | 6–10 | — |

*Ranges are placeholders — adjust to team velocity, then treat as fixed for the estimate.*

## 3. Object Breakdown

| # | Requirement ID | Deliverable | Object type | Fit (config / partial / build) | Size | Days (low) | Days (most likely) | Days (high) | Notes / assumptions |
|---|---|---|---|---|---|---|---|---|---|
| 1 | | | | | S/M/L/XL | | | | |

Config-only rows: set build days to 0, note "functional effort — excluded here".
`[CONFIRM]` scope rows: list below §3, excluded from every total.

**Scope to be confirmed (excluded from totals):**
| # | Item | Why unclear | Rough size if it lands |
|---|---|---|---|

## 4. Roll-Up

### By object type
| Object type | Count | Days (low) | Days (most likely) | Days (high) |
|---|---|---|---|---|

### By phase
| Phase | Days (most likely) | Basis |
|---|---|---|
| Analysis & design | | included per object |
| Build | | |
| Unit test | | ~25–40% of build for logic-bearing objects |
| SIT support & defect fixing | | separate line, ~15–25% of build |
| Cutover / hypercare support | | |
| **Total technical build** | | |

### Estimate summary
| Measure | Value |
|---|---|
| Base (sum of most-likely) | |
| Range (sum low – sum high) | |
| Contingency % (state the driver) | e.g. 15% — N assumption rows, M XL/uncertain items |
| **Total with contingency** | |

## 5. Assumptions (estimate-affecting — numbered)

1. Development system is available and stable from project week [CONFIRM].
2. Required SAP APIs/CDS/BAdIs are released in S/4HANA 2025; no Tier-4 exception needed beyond those listed.
3. Standard forms framework (Adobe/DPP); no third-party output tool.
4. One logical system landscape, one leading language, [N] country rollout.
5. Functional specs delivered to the agreed template before build starts.
6. No changes to the standard data model beyond released extension points.
7. Integration middleware is SAP Integration Suite, already provisioned.
8. …

## 6. Exclusions (explicit)

- Commercial pricing, rate cards, margin, discount.
- Staffing model, ramp-up, shift/onshore-offshore split.
- SAP licensing (RAP/BTP/Integration Suite consumption).
- Functional configuration and functional-consultant effort.
- Project management, architecture governance, and test management overhead.
- Infrastructure, basis, transport administration.
- Data cleansing (business activity); training; OCM.
- Non-functional test execution (performance, security pen-test).

## 7. Risks to the Estimate

| # | Risk | Trigger | Rough impact |
|---|---|---|---|
| 1 | Pricing gap needs a non-released BAdI | fit-to-standard review finds no released extension point | Tier-4 design overhead + L per affected object |
| 2 | Convergent/high-volume billing in scope | volume numbers confirmed above standard billing thresholds | re-scope as XL / side-by-side |
| 3 | Interface partner spec immature | target system API not finalised at estimate time | +M–L per interface, contingency up |

## 8. Handoff

- Objects needing a `solution-architect` design pass before the estimate is trusted:
- Objects safe to build from the FS as-is:
