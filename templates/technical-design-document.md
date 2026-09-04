# Technical Design Document (TDD)

> The architect's build-ready deliverable. Written **from** an approved/reviewed
> Functional Specification, **for** an offshore ABAP developer who was not in the
> workshop. If a developer has to ask you a question to start building, this
> document isn't finished.
>
> Naming, packages, language scope and released-API rules:
> `reference/sap-project-standards.md`. Placeholders: `[CONFIRM]`,
> `[ASSUMPTION — confirm]`, `N/A` — never a blank.

## 1. Header

| Field | Value |
|---|---|
| TDD ID | |
| Title | |
| Process area | Lead-to-Cash / SD / Invoicing |
| Source FS (ID / version) | |
| FS review report | |
| Related SDD / ADRs | |
| Author (architect) | |
| Reviewer | |
| Status | Draft / In Review / Approved / Build / Built |
| Target platform | S/4HANA Cloud Private Edition — S/4HANA 2025 |
| Language version | ABAP for Cloud Development |
| Software component / package | |
| Transport request | |

## 2. Solution Overview

One or two paragraphs: what is being built, the design approach in plain terms,
and the single most important design decision. A developer should be able to read
only this and know the shape of the work. Reference the architecture diagram if
there is one.

**Business rules implemented** — list the FS rule IDs this TDD covers (R1, R2…).
Anything in the FS *not* covered here must be listed as out of scope with a reason.

## 3. Clean Core & Extensibility Decision

| Question | Answer |
|---|---|
| Extensibility tier | 0 config · 1 key-user · 2 developer ABAP Cloud · 3 side-by-side · 4 classic exception |
| Mechanism (named concretely) | |
| Why the tier above was insufficient | |
| Released APIs / CDS / BAdIs relied on | see §8 |
| Any non-released object touched? | If yes → this is a Tier-4 exception, complete the row below |
| Upgrade-stability risk | Low / Medium / High + why |

**Tier-4 exception (only if applicable):** justification · owner · ATC allowlist
entry · remediation target release. Otherwise `N/A`.

## 4. Object Inventory

Every object to be created or changed. Naming per `sap-project-standards.md` §5.

| # | Object name | Type | New/Change | Package | Purpose | FS rule(s) |
|---|---|---|---|---|---|---|
| 1 | `ZI_<Entity>` | CDS interface view | New | | | R1 |
| 2 | `ZC_<Entity>` | CDS projection view | New | | | |
| 3 | `ZC_<Entity>` (.ddlx) | Metadata extension | New | | | |
| 4 | `ZI_<Entity>` (.bdef) | Behavior definition | New | | | |
| 5 | `ZBP_I_<Entity>` | Behavior implementation class | New | | | |
| 6 | `ZUI_<Entity>` / `ZUI_<Entity>_O4` | Service definition / binding | New | | | |
| 7 | `Z<Entity>` | Database table (+ draft table if draft-enabled) | New | | | |
| 8 | `ZCL_…` / `ZIF_…` / `ZCX_…` | Class / interface / exception | | | | |
| 9 | `ZDCL_…` | Access control (DCL) | | | | |
| 10 | message class / BAdI impl / iFlow | | | | | |

## 5. Data Model & CDS Design

- **Persistent entities** — table name, key fields, semantic fields, data elements,
  currency/quantity reference fields, admin fields (created/changed by/at).
- **Associations** — to released SAP entities (name them; API state in §8) and
  between own nodes, with cardinality.
- **CDS layering** — interface view(s) → projection view; what is exposed and what
  is deliberately not.
- **Annotations** — `@Semantics`, `@ObjectModel`, `@AccessControl.authorizationCheck`,
  `@Metadata.allowExtensions`. UI annotations live in the metadata extension, not inline.
- **Draft** — draft-enabled? draft table name (ADT-generated database table, per
  project convention) and total-etag/lock field.

| Field | Type / data element | Key | Mandatory | Source | Notes |
|---|---|---|---|---|---|

## 6. RAP Business Object Design

| Aspect | Design |
|---|---|
| Implementation type | managed / unmanaged / managed with unmanaged save + reason |
| Strict mode | `strict ( 2 )` |
| Draft | enabled / not, and why |
| Root and child nodes | |
| Numbering | early / late, internal / external |
| ETag / lock | master / dependent |
| Authorization | `authorization master ( instance )` / global, and what it checks |

### Behavior logic — one row per FS rule

