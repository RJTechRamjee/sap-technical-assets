# S/4HANA Simplification — FS Review Red Flags

Most functional specs on a transformation are written by consultants with ECC
muscle memory. This file is the scan list: **spot the ECC artifact, name the
S/4HANA 2025 reality, and say what the FS should have said instead.**

Severity in an FS review:
🔴 the design cannot be built as written · 🟠 buildable but wrong target model or
technical debt · 🟡 wording/technical-name correction.

Always confirm the specific item against the **SAP Simplification Item Catalog**
for the target release before quoting it in a formal review.

---

## 1. Data model and tables

| Spotted in the FS | S/4HANA 2025 reality | What the FS should say | Sev |
|---|---|---|---|
| `VBUK` / `VBUP` (status tables) | **Removed.** Status fields moved into `VBAK`/`VBAP`/`LIKP`/`LIPS`/`VBRK` | read status from the document tables, or the released status CDS views | 🔴 |
| `KONV` (document conditions) | **Renamed to `PRCD_ELEMENTS`** | read pricing results via a released CDS view | 🔴 |
| `LIKP`/`LIPS` status via `VBUK` join | same as above | header/item status fields directly | 🔴 |
| `BSID`/`BSAD`/`BSIS`/`BSAS`/`BSEG`-driven logic | **Universal Journal `ACDOCA`**; the classic tables survive as compatibility views only | source from `ACDOCA` / released FI CDS views | 🟠 |
| `MSEG`-heavy material document logic | **`MATDOC`** | released material document CDS | 🟠 |
| `MARA-MATNR` assumed 18 chars | **`MATNR` extended to 40** | field length 40 everywhere, incl. interfaces and forms | 🔴 |
| `KNA1`/`LFA1` maintained directly | **Business Partner + CVI** is the master; these are synchronised | BP with role `FLCU00`/`FLCU01` | 🟠 |
| LIS / SIS structures (`S0xx`), `VBOX` | **Removed / not the reporting model** | CDS-based embedded analytics | 🔴 |
| Direct `SELECT` on `VBAK`/`VBAP`/`VBRK` in new code | allowed technically in PCE, **not Clean Core** | released CDS views (`[CONFIRM in ADT]`) | 🟠 |

---

## 2. Processes and applications

| Spotted in the FS | S/4HANA 2025 reality | What the FS should say | Sev |
|---|---|---|---|
| **SD rebate agreements** (`VBO1`, rebate agreement types) | Replaced by **Condition Contract Settlement Management** (`WCOCO`) | condition contract, business volume, settlement type | 🔴 |
| **Credit management via `FD32`, `KNKA`/`KNKK`, `OVA8`** | Replaced by **SAP Credit Management (FSCM)** | BP role `UKM000`, credit segment, BRFplus credit rules | 🔴 |
| **Output via `NACE`/`NAST`/condition-technique output types** | **Output Control (BRFplus)** is the target framework | output parameter determination, form template, channel — and state explicitly which framework applies | 🔴 |
| SAPscript / Smart Forms for new forms | **Adobe form templates** (Maintain Form Templates) | Adobe-based template, owner named | 🟠 |
| Classic ATP, rescheduling `V_V2` | **aATP**: PAC, product allocation, BOP, ABC, Release for Delivery | which aATP capability is in scope | 🟠 |
| Classic product allocation | **aATP Product Allocation (PAL)** | allocation object/sequence design | 🟠 |
| **SD revenue recognition `VF44`/`VF45`** | **Event-Based Revenue Recognition** or **RAR** | which revenue model, and its billing impact | 🔴 |
| Foreign trade handled inside SD | **SAP GTS** | GTS integration scope | 🟠 |
| `LE-TRA` transportation, shipment documents | **embedded SAP TM** | TM scope and integration | 🟠 |
| Classic **WM** for a new build | **EWM** (WM is not the go-forward model) | EWM (embedded or decentralised) | 🟠 |
| `XD01`/`VD01`/`XK01`/`MK01` for master data | **`BP` only**, with CVI | BP role and grouping | 🟠 |
| Batch input / BDC / `CALL TRANSACTION` on `VA01` | not an acceptable build pattern | released API (OData/SOAP), IDoc, or RAP | 🔴 |
| Classic dynpro screen / module pool for a new UI | **Fiori** (elements first) | Fiori app type and service | 🔴 |
| Classic ALV report as the deliverable | **CDS view + Fiori elements / embedded analytics** | analytical or list report app | 🟠 |
| `MV45AFZZ`, `USEREXIT_*`, `RV60AFZZ`-style user exits | classic enhancement = **Tier 4** | released BAdI, or a documented exception | 🔴 |
| **VOFM** requirement / formula / data transfer routine | classic modification = **Tier 4** | configuration alternative, or released extension point, or documented exception | 🔴 |
| Append structure + implicit enhancement for a custom field | **key-user field extensibility** | custom field via extensibility, propagated to the follow-on documents | 🟠 |
| Custom Z-table of prices/discounts | condition records with validity, scales, release status | condition table + access sequence | 🟠 |
| Custom Z status table / Z log table | document status fields, application log, change documents | standard status/logging | 🟡 |

---

## 3. Wording and technical-name corrections (🟡, but they signal ECC drafting)

| FS says | Correct for S/4HANA 2025 |
|---|---|
| "material master" as the object of a Fiori app | **Product** (the master data is still material tables) |
| "customer master transaction XD01" | Business Partner (`BP`), role `FLCU01` for sales |
| "credit control area limit" | credit **segment** limit in FSCM |
| "output type RD00 in NACE" | output parameter determination in Output Control (unless classic NAST genuinely applies to that object in PCE — then say so) |
| "SD rebate accrual" | condition contract accrual / settlement |
| "KONV-KWERT" | `PRCD_ELEMENTS` field, read via released CDS |
| "status from VBUK-GBSTK" | overall status field on `VBAK` |
| "custom pricing routine 9xx" | condition configuration, or a released pricing extension point, or a Tier-4 exception |

---

## 4. How to use this in a review

1. Scan the FS for every technical name, transaction and process term.
2. Match against the tables above; each hit becomes a finding with its severity.
3. For 🔴 items, the FS **cannot be signed off as written** — the target model
   itself is wrong, so effort estimates and technical design built on it are void.
4. For each finding, give the replacement design in one line, not just the flag.
5. If an item is release-sensitive, check the **Simplification Item Catalog** for
   S/4HANA 2025 before asserting it, and say when you haven't.

**Do not over-flag.** `VBAK`, `VBAP`, `VBEP`, `VBPA`, `VBKD`, `VBFA`, `LIKP`,
`LIPS`, `VBRK`, `VBRP`, `KNA1`, `KNVV`, `MARA`, `MARC`, `MVKE`, `KONH`, `KONP`
and the `A*` condition tables all still exist. The issue with these is Clean Core
access (use released CDS), not existence.
