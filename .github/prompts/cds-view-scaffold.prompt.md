---
mode: 'ask'
description: 'Scaffold a read/analytical ABAP Cloud CDS model (interface + consumption view, associations, access control) from the selected requirement or entity description.'
---
Scaffold a read-only CDS model for S/4HANA Cloud Private Edition (S/4HANA 2025), following sap-technical-assets/reference/sap-project-standards.md (naming §5) and sap-technical-assets/skills/abap-object-generator/SKILL.md (Mode 2).

Produce as separate named source blocks:
1. CDS interface view(s) `ZI_<Entity>` — released SAP CDS/tables as data sources only, associations exposed, `@Semantics` where relevant, no `@UI`.
2. CDS consumption view `ZC_<Entity>` — projected/calculated fields, `@Metadata.allowExtensions: true`, `@AccessControl.authorizationCheck: #CHECK`.
3. For an analytical model: add `@Analytics.dataCategory`, `@ObjectModel` on the interface view, measures/dimensions annotated.
4. Metadata extension `ZC_<Entity>` (.ddlx) if it backs a Fiori elements list/analytical page.
5. DCL `ZDCL_<Entity>` — base row-level restrictions on a released authorization CDS/aspect.

Rules:
- Released APIs only; no direct SAP table SELECT outside released CDS; language version *ABAP for Cloud Development*.
- No behavior — read only.
- Don't invent field names — mark unknowns `[CONFIRM in ADT]`.
- End with the released-dependency list and their assumed API state.

Requirement / entity description:
${selection}
