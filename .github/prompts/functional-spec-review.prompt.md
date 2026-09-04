---
mode: 'ask'
description: 'Review a functional spec written by someone else — challenge it against standard SAP, scan for ECC-era S/4HANA red flags, and produce the architect solution position.'
---
Review the Functional Specification below as the solution architect, for S/4HANA Cloud Private Edition (S/4HANA 2025), Lead-to-Cash / SD / Invoicing. Follow sap-technical-assets/skills/functional-spec-reviewer/SKILL.md and output the structure in sap-technical-assets/templates/fs-review-report.md.

Do these in order:

1. **Fit-to-standard challenge** (the core). For every requirement, name the standard SAP mechanism that may already cover it and give the question to put to the author. Verdict per requirement: Standard covers it / Partial / Genuine gap / Unclear. Draw on sap-technical-assets/reference/fit-to-standard-patterns.md, l2c-standard-process-reference.md and pricing-condition-technique-reference.md. Typical answers: item category + billing relevance `FKREL`, copy control pricing type, incompletion procedure `OVA2`, condition table/access sequence/scales/group condition/exclusion, Invoice Correction Request `RK`, billing plan, condition contract settlement, aATP, FSCM credit management, Output Control, customer-material info record, free goods, third-party `TAS`.
2. **S/4HANA red-flag scan** against sap-technical-assets/reference/s4hana-simplification-redflags.md — `VBUK`/`VBUP`, `KONV`, SD rebate agreements, `FD32` credit, `NACE`/`NAST` output, `VF44` revenue recognition, `XD01`, MATNR 18, LIS/SIS, batch input on `VA01`, user exits, VOFM routines. A 🔴 hit means the FS is not signable as written.
3. **Completeness for build** — is the document type, item category, billing relevance, pricing procedure, org scope, output framework, volumes, and unhappy-path behaviour (return, cancellation, credit memo, partial delivery) actually stated?
4. **Clean Core assessment validity** — tier justified, mechanism named concretely, no non-released object assumed, Tier-4 items carry justification/owner/remediation.
5. **Testability** — every business rule traceable to at least one test scenario.
6. **Architect's solution position** — per requirement: recommended solution, tier, named mechanism, what must change in the FS, build objects implied, S/M/L/XL effort. End by listing which requirements are ready for a Technical Design Document.

Rules:
- Never write "standard handles this" without naming the config object, transaction or released API.
- Never accept "custom development" because the FS says so — proposing the build approach is the architect's job.
- Don't over-challenge: when it's a real gap, say so cleanly and move on.
- Don't invent SAP object names — mark unverifiable released APIs `[CONFIRM in ADT]`.
- Every 🔴/🟠 finding carries the concrete replacement, not just the objection.

Functional spec:
${selection}
