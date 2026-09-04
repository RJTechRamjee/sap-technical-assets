# Solution Design Document (SDD)

> One SDD per solution area / workstream / significant epic. It sits **above** the
> functional specs: it decides the shape of the solution across many requirements,
> and each requirement then gets its own FS (`functional-spec-template.md`).
> Fill every section. Placeholders per `reference/sap-project-standards.md` §8.

## 1. Header

| Field | Value |
|---|---|
| SDD ID | |
| Title | |
| Solution area | (Lead-to-Cash / SD / Invoicing / cross) |
| Author (architect) | |
| Status | Draft / In Review / Approved / Baselined |
| Target platform | S/4HANA Cloud Private Edition — S/4HANA 2025 (per project standards) |
| Related requirements / backlog IDs | |
| Related FS documents | |
| Related ADRs | |
| Version / date | |

## 2. Executive Summary

5–10 lines: the business outcome, the shape of the solution, the single most
important architecture decision, and the biggest risk. Written so a delivery lead
or client architect can read only this section and know what is being built.

## 3. Business Process Architecture

- **Value-chain position** — which hops of inquiry → quotation → order → delivery
  → billing → payment/dunning this solution touches, and what is upstream /
  downstream of each.
- **Process flow (to-be)** — narrative or diagram reference; mark every step that
  is standard, configured, or extended.
- **Process variants** — by sales org / distribution channel / country / customer
  type, where they diverge.
- **Fit-to-standard summary** — table below.

| Requirement group | Standard SAP mechanism | Fit | Gap → handled in |
|---|---|---|---|
| | (pricing procedure, output determination, billing plan, ICR, credit mgmt…) | Full / Partial / None | §7 tier + ADR / FS ID |

## 4. Scope & Requirements Register

**In scope:**
-

**Out of scope:**
-

| Req ID | Requirement (one line) | Priority | Process step | FS ID | Extensibility tier (§7) |
|---|---|---|---|---|---|
| R1 | | Must/Should/Could | | | 0–4 |

## 5. Solution Options & Key Decisions

For each material decision (not every small choice):

| # | Decision point | Options considered | Chosen | Rationale | ADR |
|---|---|---|---|---|---|
| D1 | | A / B / C | | | ADR-ID or "n/a — recorded here" |

## 6. Application Architecture

- **Components** — RAP BOs, CDS models, apps (Fiori elements / freestyle),
  background jobs, BRFplus decisions — and how they relate (diagram reference).
- **Reuse** — released SAP APIs / BAdIs / events consumed; existing custom
  components reused.
- **Build split** — on-stack (ABAP Cloud) vs side-by-side (BTP), with the reason
  per component (see §7).
- **Key released dependencies** — table: Component | Released API/CDS/BAdI | API state verified? |

## 7. Extensibility Register (Clean Core)

*Run the `clean-core-extensibility-advisor` logic per gap. Tier order and rules:
`reference/sap-project-standards.md` §3.*

| Gap / Req | Why standard/config insufficient | Tier (0 config · 1 key-user · 2 dev ABAP Cloud · 3 side-by-side · 4 classic exception) | Mechanism (name it concretely) | Upgrade risk | ADR |
|---|---|---|---|---|---|

**Clean Core position by dimension** (software stack / extensions / data /
integrations / processes / operations) — one line each on how this solution stays
clean, or the exception taken.

**Tier-4 exceptions** — list each with: justification, owner, ATC allowlist entry,
remediation target release. If none: `N/A`.

## 8. Integration Architecture

| Interface ID | Source → Target | Trigger | Pattern (sync API / async event / batch) | Protocol & released API | Middleware (Integration Suite iFlow / API Mgmt / Event Mesh) | Auth | Volume | Error handling & monitoring | Spec |
|---|---|---|---|---|---|---|---|---|---|
| IF-01 | | | | | | OAuth2 / cert / … | | | `interface-spec-template.md` link |

Notes: idempotency, retry/replay, ordering guarantees, PII in payloads,
fallback when the target is down.

## 9. Data Architecture

- **Data model** — new persistent entities (RAP BO nodes / custom tables via
  RAP), key fields, associations to released SAP entities. Diagram reference.
- **Master data** — which master data is read (released CDS), which is created,
  ownership and stewardship.
- **Data volume & retention** — expected row counts, growth, archiving / ILM.
- **Data migration / conversion** — objects in scope, tool (Migration Cockpit /
  LTMC / custom), cutover dependency. Detailed cutover plan is separate.

## 10. Non-Functional Requirements

| NFR | Target | How the design meets it |
|---|---|---|
| Performance (online) | e.g. < 2s p95 | |
| Throughput (batch/mass) | e.g. X docs/hour | package size, parallelization, AMDP |
| Availability | | |
| Scalability | | |
| Security & authorizations | roles, DCL, field masking, BTP destinations | |
| Auditability / compliance | change logs, GDPR, SoX | |
| Observability | app logs, job monitoring, interface monitoring | |

## 11. Security & Authorizations

- Business catalogs / roles affected or created.
- Restriction model: RAP instance authorization, CDS access control (DCL).
- Communication users / arrangements for integration; BTP destination & trust.

## 12. RAID

| Type (Risk/Assumption/Issue/Dependency) | Description | Impact | Owner | Mitigation / due |
|---|---|---|---|---|

## 13. Open Questions

| # | Question | Owner | Needed by | Status |
|---|---|---|---|---|

## 14. Handoffs

- Requirements ready for FS drafting (`functional-spec-writer`): list Req IDs.
- Decisions needing a formal ADR (`clean-core-extensibility-advisor`): list.
- Interfaces needing a full spec (`interface-spec-template.md`): list IF IDs.
- Build-ready components for scaffolding (`abap-object-generator`): list.

## 15. Sign-off

| Role | Name | Date |
|---|---|---|
| Solution architect | | |
| Lead functional consultant | | |
| Client / product owner | | |
| Integration architect (if applicable) | | |