| FS rule | Type | Name | Trigger (`on save` / `on modify`) | Logic summary | Failure message |
|---|---|---|---|---|---|
| R1 | validation | `validate…` | on save | | |
| R2 | determination | `determine…` | on modify | | |
| R3 | action | `…` | | result parameter, side effects | |

Rules for the implementer: read/write only via `READ ENTITIES` / `MODIFY ENTITIES`;
results only into `MAPPED` / `REPORTED` / `FAILED`; no `COMMIT`, no side effects
outside the save sequence; messages from the message class in §12.

## 7. Class & Method Design (non-RAP logic)

For each class: purpose, interface implemented, public methods with
signature and one-line contract, dependencies injected (for testability), and
what is deliberately kept out of the class (e.g. database access).

| Class / Interface | Method | Signature (importing / returning / raising) | Contract |
|---|---|---|---|

Design rules: business logic separated from data access so it is unit-testable;
exception class hierarchy (`ZCX_*`), no `sy-subrc` swallowing; no static mutable state.

## 8. Released API / Dependency Register

**Every** SAP object consumed. Verify API state in ADT before build starts.

| SAP object | Type | Used for | API state | Verified how / when |
|---|---|---|---|---|
| | CDS / BAdI / class / API | | Released / Released with restrictions / **[CONFIRM in ADT]** | ADT release contract / Accelerator Hub |

A dependency that turns out **not released** stops the build and returns to §3.

## 9. UI Design

- App type: Fiori elements (list report / object page / analytical) or freestyle — and why.
- Service definition/binding used; UI annotations in the metadata extension
  (`@UI.lineItem`, `@UI.selectionField`, `@UI.facet`, field groups).
- Actions exposed on the UI, and their confirmation/messaging behaviour.
- Value helps (released CDS value help views), text associations.
- Launchpad: business catalog, IAM app, tile — or `N/A`.

## 10. Interface / Integration Design

For each interface: reference the filled `interface-spec-template.md`, plus the
in-system side — which RAP action or event raises it, the released API consumed,
payload mapping owner, and error/replay handling. `N/A` if none.

| Interface ID | Direction | Pattern | Released API / event | Spec link |
|---|---|---|---|---|

## 11. Authorization & Security Design

| Aspect | Design |
|---|---|
| Restriction model (RAP instance authorization) | what is checked, on which fields |
| DCL / access control | role name, based on which released authorization aspect |
| Authorization objects / fields | |
| Business catalog / role assignment | |
| Communication user & scenario (for inbound APIs) | |
| Sensitive data handling (masking, logging exclusions) | |

## 12. Messages & Error Handling

- Message class and the message numbers used, with text and severity.
- Which failures are validation messages (`REPORTED`) vs hard failures (`FAILED`)
  vs exceptions.
- User-facing wording: says what to do, not just what went wrong.
- Application logging: what is logged, where it is read.

| Msg no. | Type | Text | Raised by | FS rule |
|---|---|---|---|---|

## 13. Performance & Volume Design

| Concern | Expected | Design response |
|---|---|---|
| Records processed per run / peak | | set-based reads, no SELECT in loop |
| Online response target | | |
| Mass/background processing | | package size, parallelization, restart behaviour |
| Table types / buffering | | HASHED/SORTED for lookup-heavy logic |
| Analytical volume | | CDS design, aggregation pushdown |

## 14. Unit Test Design

| FS rule | Test method | Framework | Doubles needed |
|---|---|---|---|
| R1 | `validate_rejects_…` | `cl_abap_behv_test_environment` | behavior double |
| | | `cl_cds_test_environment` / `cl_osql_test_environment` / `cl_abap_testdouble` | |

Coverage expectation: every FS rule has at least one test; unhappy paths and
boundary cases included; tests deterministic and DB-free. See
`abap-unit-test-writer`.

## 15. Build Sequence & Transport Plan

Ordered steps a developer follows, with dependencies:

1. Create package(s) and transport request.
2. Database table(s) and data elements.
3. CDS interface view(s) → projection view → metadata extension.
4. Behavior definition → behavior implementation class (generate skeleton in ADT).
5. Implement determinations / validations / actions per §6.
6. Service definition → service binding → activate/publish.
7. DCL and authorization objects.
8. ABAP Unit tests per §14.
9. ATC run clean (ABAP Cloud variant) before handover.

| Transport | Contents | Dependency |
|---|---|---|

## 16. Open Technical Questions

| # | Question | Owner | Blocking build? | Due |
|---|---|---|---|---|

## 17. Sign-off

| Role | Name | Date |
|---|---|---|
| Architect (author) | | |
| Technical reviewer | | |
| Development lead | | |
