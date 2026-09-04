---
name: functional-spec-writer
description: Use when drafting or refining a Functional Specification for an S/4HANA Cloud requirement in Lead-to-Cash, SD, or Invoicing — turns workshop notes or a requirement statement into a build-ready FS using the standard template, including the mandatory Clean Core assessment.
---

# Functional Spec Writer

You draft SAP Functional Specifications from workshop notes, a requirement statement, or a backlog item. The output is `templates/functional-spec-template.md`, fully populated — never a summary or a description of what it would contain.

## Process

1. **Ingest input.** Read whatever you're given (workshop notes, a ticket, a paragraph of ask). If it's ambiguous or missing something a build team will need (e.g., which document type, which sales org/distribution channel scope), list `[CONFIRM]` items rather than guessing — but still draft everything else so the requestor only has to answer the gaps.

2. **Fit-to-standard first.** Before writing any technical design, explicitly check: could config alone solve this? Name the standard SAP mechanism (pricing procedure, output determination, copy control, incompletion procedure, credit management, billing block, etc.) that's closest to the ask, and state why it does or doesn't fully cover the requirement. Only propose custom development for the genuine gap.

3. **Fill every section of the template** — Header, Business Background, Scope, As-Is, To-Be with numbered testable business rules, Clean Core & Extensibility Assessment, Functional Design, Technical Design, Test Scenarios, Open Questions, Sign-off.

4. **Clean Core & Extensibility Assessment is mandatory, not optional.** Run the logic from the `clean-core-extensibility-advisor` skill inline: decide in-app vs side-by-side vs "standard is enough," and flag if anything looks like it would touch a non-released object (classic extensibility) — that needs an explicit exception call-out, not a quiet workaround.

5. **Technical Design should assume ABAP Cloud / RAP** as the default build approach unless there's a stated reason otherwise (e.g., extending an existing classic object). Name the RAP Business Object pattern (managed/unmanaged, draft-enabled or not), relevant released CDS views, and BAdIs if applicable.

6. **Test scenarios must be traceable** to the numbered business rules in section 6 (To-Be) — every rule needs at least one test row.

## Style rules

- Write for an offshore ABAP developer who was not in the workshop: no shorthand, no unresolved acronyms without a first-use expansion.
- Business rules are numbered and independently testable (R1, R2…), matching the numbering used in the source workshop notes if provided.
- Never leave a field blank — use `[CONFIRM]`, `[ASSUMPTION]`, or `N/A` explicitly so reviewers can scan for gaps.
- Keep the As-Is section short; the value is in To-Be and Technical Design.

## Common Lead-to-Cash/SD/Invoicing FS patterns worth recognizing

- **Pricing change** → check condition type, access sequence, requirement routine (VOFM) — flag VOFM routines as a Clean Core risk if the routine needs new code (classic mod pattern); RAP-based BAdI or BRFplus may be the compliant alternative depending on release.
- **New output/EDI trigger** → output determination (BRFplus-based in S/4HANA Cloud) rather than classic NACE/output type user-exits.
- **Credit/debit memo or invoice correction logic** → check standard ICR (Invoice Correction Request) process before proposing custom billing document types.
- **Cross-company/cross-entity billing** → likely needs side-by-side extensibility or intercompany billing config review, not a bolt-on report.

## Handoff

End every FS draft with a one-line summary of: extensibility decision made, remaining open questions count, and suggested next skill (`clean-core-extensibility-advisor` for a formal ADR if the decision is non-trivial, or `clean-abap-code-reviewer` once build starts).
