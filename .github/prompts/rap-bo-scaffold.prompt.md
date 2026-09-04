---
mode: 'ask'
description: 'Scaffold a full ABAP Cloud RAP Business Object (CDS + metadata extension + behavior definition + implementation + service definition/binding) from the selected FS text or entity description.'
---
Scaffold a complete RAP Business Object for S/4HANA Cloud Private Edition (S/4HANA 2025), following sap-technical-assets/reference/sap-project-standards.md (naming §5, abapGit layout §6) and sap-technical-assets/skills/abap-object-generator/SKILL.md (Mode 1).

Produce every artifact as a separate, named source block, each headed by a comment with the object name, type, and FS/requirement ID:
1. CDS interface view(s) `ZI_<Entity>` — root + children, associations to released SAP entities.
2. CDS projection view `ZC_<Entity>` (`provider contract transactional_query`).
3. Metadata extension `ZC_<Entity>` (.ddlx) — all `@UI` here, not inline.
4. Behavior definition `ZI_<Entity>` — `managed`, `with draft` (UI service), `strict ( 2 )`, `implementation in class ZBP_I_<Entity> unique`, `mapping for` the DB table; declare determinations/validations/actions traced to business rules R1, R2…
5. Behavior implementation class `ZBP_I_<Entity>` — local handler + saver, one method per rule, `READ/MODIFY ENTITIES` only, results via MAPPED/REPORTED/FAILED, `TODO(Rn)` where the FS is not explicit.
6. Service definition `ZUI_<Entity>` + service binding `ZUI_<Entity>_O4` (OData V4).
7. DCL `ZDCL_<Entity>` only if row-level auth applies.

Rules:
- Language version *ABAP for Cloud Development*; released APIs only; Clean ABAP style; no `SELECT` in loops; exception classes not `sy-subrc` swallow; no forbidden classic syntax.
- Do not invent SAP field/table names — mark unknowns `[CONFIRM in ADT]`.
- End with a "verify before activation" list of every released API/CDS/table used with its assumed API state, and note to run sap-technical-assets/.github/prompts/abap-unit-test.prompt.md next.

FS text / entity description:
${selection}
