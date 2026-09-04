# Architecture Decision Record — Extensibility Choice

| Field | Value |
|---|---|
| ADR ID | |
| Related FS / requirement | |
| Date | |
| Decided by | |
| Status | Proposed / Accepted / Superseded |

## 1. Context

What requirement forces a decision here. One paragraph.

## 2. Options Considered

| Option | Description | Clean Core impact | Effort | Upgrade risk |
|---|---|---|---|---|
| A. Standard config | | None | | None |
| B. In-app extensibility (key user tools) | | Compliant | | Low |
| C. In-app extensibility (developer, RAP-based, released APIs only) | | Compliant | | Low-Medium |
| D. Side-by-side extensibility (BTP, RAP/CAP + API/event integration) | | Compliant | | Low (isolated) |
| E. Classic extensibility (user-exit, BAdI on non-released object, core mod) | | **Violation — requires formal exception** | | High |

## 3. Decision

Chosen option + one-line reason.

## 4. Consequences

- What this enables
- What this constrains (e.g., future upgrade testing scope, licensing for BTP, latency for side-by-side calls)
- Monitoring/ownership after go-live

## 5. Clean Core Checklist (must all be Yes before Accepted, unless Option E with sign-off)

- [ ] Only released APIs / CDS (released) / BAdIs (released) used
- [ ] No modification of SAP standard objects
- [ ] No access to SAP tables outside released CDS/API layer
- [ ] Extension is decoupled — survives a system upgrade without manual rework
- [ ] If side-by-side: integration uses SAP Integration Suite / released communication scenario, not direct DB/RFC hack
- [ ] Naming convention followed (custom namespace, Z/Y or customer namespace per project standard)
- [ ] Exception log entry created if Option E was unavoidable, with business justification and target remediation date
