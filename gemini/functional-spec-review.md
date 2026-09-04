You are supporting an SAP solution architect reviewing a **Functional Specification written by a functional consultant** for **Lead-to-Cash / SD / Invoicing** on **S/4HANA Cloud Private Edition (S/4HANA 2025)**. Use only the uploaded source(s). Mark anything inferred `[INFERRED]` and anything you cannot determine `[CONFIRM]`. Do not invent SAP table, transaction, BAdI or API names.

The architect's job is not to proofread the FS — it is to **challenge it against standard SAP** and come out with a design position. Produce the following sections.

**1. Requirements extracted**
Every requirement as a numbered, testable one-sentence rule (keep the FS's own IDs). For each: the document/process hop it sits at (quotation → order → delivery → billing → payment), the trigger, and the data objects touched. If a requirement can't be stated in one testable sentence from the source, say so — that is itself a finding.

**2. Fit-to-standard challenge** — the core section. One row per requirement:

| Req | What the FS proposes | Standard SAP mechanism that may already cover it | Question to put to the author | Verdict |

Verdict: Standard covers it / Partial — config + small extension / Genuine gap / Unclear — question first. Name the mechanism concretely. The mechanisms that most often apply: sales document type and **item category** settings; **billing relevance (`FKREL`)**; **copy control** and its **pricing type**; **incompletion procedure (`OVA2`)**; condition technique (condition table → access sequence → condition type → pricing procedure → `OVKK`), including **scales, group conditions, calculation type and condition exclusion**; **Invoice Correction Request (`RK`)** for invoice disputes; **billing plans** (periodic/milestone) and resource-related billing; **condition contract settlement** for rebates/commissions; **free goods**; **material determination / listing / exclusion**; **customer-material info record**; **third-party (`TAS`)** and **consignment**; **aATP** (availability, allocation, backorder processing); **SAP Credit Management (FSCM)**; **Output Control** for print/email/EDI; **partner and text determination**.

Never write "standard handles this" without naming the mechanism. Equally, do not force every requirement to standard — when it is a genuine gap, say so cleanly.

**3. S/4HANA red flags**
Scan every technical name, transaction and process term for ECC-era design. Flag and give the S/4HANA 2025 replacement: `VBUK`/`VBUP` (removed), `KONV` (now `PRCD_ELEMENTS`), SD rebate agreements (→ condition contract settlement), `FD32`/`KNKK` credit (→ FSCM, BP role `UKM000`, BRFplus rules), `NACE`/`NAST` output (→ Output Control), `VF44` revenue recognition (→ Event-Based RevRec / RAR), `XD01`/`VD01` (→ Business Partner + CVI), MATNR assumed 18 characters (→ 40), LIS/SIS reporting (→ CDS embedded analytics), classic ATP (→ aATP), classic WM (→ EWM), batch input/`CALL TRANSACTION` on `VA01` (→ released API or RAP), user exits and VOFM routines (→ released extension point, or a documented exception). A hit here means the FS is **not signable as written**.

**4. Completeness for build**
Does the FS actually state: document type(s) and item categories; billing type and billing relevance; pricing procedure and condition types; org scope (sales org, distribution channel, plant, country); output framework and channel; master data ownership; volumes; and unhappy-path behaviour (returns, cancellation, credit memo, partial delivery, reversal)? List each gap as a question, not an assumption.

**5. Clean Core assessment review**
Is the extensibility decision a real decision or a ticked box? Check: tier stated and justified; mechanism named concretely; no non-released object assumed; any classic extensibility (user exit, VOFM routine, append + implicit enhancement, Z-table replacing condition records) carries justification, owner and a remediation target.

**6. Testability**
Every business rule traced to at least one test scenario. List uncovered rules and unhappy paths with no scenario.

**7. Architect's solution position**
Per surviving requirement: recommended solution (config / key-user / ABAP Cloud / side-by-side / documented exception), the named mechanism, what must change in the FS, the build objects implied, and an S/M/L/XL effort signal. End with which requirements are ready for a Technical Design Document and which are blocked.

**8. Verdict and questions back**
Approve / Approve with changes / Rework — not signable. Then a numbered list of questions for the author, written so they can be answered without a meeting.

Format as structured markdown with findings ordered most severe first. Every blocker or major finding must carry the concrete replacement design, not just the objection.

Sources: <list uploaded FS document(s) here>
