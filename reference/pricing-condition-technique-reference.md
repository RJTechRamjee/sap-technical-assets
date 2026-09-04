# Pricing & Condition Technique — Architect's Reference

Pricing generates more "we need custom development" requests than any other L2C
area, and most of them are configuration. This file is the depth needed to
challenge a functional spec and design the compliant alternative.

Companions: `l2c-standard-process-reference.md`, `fit-to-standard-patterns.md`,
`s4hana-simplification-redflags.md`. Platform rules: `sap-project-standards.md`.

**Accuracy discipline:** classic config objects, tables and transactions below are
stable. **Released pricing BAdI / CDS / API technical names are deliberately not
asserted** — verify in ADT (API state) or the Business Accelerator Hub for
S/4HANA 2025 and write `[CONFIRM in ADT]` until you have.

---

## 1. The five layers

```
Field catalogue          which fields may be used as condition keys
   ↓
Condition table  V/03    a key combination, e.g. customer/material, price list/material
   ↓
Access sequence  V/07    ordered list of condition tables, with requirements & exclusive flag
   ↓
Condition type   V/06    a price / discount / surcharge / freight / tax element
   ↓
Pricing procedure V/08   the ordered calculation, with requirements, formulas, account keys
   ↓
Procedure determination OVKK
```

**Procedure determination (`OVKK`) key:**
Sales org + Distribution channel + Division + **Document pricing procedure**
(from the sales document type, `TVAK-KALVG`) + **Customer pricing procedure**
(`KNVV-KALKS`) → pricing procedure.

That's the lever for "this customer group must be priced differently" — a
customer pricing procedure, not code.

---

## 2. Condition type controls (`V/06`) — what each switch buys you

| Control | What it decides | Why it matters in FS review |
|---|---|---|
| **Condition class** | `A` price · `B` discount/surcharge · `C` expense reimbursement · `D` taxes | Determines where in the procedure it can sit and how it's treated |
| **Calculation type** | `A` percentage · `B` fixed amount · `C` quantity · `D` gross weight · `E` net weight · `F` volume · `G` formula | "Charge per kg" / "per pallet" is a calculation type, not code |
| **Condition category** | tax, freight, basic price, etc. | Drives downstream handling (e.g. tax, delivery costs) |
| **Plus/minus** | positive, negative, or both | Stops a "discount that can also be a surcharge" needing two types |
| **Item / header condition** | item-level, header-level, or header with distribution | "Apply a discount to the whole order" = header condition + group distribution |
| **Group condition** | value/quantity accumulated across items before scale lookup | The answer to "give the scale price based on total order quantity" |
| **Scale basis** | `B` quantity · `C` value · `D` gross weight · `E` net weight · … | Volume/tier pricing without code |
| **Scale type** | from-scale / to-scale, graduated | Graduated (interval) scales are standard |
| **Manual entries** | not possible / possible / manual only | Controls negotiated overrides |
| **Amount/value, delete** | whether a user can change or remove it | Governance without custom authorization checks |
| **Accruals** | posts to an accrual account | Rebates/commissions |
| **Reference condition type / reference application** | reuse another type's records | Avoids duplicate condition maintenance |
| **Condition exclusion** | exclusion indicator + exclusion groups | "Best price wins" logic without code |
| **Validity default** | proposed valid-from | Small but frequently specified wrong |

**Before accepting "we need a custom condition routine", walk this table.** Most
pricing requirements are a combination of calculation type, group condition,
scale basis and exclusion.

---

## 3. Pricing procedure columns (`V/08`) — read them like code

| Column | Meaning |
|---|---|
| Step / Counter | order of calculation |
| CTyp | condition type |
| From / To | reference steps — the base a percentage applies to, or a subtotal range |
| Manual | condition is not determined automatically |
| Required | document is incomplete without it |
| Statistical | shown but not added to the net value |
| Print | print control on output |
| **Subtotal** | writes the value into a `KZWI1..6` field for later reuse/reporting |
| **Requirement** | routine deciding whether the condition is found at all |
| **AltCTy** (alternative calculation type) | routine that **computes the condition value** instead of the standard calculation |
| **AltCBV** (alternative condition base value) | routine that **computes the base** the condition applies to |
| **AccKey** | account key → `VKOA` → G/L account |
| **Accrls** | accrual key |

### The Clean Core trap
**Requirement, AltCTy and AltCBV are VOFM routines** — classic modifications in
the SAP namespace with customer routine numbers. In a Clean Core project they are
**Tier 4 (documented exception)**, not a normal build option.

When an FS proposes pricing logic that implies a new routine, the architect's job
is to answer in this order:

1. **Can configuration do it?** — a different calculation type, a group condition,
   a scale basis, condition exclusion, a new access with an extra key field, a
   statistical condition plus a subtotal, or a second condition type.
2. **Can a standard routine do it?** — many delivered requirements and formulas
   already cover common cases; check the existing routine list before creating one.
3. **Can key-user extensibility do it?** — a custom field added to the pricing
   field catalogue via key-user extensibility, then used as a condition key, is
   Tier 1 and needs no ABAP.
4. **Is there a released pricing BAdI / custom-logic extension point** for this
   release? In S/4HANA Cloud the pricing extension points are exposed as *Custom
   Logic* business contexts (condition value, base value, requirement-style checks).
   In Private Edition, verify what is released for S/4HANA 2025 in ADT —
   `[CONFIRM in ADT]` — and use it as Tier 2.
5. **Only then** a VOFM routine, recorded as a Tier-4 exception with owner and
   remediation target.

