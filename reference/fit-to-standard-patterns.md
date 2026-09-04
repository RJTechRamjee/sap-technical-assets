# Fit-to-Standard Challenge Catalog

Recurring requirement patterns in Lead-to-Cash / SD / Invoicing, and the standard
SAP answer to each. Use it to **challenge a functional spec before designing** —
the architect's value is in the pushback, and most "custom development" requests
in this space are configuration that nobody checked.

Columns: **Ask** (how the requirement usually arrives) · **Standard answer** ·
**Question to put to the functional consultant** · **When it's genuinely a gap**
· **Tier if genuine** (0 config · 1 key-user · 2 ABAP Cloud · 3 side-by-side ·
4 classic exception — see `sap-project-standards.md` §3).

Depth behind each answer: `l2c-standard-process-reference.md` and
`pricing-condition-technique-reference.md`.

---

## Pricing & conditions

| # | Ask | Standard answer | Question to ask | Genuinely a gap when | Tier |
|---|---|---|---|---|---|
| 1 | "Discount by customer + material + volume" | Condition table + access sequence + **scales** | Which key fields, and are they all in the pricing field catalogue? | A key field isn't in the field catalogue and can't be added by key-user extensibility | 1–2 |
| 2 | "Z-table holding customer prices" | **Condition records** — validity, scales, release status, authorization come free | What does a Z-table give you that a condition record doesn't? | Prices are owned by an external system of record and cannot be replicated | 3 |
| 3 | "Discount on total order value, not per line" | **Group condition** + header condition with distribution | Is the scale basis value or quantity, and across which items? | — rarely | 0 |
| 4 | "Best of several discounts only" | **Condition exclusion** groups + exclusion indicator | Which conditions compete, and what's the tie-break? | Selection depends on data outside the document | 2 |
| 5 | "Charge per kg / per pallet" | **Calculation type** D/E/F (weight/volume) on the condition type | Which unit drives it — is it on the material master? | — rarely | 0 |
| 6 | "Custom pricing routine / formula" | Walk the ladder: calculation type → group condition → scale → exclusion → extra access → standard routine → released extension point | What exactly can't the condition type configuration express? | Value genuinely needs procedural logic no config expresses | 2, else **4** |
| 7 | "Invoice price differs from order price — need custom repricing" | **Pricing type in copy control** (`VTFL`/`VTFA`) + condition validity dates | Which pricing type is set today, and what's the intended behaviour? | — almost never | 0 |
| 8 | "Rebate / commission / royalty accruals" | **Condition Contract Settlement Management** (`WCOCO`) — classic SD rebate is not the S/4 model | Has condition contract management been evaluated? | Contract terms are managed in a non-SAP system | 3 |
| 9 | "Buy 10 get 1 free" | **Free goods** (`VBN1`, procedure `NA00`, item category `TANN`), inclusive or exclusive | Inclusive or exclusive? Does it need to appear on the invoice? | Complex multi-product bundling rules | 2 |
| 10 | "Different pricing for a customer group" | **Customer pricing procedure** (`KNVV-KALKS`) in the `OVKK` key | Why can't a customer pricing procedure separate them? | — rarely | 0 |
| 11 | "Show margin / cost on the order" | Statistical condition (`VPRS`) + **subtotal** field | Do you need it stored, or just displayed? | Margin needs a calculation not derivable in the procedure | 2 |
| 12 | "Multi-jurisdiction US tax" | Tax condition + classification, or the **external tax engine** integration (Vertex / Avalara / ONESOURCE) | Which engine, and is tax determined at order, delivery or billing? | Engine has no standard integration for the release | 3 |

## Sales order processing

