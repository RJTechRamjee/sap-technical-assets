# SAP Project Standards — Ground Truth for All Skills

Every skill, prompt, and template in this repo assumes what is written here unless
the user overrides it for a specific task. When a skill needs a platform fact
(target release, extensibility tier, naming, released-API rule), it cites this
file instead of re-deriving or hedging. Keep this file current; it is the single
place to change a project-wide assumption.

---

## 1. Platform baseline

| Aspect | Assumption |
|---|---|
| Product | SAP S/4HANA Cloud **Private Edition** (PCE), also valid for on-prem S/4HANA |
| Release | **S/4HANA 2025** |
| Primary build model | **ABAP Cloud** (language version *ABAP for Cloud Development*), developed in ADT / Eclipse |
| Landscape | 3-system transport track (DEV → QAS → PRD) via TMS; abapGit for source sharing where used |
| UI | SAP Fiori (RAP → OData V4), Fiori elements first, freestyle UI5 only where justified |
| Integration platform | SAP Integration Suite (Cloud Integration / API Management / Event Mesh) |
| Side-by-side platform | SAP BTP, ABAP or CAP environment |

If the user says the engagement is **Public Edition**, tighten every rule below to
"released APIs only, no classic fallback, key-user + developer extensibility only",
and treat any classic-ABAP option as unavailable rather than exception-gated.

---

## 2. Clean Core — the six dimensions

Assess and keep clean on all six, not just custom code:

1. **Software stack** — stay close to standard; no core modifications.
2. **Extensions** — decoupled, released-API-only, upgrade-stable (see §3).
3. **Data** — no direct writes to SAP tables; consistent master data; archiving strategy.
4. **Integrations** — released APIs / events only; via Integration Suite, not point-to-point RFC hacks.
5. **Processes** — prefer SAP standard process flows; configure before you extend.
6. **Operations** — monitoring, job scheduling, and housekeeping use standard tooling.

A "Clean Core assessment" in any FS/SDD/ADR must state a position on each dimension
that the requirement touches, not only dimension 2.

---

## 3. Extensibility decision — tier order for PCE

Always justify why the tier above was not sufficient before choosing the next one.

| Tier | What | When |
|---|---|---|
| 0. **Standard config / BRFplus** | IMG, output determination, condition technique, business rules | Default first stop for every requirement |
| 1. **Key-user in-app** | Custom fields, custom logic (RAP BAdI), custom CDS views, custom business objects, adaptation of Fiori | Simple field/logic extensions, no lifecycle concerns |
| 2. **Developer extensibility (ABAP Cloud, on-stack)** | New RAP BOs, released-API classes, released BAdI implementations, wrap-and-extend released CDS | Real developer logic that belongs inside S/4 and only depends on released APIs |
| 3. **Side-by-side (BTP)** | RAP/CAP on BTP, talking to S/4 via released OData V4 / SOAP / events through Integration Suite | Logic to decouple from the S/4 upgrade cycle, non-SAP integration, heavy custom UI, cross-system orchestration |
| 4. **Classic extensibility** (user-exit, enhancement, BAdI on non-released object, access to non-released API) | — | **Only** when no released alternative exists in 2025. Requires a dated, signed exception in the ADR, an owner, an ATC allowlist entry, and a remediation target release. Never the default, never a silent shortcut. |

PCE allows Tier 4 technically; this repo treats it as an exception path, not a
convenience. Tier 2 code must compile under language version *ABAP for Cloud
Development* even though the system would also accept *Standard ABAP*.

---

## 4. ABAP Cloud language & API rules

- Language version **ABAP for Cloud Development** for all new objects in Tier 1–3.
- **Released APIs only.** Before using any SAP table, CDS view, class, function
  module, or BAdI: confirm API State = *Released* (see §7). A non-released object
  is off-limits even if it compiles today.
- Forbidden in new code: `EXPORT/IMPORT … TO MEMORY`, `GENERATE SUBROUTINE POOL`
  and dynamic program generation, classic dynpro (`CALL SCREEN`, `CALL DIALOG`),
  `NATIVE SQL` / `EXEC SQL`, `CALL TRANSACTION`, `SUBMIT` of classic reports,
  direct `AUTHORITY-CHECK` on non-released objects, `PERFORM` / VOFM-style
  routine mods.
- Persistence: released CDS for read, RAP BOs for transactional write. No direct
  `SELECT/INSERT/UPDATE/DELETE/MODIFY` on SAP-owned tables.
- Eventing: Enterprise Event Enablement (RAP raise-event / released business events).