Never let an FS say "add a pricing routine" without this ladder being walked in
the Clean Core section.

---

## 4. Condition records and their storage

- Maintained with `VK11` / `VK12` / `VK13` (and the Fiori *Manage Prices* apps).
- **`KONH`** header, **`KONP`** item, scales in **`KONM`** (quantity) /
  **`KONW`** (value).
- Access tables are the `A*` tables generated per condition table (e.g. `A004`
  material, `A005` customer/material) — a condition table's technical name is
  `Annn`.
- Records carry **validity period, scales, release status, and authorization** —
  the reason a "Z-table of prices" is almost always the wrong design.
- **Document pricing results**: `KONV` no longer exists — the table is
  **`PRCD_ELEMENTS`**. Read it through a released CDS view, never by direct SELECT.

---

## 5. Pricing type in copy control — the most under-specified field in billing FSs

Set per item in `VTFL` (delivery→billing) and `VTFA` (order→billing). It decides
what happens to pricing when the follow-on document is created:

| Type | Behaviour |
|---|---|
| `A` | copy price components **unchanged** |
| `B` | carry out **new pricing** |
| `C` | copy **manual** pricing elements, redetermine the rest |
| `D` | copy pricing **unchanged** (including manual) |
| `E` | adopt price components and **fix the values** |
| `G` | copy pricing elements unchanged, **redetermine taxes** |
| `H` | copy unchanged, **redetermine freight** |

Confirm the full list for your release in copy control. Nearly every
"the invoice price doesn't match the order" defect and every "we need custom
repricing logic" request resolves to this field plus condition validity dates.

**Manual repricing** in a document is available via the *Update* button on the
conditions tab, using the same pricing types.

---

## 6. Taxes

- Output tax condition `MWST` (plus country-specific types), determined from
  **customer tax classification** (`KNVI-TAXKD`) × **material tax classification**
  (`MLAN-TAXKM`) × departure country × destination country → tax code.
- Tax code drives the FI posting via the tax procedure and account key `MWS`.
- **External tax engines** (Vertex, Avalara, ONESOURCE) plug in through the tax
  interface / a released tax integration rather than a custom condition routine.
  An FS involving multi-jurisdiction US tax must state **which engine and which
  integration**, and whether tax is calculated at order, delivery or billing.
- Plants-abroad, EU triangulation and export scenarios have standard handling —
  challenge custom logic here hard.

---

## 7. Rebates → Settlement Management (a top S/4 red flag)

**Classic SD rebate agreements (`VBO1`/`VBO2`, rebate agreement types, rebate-relevant
billing types) are not the S/4HANA target model.** The successor is
**Condition Contract Settlement Management**:

- **Condition contract** (`WCOCO`) holds the eligibility, condition records,
  business volume selection criteria and settlement calendar.
- **Business volume determination** aggregates the qualifying sales.
- **Settlement types**: partial, delta accruals, final settlement — producing
  settlement documents that post to FI.
- Covers customer rebates, supplier rebates, commissions and royalties in one
  framework.

An FS specifying accrual logic, retro-active rebate calculation, or a custom
"rebate accrual table" is nearly always a condition contract design that hasn't
been recognised. Push it back before any build is estimated.

---

## 8. Free goods and other pricing-adjacent standards

| Requirement | Standard mechanism |
|---|---|
| Buy 10 get 1 free (inclusive or exclusive) | Free goods, `VBN1`, procedure `NA00`, item category `TANN` |
| Best of several discounts only | Condition exclusion groups + exclusion indicator |
| Minimum order value surcharge | Condition type with a requirement + scale, or `AMIW`/`AMIZ`-style minimum value handling |
| Price list per customer group | Price list type (`KNVV-PLTYP`) as a condition key field |
| Currency and unit conversion | Condition type currency conversion + condition exchange-rate type |
| Cost/profit margin display | Statistical condition (`VPRS` cost) plus a subtotal for margin |
| Promotional / campaign pricing | Validity-dated condition records; sales deal / promotion objects |
| Customer-expected price check | Order incompleteness/blocking via expected price fields (`VBAP` expected value fields) |

---

## 9. Diagnosing before designing

Before accepting any pricing defect or gap as a development:

1. Run **Pricing Analysis** on the document (conditions tab → *Analysis*). It
   shows, per condition type, which access was tried, which key was used and why
   a record was or wasn't found. Most "pricing bugs" are a missing condition
   record or a failed access, not a code defect.
2. Check the **condition record validity** and release status.
3. Check the **procedure determination** (`OVKK` key) actually resolves to the
   procedure the requester assumes.
4. Check **copy control pricing type** if the complaint is about a follow-on document.
5. Only then consider requirements/formulas or an extension point.

Teach this ladder to the team — it is a strong COE session on its own.

---

## 10. Extensibility summary for pricing

| Need | Tier | Mechanism |
|---|---|---|
| New key combination for pricing | 0 | New condition table + access sequence entry |
| Custom field as a pricing key | 1 | Key-user field extensibility, field added to the pricing field catalogue |
| Different calculation, scale or exclusion behaviour | 0 | Condition type configuration |
| Rebate/commission/royalty | 0 | Condition contract settlement management |
| Logic that genuinely needs code at condition level | 2 | Released pricing extension point / custom logic BAdI — `[CONFIRM in ADT]` for S/4HANA 2025 |
| Pricing driven by data outside S/4 | 3 | Side-by-side service called via a released API, or replicate the data and price in-system |
| New VOFM requirement / AltCTy / AltCBV routine | **4** | Documented exception only: justification, owner, ATC allowlist, remediation target |
