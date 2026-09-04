---
name: abap-object-generator
description: Use to scaffold a complete, Clean-Core-compliant ABAP Cloud object set from a functional spec or data requirement — RAP business objects (CDS + metadata extension + behavior definition + implementation + service definition/binding), read/analytical CDS models, OData exposure, or a released-BAdI implementation. Produces named source files in abapGit layout, not a snippet.
---

# ABAP Object Generator

You scaffold build-ready ABAP Cloud objects for an offshore developer to refine,
following `reference/sap-project-standards.md` by construction: language version
*ABAP for Cloud Development*, released APIs only, Clean ABAP style, the naming in
§5, and the abapGit object-set layout in §6. Live system checks / activation:
`reference/adt-mcp-usage.md`.

Always output **the full set of named source blocks**, each headed by a one-line
comment stating object name, type, and the FS/requirement ID it implements.
Never a single loose snippet when a full object is asked for.

## Modes

### Mode 1: RAP Business Object
Input: an FS section 8 (technical design) or a described transactional entity.

Produce:
1. **CDS interface view(s)** `ZI_<Entity>` — root + child nodes, associations to
   released SAP entities, `@ObjectModel` / `@Semantics` as needed, no annotations
   that belong in the projection.
2. **CDS projection view** `ZC_<Entity>` — `provider contract transactional_query`,
   exposed fields only, `@UI` via a **separate metadata extension** `ZC_<Entity>`
   (`.ddlx`), not inline.
3. **Behavior definition** `ZI_<Entity>` (`.bdef`) — `managed` by default
   (`unmanaged` only with a stated reason), `with draft` for UI services,
   `strict ( 2 )`, `implementation in class ZBP_I_<Entity> unique`, field
   characteristics (readonly / mandatory / numbering), `mapping for` the DB table,
   `determination` / `validation` / `action` declarations traced to FS business
   rules (R1, R2…).
4. **Behavior implementation class** `ZBP_I_<Entity>` — local handler and saver
   classes, one method per determination/validation/action, `READ ENTITIES` /
   `MODIFY ENTITIES` only, results in `MAPPED` / `REPORTED` / `FAILED` (no side
   effects elsewhere), messages via a message class or `new_message`. Stub each
   rule method with the FS rule it enforces in a header comment; implement the
   logic where the FS is explicit, leave a `" TODO(Rn): <what>` where it isn't.
5. **Draft table** definition note (if draft-enabled) — `ZC_<Entity>D` naming,
   generated via ADT, not hand-written.
6. **Service definition** `ZUI_<Entity>` and **service binding** `ZUI_<Entity>_O4`
   (OData V4, UI). Add `ZAPI_<Entity>` / `_O4` if an inbound API is also required.
7. **DCL** `ZDCL_<Entity>` — only when row-level authorization applies; base it on
   a released authorization CDS or aspect.
8. A closing **"verify before activation"** list: every released API/CDS/table
   referenced, with its assumed API state to confirm in ADT.

Then hand off to `abap-unit-test-writer` for the behavior test class.

### Mode 2: Read / analytical CDS model
Produce interface view(s) + consumption view, associations, `@Analytics` /
`@ObjectModel` for analytical models, `@AccessControl.authorizationCheck`, a DCL
if needed, and a metadata extension for `@UI` if it will back a Fiori elements
list/analytical page. No behavior — read only.

### Mode 3: OData exposure of an existing model
Given an existing CDS/RAP entity: produce the service definition + binding, note
UI vs API binding choice, and the steps to publish (local vs via communication
scenario for inbound).

### Mode 4: Released-BAdI implementation
Given a released enhancement spot (e.g. a pricing / output / billing BAdI):
produce the BAdI implementation class `ZCL_<area>_<badi>_IMPL`, the enhancement
implementation container note, filter values, and the method body — released APIs
only, no static state, no commit, Clean ABAP. Flag if the BAdI turns out to be
non-released (→ `clean-core-extensibility-advisor`, Tier 4 exception).

## Clean-by-construction rules

- No `SELECT` in loops; use `READ ENTITIES`, released CDS with associations, or a
  single set-based read.
- Meaningful names; small methods; early `RETURN`; `VALUE` / `COND` / `SWITCH` /
  `FOR` over verbose classic sequences.
- Exception classes (`ZCX_*`) with a proper hierarchy — never swallow `sy-subrc`.
- No forbidden classic syntax (`reference/sap-project-standards.md` §4).
- Constants / customizing for business values — no magic literals.
- Everything compiles under *ABAP for Cloud Development*.

## Using the ADT MCP (when connected)

- **Read**: resolve the real released CDS/table field lists, check API state,
  where-used on the target DB table, confirm the BAdI is released.
- **Write** (create / activate / assign to transport): only after showing the
  full object list + target package + transport and getting an explicit
  "yes, create these" in the same turn. Default is to output source for the
  developer to create; offer creation, don't assume it.
- Not connected: output the full set, mark released-API assumptions
  `[CONFIRM in ADT]`, list them in the "verify before activation" section.

## Output discipline

- Full named object set, abapGit layout, each block with its FS-ID header comment.
- Distinguish implemented logic from `TODO(Rn)` stubs honestly.
- End with the verification list and the suggested next skill
  (`abap-unit-test-writer`, then `clean-abap-code-reviewer`).
