---
mode: 'ask'
description: 'Draft the Technical Design Document from a reviewed functional spec or solution position — object inventory, CDS/RAP design, released-API register, authorization, messages, tests, build sequence.'
---
Write the Technical Design Document for the requirement below, using the structure in sap-technical-assets/templates/technical-design-document.md and the method in sap-technical-assets/skills/technical-design-writer/SKILL.md. Target: S/4HANA Cloud Private Edition, S/4HANA 2025, language version *ABAP for Cloud Development*. Naming and packaging per sap-technical-assets/reference/sap-project-standards.md §4–§6.

The bar: an offshore ABAP developer who was not in the workshop can build the whole thing without asking a question.

Fill in order:
1. **Clean Core & extensibility decision** — tier, named mechanism, why the tier above was insufficient. Everything downstream depends on it.
2. **Object inventory** — every object to create/change with name, type, package, purpose and the FS rule it serves.
3. **Data model & CDS design** — persistent entities, keys, associations to released SAP entities, interface vs projection split, annotations (UI annotations in the metadata extension, never inline), draft decision.
4. **RAP behavior design** — one row per FS business rule: determination / validation / action, trigger, logic summary, failure message. Plus implementation type (managed, `strict ( 2 )`), numbering, ETag/lock, authorization model.
5. **Class & method design** for non-RAP logic — business logic separated from data access so it is unit-testable; `ZCX_*` exception hierarchy.
6. **Released API dependency register** — every SAP object consumed with its API state; mark unverified rows `[CONFIRM in ADT]` and list verification as a pre-build task.
7. **UI, interface, authorization, messages, performance, unit-test design** — do not skip these; message texts are written here, not left to the developer, and performance gets a number, not "should be fine".
8. **Build sequence & transport plan** — ordered steps ending with a clean ATC run under the ABAP Cloud variant.

Rules:
- Fill every section; `N/A` is valid, blank is not.
- Every object traces to at least one FS rule; every FS rule appears in the behavior or class design, or is explicitly out of scope.
- Never invent a CDS view, BAdI or API name to look complete — write `[CONFIRM in ADT]`.
- If the requirement hasn't been challenged against standard SAP yet, say so and recommend /functional-spec-review first rather than designing a build for something configuration already covers.

Requirement / reviewed FS / solution position:
${selection}
