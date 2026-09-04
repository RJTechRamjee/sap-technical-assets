You are supporting an SAP solution architect building a **Solution Design Document** for **Lead-to-Cash / SD / Invoicing** on an S/4HANA Cloud **Private Edition** (S/4HANA 2025) project. Use only the uploaded source(s) — workshop transcripts, requirement backlog, draft functional designs, RFP scope, release notes. Don't fill gaps from general SAP knowledge unless I ask; mark anything inferred `[INFERRED]` and anything missing `[CONFIRM]`.

From the uploaded sources, produce a draft SDD skeleton I can paste into a solution-design-document template:

1. **Requirements register** — every requirement as a row: ID, one-line statement, priority (Must/Should/Could), the Lead-to-Cash process step it sits at (quotation → order → delivery → billing → payment/dunning), and any downstream system named (FI-CA, external tax, output channel, CRM/CX).
2. **Fit-to-standard table** — for each requirement group, the closest standard SAP mechanism (pricing procedure / condition technique, output determination via BRFplus, billing plan, ICR, credit management, intercompany billing…) and a fit rating: Full / Partial / None. Justify None/Partial with what the source says is missing.
3. **Candidate extensibility tiering** — for each gap, a first-pass tier: 0 config · 1 key-user in-app · 2 developer ABAP Cloud (on-stack) · 3 side-by-side BTP · 4 classic (exception). One line why the tier above is insufficient, based on the source.
4. **Integration points** — every interface implied by the sources: source → target, trigger, sync/async/batch, and whether a released API is mentioned.
5. **Persistent data** — new entities/fields the requirements imply, and which SAP master/transactional data they relate to.
6. **Material decisions** — the 3–7 choices that will shape the solution (on-stack vs side-by-side, RAP BO vs config+BRFplus, event vs sync API, single vs multi entity), with the options the sources surface.
7. **Open questions & RAID** — what must be answered before the SDD can be baselined; risks/assumptions/dependencies stated in the sources.

Format as structured markdown. Do not invent SAP object, API, or config names — if a name isn't in the sources, write `[CONFIRM in ADT / with functional team]`.

Sources: <list uploaded documents here>
