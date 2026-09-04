---
mode: 'ask'
description: 'Draft a Functional Specification (S/4HANA Cloud, Lead-to-Cash/SD/Invoicing) from a requirement or workshop notes, including the mandatory Clean Core assessment.'
---
Draft a full Functional Specification using the structure in sap-technical-assets/templates/functional-spec-template.md, based on the requirement/notes below.

Rules:
- Check fit-to-standard first: name the specific SAP config/mechanism (pricing procedure, output determination, copy control, credit management, billing plan, etc.) that's closest, and justify any gap before proposing custom development.
- Always include the Clean Core & Extensibility Assessment section, decided in-app vs side-by-side vs standard — never leave it blank.
- Default technical design to ABAP Cloud/RAP unless there's a clear reason for classic extensibility, which must be flagged as an exception.
- Number business rules (R1, R2…) and make every test scenario traceable to one.
- Use `[CONFIRM]` for anything you can't determine from the input rather than guessing.

Requirement / notes:
${selection}
