# Lead-to-Cash — Standard SAP Process & Configuration Reference

Working reference for reviewing a functional spec and designing the solution.
For each process step: **what standard SAP already does**, the **config object**
that controls it, **what an FS must specify**, and the **gaps FSs commonly leave**.

Companion files: `pricing-condition-technique-reference.md` (all pricing),
`s4hana-simplification-redflags.md` (ECC→S/4 deltas), `fit-to-standard-patterns.md`
(the challenge catalog). Platform rules: `sap-project-standards.md`.

**Accuracy discipline:** classic config objects, tables and transactions below are
stable and safe to cite. Released **CDS view / BAdI / API technical names are not
listed here** — verify those in ADT or the SAP Business Accelerator Hub for
S/4HANA 2025 and write `[CONFIRM in ADT]` until you have.

---

## 1. The document spine

```
Inquiry (IN) → Quotation (QT) → Sales Order (OR) → Delivery (LF) → Goods Issue → Billing (F2) → Accounting → Payment/Dunning
                                     ↓ contracts, scheduling agreements
                                     ↓ returns (RE), credit/debit memo requests (CR/DR), invoice correction (RK)
```

Document flow is recorded in **VBFA**. Header/item/schedule-line data:
**VBAK / VBAP / VBEP**, partners **VBPA**, business data **VBKD**, delivery
**LIKP / LIPS**, billing **VBRK / VBRP**.
*(Status tables VBUK/VBUP no longer exist — see the red-flags file.)*

Every requirement sits at **one hop** of this chain. First question on any FS:
*which document, which hop, and what is upstream/downstream of it?*

---

## 2. Sales document processing

### 2.1 Document type — `VOV8` / table `TVAK`
Controls: number ranges, screen sequence, incompletion procedure, delivery type,
billing type(s), delivery/billing block defaults, pricing procedure key
(document pricing procedure), partner procedure, text procedure, output procedure,
contract profile, checking group.

Standard types worth knowing: `IN` inquiry, `QT` quotation, `OR` standard order,
`RO` rush order, `CS` cash sale, `RE` returns, `CR` credit memo request,
`DR` debit memo request, `RK` invoice correction request, `KB/KE/KA/KR` consignment
fill-up/issue/pickup/return, `CQ` quantity contract, `WK1/WK2` value contract,
`DS` scheduling agreement.

**FS must specify:** the document type(s) in scope, or that a new Z-type is needed
and why a standard one doesn't fit.
**Common gap:** FS says "sales order" without naming the type — pricing,
incompletion, billing relevance and output all depend on it.

### 2.2 Item category determination — `VOV4` / table `TVAP` (`VOV7` maintains the category)
Key: **Sales document type + Item category group (`MVKE-MTPOS`) + Usage +
Higher-level item category → item category** (plus up to 3 manual alternatives).

Standard categories: `TAN` standard, `TANN` free of charge, `TAS` third-party,
`TAB` individual purchase order, `TAX` non-stock, `REN` returns, `G2N` credit memo,
`L2N` debit memo, `TAP/TAE` BOM header/item, `KBN/KEN` consignment.

Item category controls, among others: **billing relevance (`FKREL`)**, pricing
relevance, schedule-line allowed, delivery relevance, incompletion procedure,
partner/text procedure, credit-active flag, structure scope (BOM explosion),
returns flag.

**This is where most "we need custom logic" claims die** — the behaviour asked
for is usually an item category setting.

### 2.3 Schedule line category — `VOV5` / table `TVEP` (`VOV6` maintains)
Key: **Item category + MRP type → schedule line category.**
Controls: movement type, requirements transfer, availability check, delivery block,
purchase requisition creation (third-party/individual PO), item relevant for delivery.

Standard: `CP` (MRP), `CN` (no MRP), `BN` (no MRP, no goods issue), `BV` cash sale,
`CT`, `CS` third-party.

### 2.4 Copy control — `VTAA` / `VTLA` / `VTFA` / `VTFL` / `VTFF`
Tables `TVCPA` (order→order), `TVCPL` (order→delivery), `TVCPF` (→billing).
Per header/item/schedule-line: **copying requirements**, **data transfer routines**,
**pricing type**, quantity/value update rules, and the **billing split criteria**.

**Pricing type** in `VTFL`/`VTFA` is the answer to "why is the invoice price
different from the order price" — see the pricing reference.
**Copying requirements and data transfer routines are VOFM routines** — writing a
new one is classic modification (Tier 4). Check whether the requirement is really a
config/determination difference first.

