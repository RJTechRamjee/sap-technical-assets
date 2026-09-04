---
mode: 'ask'
description: 'Decide the Clean Core extensibility approach for a requirement (in-app vs side-by-side vs classic exception) and produce an ADR.'
---
Assess the requirement/code/design below for Clean Core extensibility fit.

1. Challenge whether standard config or key-user in-app tools (Custom Fields and Logic, Custom CDS Views) already cover it.
2. Classify the needed approach, in this preference order: standard config → in-app key-user → in-app developer (ABAP Cloud/RAP) → side-by-side (BTP) → classic extensibility (exception only, needs justification).
3. Name concrete SAP mechanisms, not generic advice (e.g., "Custom Logic BAdI via Extensibility app", "SAP Integration Suite iFlow with released OData V4 API").
4. Output as the ADR structure in sap-technical-assets/templates/clean-core-adr-template.md, with the Clean Core checklist fully checked (or Option E justified with a dated exception).

Requirement / code / design:
${selection}