| # | Ask | Standard answer | Question to ask | Genuinely a gap when | Tier |
|---|---|---|---|---|---|
| 13 | "Don't allow save unless field X is filled" | **Incompletion procedure** (`OVA2`) + status group | Which status group — should it block delivery, billing or both? | The check depends on data outside the document or a cross-document rule | 2 |
| 14 | "Different ship-to per line" | **Item-level partner determination** procedure | Is the item partner procedure assigned on the item category? | — rarely | 0 |
| 15 | "Substitute material automatically" | **Material determination** (`VB11`) | Substitution reason, and should the original be visible? | Substitution logic needs stock/allocation awareness | 2 |
| 16 | "This customer may only buy these materials" | **Listing / exclusion** (`VB01`) | Listing or exclusion, at which level? | — rarely | 0 |
| 17 | "Customer orders using their own part number" | **Customer-material info record** (`KNMT`) | Does it also need to print on the invoice? (it does, via standard) | — rarely | 0 |
| 18 | "Drop-ship direct from vendor" | **Third-party** item category `TAS` → purchase requisition → PO → vendor invoice → order-related billing (`FKREL` = `F`) | Bill on vendor invoice quantity or on confirmation? | — rarely | 0 |
| 19 | "Stock held at the customer site" | **Consignment** cycle `KB` fill-up / `KE` issue / `KA` pickup / `KR` return | Which steps are billing-relevant? (issue is) | — rarely | 0 |
| 20 | "Custom confirmed delivery date logic" | **aATP** (PAC, allocation, ABC) + **delivery scheduling** (transit, loading, pick/pack, transportation lead time) | What confirms the date today and which lead times are maintained? | Date depends on external logistics data | 3 |
| 21 | "Reserve scarce stock for key customers" | **aATP Product Allocation**, and **BOP** with confirmation strategies | Have allocation objects/sequences been designed? | Allocation policy needs logic outside the aATP model | 2 |
| 22 | "Approval before the order can proceed" | **Delivery/billing block** on the document type + release with authorization; or SAP Business Workflow / flexible workflow | Who approves, on what condition, and what is blocked meanwhile? | Multi-step conditional approval beyond flexible workflow | 2 |
| 23 | "Custom number range / document numbering" | Number range object assigned in the **document type** config | Is a new document type actually justified? | Numbering must follow an external scheme | 2 |

## Delivery & logistics

| # | Ask | Standard answer | Question to ask | Genuinely a gap when | Tier |
|---|---|---|---|---|---|
| 24 | "Why did we get two deliveries / force one delivery" | **Delivery split criteria** — route, shipping point, ship-to, incoterms; combination controlled in the delivery due list | Which split criterion is differing? | A non-standard split key is genuinely required | 2 (avoid) |
| 25 | "Pick and pack rules" | Lean WM or **EWM**, handling units, packing instructions | EWM in scope, embedded or decentralised? | — rarely | 0 |
| 26 | "Print a packing list / delivery note" | **Output Control** + Adobe form template | Which framework and who owns the template? | — rarely | 0 |

## Billing & invoicing

| # | Ask | Standard answer | Question to ask | Genuinely a gap when | Tier |
|---|---|---|---|---|---|
| 27 | "Customer disputes the price/quantity on an invoice" | **Invoice Correction Request (`RK`)** — paired credit/debit items settle only the difference | Has ICR been evaluated instead of a custom credit memo flow? | — rarely | 0 |
| 28 | "Bill monthly / quarterly for a service" | **Periodic billing plan** (billing relevance `I`) | Which date category and billing rule? | Billing cycle driven by external usage data | 3 (or FI-CA CI) |
| 29 | "Bill at project milestones" | **Milestone billing plan**, PS-integrated | Are milestones in PS or maintained manually? | — rarely | 0 |
| 30 | "Invoice actual time and materials consumed" | **Resource-related billing** `DP90` + DIP profile | Which cost sources feed it? | Source costs live outside SAP | 3 |
| 31 | "One invoice for many deliveries" | **Collective billing** (matching split criteria) or **invoice list** (`LR`) | Collective billing or a true invoice list document? | — rarely | 0 |
| 32 | "Split invoices by PO number / cost centre" | Check standard split criteria first; otherwise a copy-control **data transfer routine** (VOFM = Tier 4) | Is the split field already a standard criterion? | The field is genuinely non-standard | **4** (get exception) |
| 33 | "Down payment before delivery" | **Billing plan down payment** date category + `AZWR` condition | Down payment request or a real down payment with FI clearing? | — rarely | 0 |
| 34 | "Pro forma invoice for customs" | Billing type **`F5`/`F8`** | Order- or delivery-related pro forma? | — rarely | 0 |
| 35 | "Intercompany invoicing between plants" | **`IV` billing type** + intercompany conditions (`PI01`/`PI02`) | Is the delivering plant assigned to another company code? | Complex multi-entity chains | 2–3 |
| 36 | "Post this revenue to a different G/L account" | **Account key** in the pricing procedure + **`VKOA`** entry | Which account key and account assignment groups? | — rarely | 0 |
| 37 | "Recognise revenue over the contract period" | **Event-Based Revenue Recognition** or **RAR** — not classic `VF44` | Which revenue model is the project on? | — rarely; the model is a project decision | 0 |
| 38 | "Very high invoice volumes / usage-based billing" | **FI-CA Convergent Invoicing** (billable items → billing → invoicing), not SD billing | Is this SD billing or FI-CA? Resolve before design | — the choice itself is the design | 0 |
| 39 | "Custom validation before releasing the invoice to accounting" | **Billing block** + standard checks; else a released billing BAdI | What condition, and can a billing block carry it? | Genuine cross-object check | 2 |