**Common gap:** FS describes a follow-on document behaviour without naming the
copy control entry that produces it.

### 2.5 Incompletion — `OVA2` / tables `TVUV`, `TVUVF`
Assigned per document type, item category, schedule line, partner function, sales
activity. The **status group** decides what an incomplete field blocks (delivery,
billing, pricing, goods issue, general).

**Any FS asking for "don't allow save unless field X is filled" is an
incompletion procedure requirement**, not a custom validation — unless the check
is conditional on data outside the document.

### 2.6 Partner determination — `VOPA` / tables `TPAR`, `TPAER`
Partner functions: `SP` sold-to, `SH` ship-to, `BP` bill-to, `PY` payer, plus
`ER` employee responsible, `SB` forwarding agent, etc. Procedures exist separately
for customer master, sales header, sales item, delivery, billing, and shipment.

Item-level partner procedures allow **a different ship-to per line** — a routinely
over-engineered requirement.

### 2.7 Text determination — `VOTXN`
Text objects/IDs with access sequences that pull text from customer master,
preceding document, or material. FSs asking for "copy the customer's special
instruction to the invoice" are usually a text determination access sequence.

### 2.8 Other standard determinations worth knowing
| Requirement pattern | Standard mechanism | Config |
|---|---|---|
| Substitute one material for another | Material determination | `VB11`, procedure on doc type |
| Allow/forbid materials per customer | Listing / exclusion | `VB01`, `VB03` |
| Give N free with M | Free goods (inclusive/exclusive) | `VBN1`, procedure `NA00`, item cat `TANN` |
| Suggest related products | Cross-selling | Cross-selling profile |
| Customer's own material number | Customer-material info record | `VD51` / table `KNMT` |
| Batch selection at order/delivery | Batch determination | Search strategy `VCH1` |

---

## 3. Availability & scheduling

**Classic ATP**: checking group (material `MARC-MTVFP`) + checking rule → scope of
check (`OVZ9`); requirement type/class drives transfer of requirements.

**aATP (Advanced ATP) is the S/4HANA model** and what an FS should assume:
- **Product Availability Check (PAC)** — the base check.
- **Product Allocation (PAL)** — replaces classic product allocation; allocation
  planning via CDS/planning objects, sequences, characteristics.
- **Backorder Processing (BOP)** — segments and confirmation strategies
  (Win / Gain / Redistribute / Fill / Lose) run as a BOP variant, replacing
  classic rescheduling (`V_V2`).
- **Alternative-Based Confirmation (ABC)** — confirm from an alternative plant.
- **Release for Delivery** — controlled release of confirmed stock.

**Delivery scheduling** (backward/forward): transit time, loading time,
pick/pack time, transportation lead time — from route and shipping point.
"Custom confirmed-date logic" is usually a scheduling/aATP configuration ask.

---

## 4. Credit management

**In S/4HANA, SD credit management (FD32, `KNKK`, `OVA8`) is replaced by
SAP Credit Management (FIN-FSCM-CR).** Treat an FS that references `FD32`,
`KNKA`/`KNKK`, or "credit control area credit limit in the customer master" as
written against ECC.

The S/4 model:
- Business Partner role **`UKM000`**, transaction `UKM_BP`.
- **Credit segment** (not the credit control area alone) carries limit and exposure.
- **Credit rules engine in BRFplus** — scoring, risk class, limit calculation and
  the check itself are decision tables, so "custom credit rules" is normally a
  BRF+ configuration ask, not ABAP.
- Credit exposure/liability in the `UKM_*` tables; cases via `UKM_CASE`.
- Blocked documents released with `VKM1`/`VKM3` (still valid).

---

## 5. Delivery & shipping

| Object | Config | Key |
|---|---|---|
| Delivery type (`LF`, `LO`, `NL`, `RL`) | `0VLK` / `TVLK` | from sales doc type |
| Delivery item category | `0184` / `TVLP` | delivery type + item cat group + usage + higher-level item cat |
| Shipping point | `OVL2` | shipping condition (customer) + loading group (material) + plant |
| Route | route determination | departure country/zone + destination country/zone + shipping condition + transportation group (+ weight group) |
| Picking | lean WM / EWM | storage location determination |
| Packing | Handling Units | packing instructions |
| Goods issue | movement type from schedule line category | posts material doc + FI, sets status |

**Delivery split** happens on differing route, shipping point, ship-to,
incoterms, or route schedule — a frequent "why did we get two deliveries" FS.