---

## 5. Naming conventions

Customer namespace: `Z` (switch to the client's reserved namespace if the project
has one — the user will say so).

| Object | Pattern | Example |
|---|---|---|
| CDS interface view | `ZI_<Entity>` | `ZI_BillingRequestItem` |
| CDS projection / consumption view | `ZC_<Entity>` | `ZC_BillingRequestItem` |
| CDS extend view | `ZE_<Entity>` | `ZE_SalesOrderItem` |
| Metadata extension | same as projection view | `ZC_BillingRequestItem` |
| Behavior definition | same as root interface view | `ZI_BillingRequest` |
| Behavior implementation class | `ZBP_I_<Entity>` (RAP convention `ZBP_` + interface view) | `ZBP_I_BillingRequest` |
| Service definition | `ZUI_<Entity>` / `ZAPI_<Entity>` | `ZUI_BillingRequest` |
| Service binding | `ZUI_<Entity>_O4` (OData V4 UI) / `ZAPI_<Entity>_O4` | `ZUI_BillingRequest_O4` |
| Global class | `ZCL_<area>_<purpose>` | `ZCL_L2C_PRICING_VALIDATION` |
| Interface | `ZIF_<area>_<purpose>` | `ZIF_L2C_PRICING_STRATEGY` |
| Exception class | `ZCX_<area>_<purpose>` | `ZCX_L2C_BILLING` |
| ABAP Unit test class | `ZCL_<...>_TEST` or local `ltcl_*` inside the class pool | `ltcl_pricing_validation` |
| Released-BAdI impl class | `ZCL_<area>_<badi>_IMPL` | `ZCL_L2C_PRICE_ELEMENT_IMPL` |
| Package (structure) | `ZL2C` → subpackages `ZL2C_SD`, `ZL2C_BILLING`, `ZL2C_INT` | |

RAP BOs are **draft-enabled** for UI services, **draft-disabled** for API-only
services, unless the requirement says otherwise.

---

## 6. abapGit object-set layout (what "full object set" means)

When a skill generates a complete RAP object, it produces these as separate,
named source blocks/files so they can be pasted into ADT or committed via abapGit:

```
zi_<entity>.ddls.asddls               CDS interface view(s) (root + children)
zc_<entity>.ddls.asddls               CDS projection / consumption view
zc_<entity>.ddlx.asddlx               Metadata extension (UI annotations)
zi_<entity>.bdef.asbdef               Behavior definition (managed/unmanaged)
zbp_i_<entity>.clas.abap              Behavior implementation class (+ local handler/saver classes)
zui_<entity>.srvd.srvdsrv             Service definition
zui_<entity>_o4.srvb.xml              Service binding (OData V4)
zdcl_<entity>.dcls.asdcls             Access control (DCL) — when row-level auth applies
zcl_<...>_test.clas.testclasses.abap  ABAP Unit test class (see abap-unit-test-writer)
```

Every generated block starts with a one-line comment: object name, type, and the
FS/requirement ID it implements.

---

## 7. How to verify an API/object is "Released"

In order of preference:

1. **ADT MCP** (if connected) — read the object and check its release contract /
   API state; see `reference/adt-mcp-usage.md`.
2. **ADT manually** — Properties → API State = *Released* / *Released with
   restrictions*; or the *Released Objects* app / `RUTDDLS_RELSTATE`-style checks.
3. **SAP Business Accelerator Hub** — the object appears with a stable contract.
4. **SAP Help release info for 2025** — the CDS view / BAdI / API is listed as
   released for the target release.

If it can only be reached via SE11/SE80/SE37 with no released wrapper: treat as
**not released** and route to §3 Tier 3/4.

---

## 8. Output placeholder conventions (all skills)

- `[CONFIRM]` — a fact the build team needs that the input didn't provide.
- `[ASSUMPTION — confirm]` — a value the skill inferred to keep moving; must be flagged, never silent.
- `N/A` — deliberately not applicable (write it, don't leave blank).
- Never invent SAP table names, field names, BAPI signatures, or release dates.
  If unsure, say how to verify (ADT Where-Used, Accelerator Hub) instead of guessing.

---

## 9. Domain scope

Primary process area for this repo: **Lead-to-Cash / Sales (SD) / Invoicing** —
inquiry/quotation → sales order → delivery → billing → payment/dunning, condition
technique for pricing, output determination (BRFplus), billing document types,
credit management, invoice correction (ICR), intercompany and convergent/
high-volume billing, FI-CA where telco/utilities.