## Output, master data, integration, reporting

| # | Ask | Standard answer | Question to ask | Genuinely a gap when | Tier |
|---|---|---|---|---|---|
| 40 | "Email the invoice as a PDF" | **Output Control**: channel EMAIL, Adobe form template, email template, receiver determination | Which framework applies to this object — Output Control or classic NAST? | — rarely | 0 |
| 41 | "Send orders/invoices to a partner by EDI" | Standard IDocs (`ORDERS`, `ORDRSP`, `DESADV`, `INVOIC`) or a released API through **Integration Suite** | Which message, which partner spec, sync or async? | Partner format has no standard mapping | 3 |
| 42 | "Receive sales orders from an external system" | Released **Sales Order API** (OData/SOAP) or IDoc `ORDERS` via Integration Suite | Which released API, and what's the error/replay design? | — rarely | 0/3 |
| 43 | "Add a custom field to the order and see it on the invoice" | **Key-user field extensibility**, with the field propagated to follow-on documents and to output | Is the field needed in pricing, output, or just display? | Field must drive logic no extension point exposes | 2 |
| 44 | "Custom report of open orders / backlog" | **CDS view + Fiori elements / embedded analytics**; check for a standard app first | Which standard Fiori app was evaluated? | Genuinely novel analytical model | 2 |
| 45 | "Create the customer in XD01" | **Business Partner** (`BP`) with roles `FLCU00`/`FLCU01`, CVI behind it | Which BP roles and grouping? Who is the master system? | — never; correct the FS | 0 |
| 46 | "Block the order when the customer is over their credit limit" | **SAP Credit Management (FSCM)**: credit segment, risk class, **BRFplus credit rules** | Are the credit rules BRF+ decision tables, or is this an ECC-era design? | Scoring needs an external credit bureau feed | 3 |
| 47 | "Custom approval/return workflow" | **Advanced Returns Management** (inspection, refund determination, follow-up) or flexible workflow | Has ARM been evaluated? | Beyond ARM's decision model | 2 |
| 48 | "Archive / purge old documents" | **ILM / archiving objects** | Which archiving object and retention rule? | — rarely | 0 |

---

## How to use this in an FS review

1. Map each numbered business rule in the FS to the closest pattern above.
2. Put the **question** to the functional consultant — in writing, in the review.
3. Only record a gap when the "genuinely a gap when" condition is actually met by
   the requirement as written, and say which condition it is.
4. Record the tier and the concrete mechanism in the FS's Clean Core section; a
   gap with no named mechanism is not an accepted gap.
5. If a pattern isn't in this catalog, add it after the review — this file should
   grow with every engagement.

**Discipline:** do not claim standard covers something you cannot name the
mechanism for. "Standard handles this" without a config object, transaction or
released API is exactly the vagueness this catalog exists to replace.