---

## 6. Billing & invoicing

### 6.1 Billing type — `VOFA` / table `TVFK`
Standard: `F1` order-related, `F2` delivery-related, `F5`/`F8` pro forma,
`G2` credit memo, `L2` debit memo, `RE` returns credit memo, `S1` invoice
cancellation, `S2` credit memo cancellation, `IV` intercompany, `LR`/`LG` invoice
list, `BV` cash sale.

Controls: number range, account determination procedure, output procedure,
cancellation billing type, invoice list type, posting block, rebate relevance.

### 6.2 Billing relevance — item category field `FKREL` (the most-missed control)
Decides **what a billing document is created from**. Principal values:

| Value | Meaning |
|---|---|
| ` ` | not relevant for billing |
| `A` | delivery-related billing |
| `B` | order-related billing — status per **order quantity** |
| `C` | order-related billing — status per **target quantity** (contracts) |
| `D` | relevant for pro forma |
| `F` | order-related, billed per **invoice receipt quantity** (third-party) |
| `G` | order-related, billed per **delivery quantity** |
| `H` | delivery-related, **no zero quantities** |
| `I` | order-relevant — **billing plan** |
| `K` | delivery-related, partial quantity billing |

Confirm the exact code list in `VOV7` for your release before writing it into an FS.

**Most billing FSs that propose custom development are actually asking for a
different `FKREL` + copy control combination.**

### 6.3 Billing plans — `OVBI` / `OVBJ`, tables `FPLA` / `FPLT`
- **Periodic billing** — recurring equal invoices (rental, service, subscription);
  date category, billing rule, horizon, calendar.
- **Milestone billing** — value/percentage per project milestone; integrates with PS.
- Requires item category billing relevance `I` and a billing plan type on the
  item category.
- **Down payments** run through the billing plan (down payment date category and
  the `AZWR` condition).

### 6.4 Resource-related billing — `DP90` / `DP91`, DIP profile `ODP1`
Bills actual costs/effort from CO/PS/service orders. The standard answer to
"invoice the customer for time and materials actually consumed".

### 6.5 Invoice combination and split
- **Collective billing** — one invoice from several deliveries when header split
  criteria match (payer, billing date, terms, sales org, and the `VBRK-ZUKRI`
  split field built by copy control).
- **Invoice list (`LR`/`LG`)** — a periodic list document grouping invoices for a
  payer; requires an invoice list type on the billing type and a factory calendar
  on the payer.
- **To force a split** (e.g. per PO number), add the field to the split criteria
  via a copy-control data transfer routine — that routine is VOFM (Tier 4);
  check first whether a standard split criterion already covers it.
- Billing due list: `VF04`, background `VF06`.

### 6.6 Corrections, returns, cancellation
- **Invoice Correction Request (`RK`)** — the standard answer to "the customer
  disputes price or quantity on an invoice". Created with reference to the
  invoice; generates **paired credit and debit items** so only the difference
  settles. FSs routinely propose custom credit-memo logic for exactly this.
- **Credit / debit memo request** (`CR`/`DR`) → billing `G2`/`L2`, usually with a
  billing block released after approval.
- **Returns** — `RE` order → returns delivery → credit memo. In S/4,
  **Advanced Returns Management** adds inspection, refund determination, follow-up
  activity and approval — check it before speccing a custom returns workflow.
- **Cancellation** — `VF11`, producing `S1`/`S2`.

### 6.7 Intercompany billing
Delivering plant belongs to another company code → intercompany billing type `IV`,
with the intercompany price conditions (`PI01` quantity-based / `PI02` percentage)
carrying the transfer price. Configured on the sales doc type / delivering plant's
sales org assignment.

### 6.8 SD → FI account determination — `VKOA`
Condition technique again: application `V`, condition types **`KOFI`**
(FI account determination) and **`KOFK`** (with CO account assignment).
Access keys combine: chart of accounts, sales organisation, **account assignment
group of the customer** (`KNVV-KTGRD`), **of the material** (`MVKE-KTGRM`), and
the **account key** from the pricing procedure (`ERL` revenue, `ERS` sales
deductions, `ERF` freight, `MWS` tax, `EVV` cash clearing).

"Post this condition to a different G/L account" = a new account key +
`VKOA` entry, not code.

### 6.9 Revenue recognition
Classic SD revenue recognition (`VF44`/`VF45`) is **not** the S/4 path. Use
**Event-Based Revenue Recognition** or **SAP Revenue Accounting and Reporting
(RAR)** — and say which in the FS, because the billing design depends on it.

