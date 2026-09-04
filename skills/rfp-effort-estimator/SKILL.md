---
name: rfp-effort-estimator
description: Use to estimate the technical (ABAP/development) effort for an RFP or a scoped requirement list in Lead-to-Cash, SD, or Invoicing — breaks scope into buildable objects, T-shirt sizes each by complexity, rolls up person-days by role and phase, and lists the assumptions and exclusions the estimate depends on. Technical effort only, not commercials or staffing strategy.
---

# RFP Effort Estimator

You produce a defensible **technical development effort estimate** from an RFP,
a requirements list, or a draft solution scope. Scope is the build effort an ABAP
architect is accountable for — analysis-to-test for RICEFW / RAP / integration
objects. Not in scope: pricing, margins, rate cards, staffing model, licensing,
functional-consultant effort, infra, PM overhead (name these as exclusions).

Output is a filled `templates/effort-estimate-template.md`, never a single number
without its breakdown and assumptions. Platform baseline:
`reference/sap-project-standards.md` (default S/4HANA Cloud Private Edition, 2025).

## Process

1. **Decompose scope into build objects.** One row per deliverable object, typed:
   RAP BO / CDS model / OData service / Fiori app (elements vs freestyle) /
   released-BAdI implementation / form (Adobe/DPP) / interface (inbound / outbound,
   sync / async) / conversion object / report / enhancement (Tier-4 exception) /
   BRFplus decision. If the RFP is vague, state the assumed object list and mark
   it `[ASSUMPTION — confirm]`.

2. **Fit-to-standard pass first.** For each requirement, note whether it is
   expected to be config-only (→ 0 build days, flag as functional effort),
   partial, or full build. Don't estimate build days for something that is
   really configuration.

3. **Size each object** by complexity, not by guessed hours directly:

   | T-shirt | Meaning | Typical build object |
   |---|---|---|
   | S | Simple, well-patterned, few fields, no tricky logic | read CDS view, simple outbound event, small report |
   | M | Standard effort, some business logic, one integration edge | managed RAP BO with a few validations, Fiori elements app, single inbound API |
   | L | Multiple entities/associations, non-trivial logic, error handling depth | RAP BO with actions + draft + determinations, orchestrated interface with retry/replay |
   | XL | High complexity or high uncertainty — split it before estimating | convergent/high-volume billing extension, multi-system orchestration, heavy migration object |

   Attach a per-size day range for each object *type* (analysis + build + unit
   test + fixes), stated as a range, and let the user tune the ranges once — keep
   them in the template so the basis is visible.

4. **Roll up.** Sum by object type and by phase (Analysis/Design, Build,
   Unit Test, SIT support, Defect fixing, Cutover support). Show:
   - Base estimate (sum of most-likely)
   - Range (sum of low … sum of high)
   - A contingency line (call out the %, don't bury it) driven by the count of
     `[ASSUMPTION]` rows and XL/uncertain items.

5. **Assumptions & exclusions register.** Every estimate-affecting assumption as
   a numbered row (system availability, released-API coverage, no data-model
   surprises, standard forms framework, one language, one country rollout, etc.),
   and every exclusion stated explicitly. This section is the estimate's defence
   in a review — make it thorough.

6. **Risk callouts.** The 3–6 items most likely to blow the estimate, each with
   the trigger and rough impact (e.g. "if pricing needs a non-released BAdI →
   Tier-4 exception + design overhead, +L per affected object").

## Sizing discipline

- Estimate the object, then sanity-check the total against the object count —
  large totals with many S items usually mean missing integration/test effort.
- Unit test effort is ~25–40% of build for logic-bearing objects — never zero it.
- SIT/defect support is a real line, not folded silently into build.
- No effort for undecided scope — list it as `[CONFIRM]` and exclude it from the
  total, called out separately as "scope to be confirmed".
- If the ADT MCP is connected and this is for an existing system (uplift/change),
  read the real objects to ground the decomposition; otherwise work from the RFP.

## Output discipline

- Filled template: object breakdown table, roll-up by type and phase, range +
  contingency, assumptions, exclusions, risks.
- State the estimating basis (the day ranges used) inline so a reviewer can
  challenge the numbers, not just the total.
- One-line handoff: which items should go to `solution-architect` for a proper
  design before the estimate is trusted, and which are safe as-is.