### 6.10 High-volume / convergent invoicing
For telco/utilities-style volumes: **Convergent Invoicing** on **FI-CA**
(billable items → billing documents → invoicing documents), separate from SD
billing. If an FS mixes SD billing and FI-CA concepts, that ambiguity must be
resolved before design.

---

## 7. Output / document communication

**S/4HANA target is Output Control (BRFplus-based Output Management)**, not
classic `NACE`/`NAST` condition-technique output.

- **Output parameter determination** is a set of BRFplus decision tables per
  application object (sales order, delivery, billing document): they determine
  **channel** (PRINT / EMAIL / EDI-XML / IDoc), **form template**, **receiver**,
  **email template** and **rules**.
- **Form templates** are Adobe-based, maintained in the *Maintain Form Templates*
  app; email templates in *Maintain Email Templates*.
- Classic `NAST` output still exists in Private Edition for some applications —
  an FS must state **which framework** applies to the object in scope. Do not let
  it stay ambiguous; the build differs completely.
- Standard classic output types you'll still see referenced: `BA00` order
  confirmation, `LD00` delivery note, `RD00` invoice.

"Send the invoice as a PDF by email" is Output Control configuration + a form
template — not a development.

---

## 8. Master data

### 8.1 Business Partner is the single entry point
In S/4HANA, **`BP` is the only transaction** for customers/vendors; `XD01`/`VD01`/
`XK01`/`MK01` are obsolete paths. **CVI (Customer/Vendor Integration)** keeps
`KNA1`/`LFA1` in sync behind the BP.

Roles that matter for L2C: **`FLCU00`** (FI customer / company code),
**`FLCU01`** (SD customer / sales area), **`UKM000`** (credit management).

Data still lands in: `KNA1` general, `KNB1` company code, `KNVV` sales area,
`KNVP` partner functions, `KNVI` tax classification.

**An FS that says "create the customer in XD01" was written against ECC.**

### 8.2 Product master
Material master is the **Product** in S/4 Fiori apps; `MARA` / `MARC` / `MVKE`
(sales org) / `MLAN` (tax) remain. **`MATNR` is extended to 40 characters** — any
FS assuming 18 needs correcting, especially for interfaces and forms.

Sales-relevant fields that drive determination: item category group
(`MVKE-MTPOS`), availability checking group (`MARC-MTVFP`), loading group,
transportation group, account assignment group (`MVKE-KTGRM`), tax classification.

### 8.3 Condition records
See the pricing reference. Key point for FS review: condition records carry
**validity periods, scales, release status and authorization**. A custom Z-table
of prices/discounts throws all of that away — always challenge it.

---

## 9. Integration touchpoints to pin down in every FS

| Touchpoint | What the FS must state |
|---|---|
| Finance | account determination impact, revenue recognition model, down payments |
| FI-CA / Convergent Invoicing | whether billing is SD or FI-CA — never leave ambiguous |
| Tax | tax condition and classification, or the external engine (Vertex / Avalara) and which |
| Output | Output Control vs classic NAST; channel; form template owner |
| EDI / partners | standard IDoc (`ORDERS`, `ORDRSP`, `DESADV`, `INVOIC`) vs API vs Integration Suite iFlow |
| CRM / CX | lead/opportunity → quotation handover, and which system owns the customer |
| Logistics | WM vs EWM, embedded TM, batch/serial requirements |
| Analytics | CDS/embedded analytics — not a custom ALV report |

---

## 10. FS review quick probes (per area)

- **Order**: which document type and item category? what should be incomplete-blocked?
  which partner functions at item level? contract/consignment/third-party variant?
- **Pricing**: which procedure, condition type, access sequence? scales? is this a
  requirement/formula (VOFM) ask in disguise?
- **ATP**: aATP in scope — PAC only, or allocation/BOP/ABC? what confirms the date?
- **Delivery**: split criteria intended? picking/packing/HU relevance? EWM or lean WM?
- **Billing**: billing type, `FKREL`, order- vs delivery-related, plan type,
  split vs collective, cancellation behaviour, account key.
- **Output**: which framework, which channel, who owns the form template?
- **Credit**: FSCM segments and BRF+ rules — or is this an ECC-era design?
- **Master data**: BP roles and which system is master; MATNR 40 handled?
- **Downstream**: FI posting, revenue recognition, tax engine, reporting.
