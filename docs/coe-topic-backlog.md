# COE Knowledge-Sharing — Topic Backlog

Rolling, ranked backlog for the biweekly ABAP developer sessions. `coe-session-planner`
pulls the top unblocked item, researches it (fresh — via `sap-innovation-radar`),
drafts it, then the delivered session moves to `coe-session-log.md`.

Keep it to ~15 live items. Re-rank when priorities shift. Every product-version
topic must be re-verified against current SAP docs before it is drafted — the
notes here go stale.

## Ranking guide

- **P1** — timely (tied to a current release, an active project decision, or a
  recurring code-review finding) and deliverable in one 45–60 min slot.
- **P2** — valuable, not urgent, or needs prep/split.
- **P3** — parking lot / someday.

## Backlog

| Rank | Topic | Type | Why it matters now | Prep | Status |
|---|---|---|---|---|---|
| P1 | RAP managed BO end-to-end for classic ABAP developers | Practice | Core skill for the greenfield build; recurring review gaps in save-sequence use | M | Ready |
| P1 | Clean Core in Private Edition — the 3-tier model and when Tier 4 is really allowed | Practice | Team keeps reaching for enhancements; align on the exception bar | S | Ready |
| P1 | Reading a released-API contract in ADT (API state, successor, deprecation) | Practice | Prevents non-released usage getting into transports | S | Ready |
| P1 | ABAP Unit for RAP: behavior test doubles, CDS test doubles | Practice | New logic shipping with thin/absent tests | M | Ready |
| P1 | Using GitHub Copilot well for ABAP — prompt patterns, what it gets wrong | AI | This COE's standing AI thread; concrete team productivity | S | Ready |
| P2 | S/4HANA 2025: what changed for SD / Billing (release-note walkthrough) | Innovation | Keep the team current; feeds design decisions | M — needs fresh research | Blocked on research |
| P2 | Output management in S/4HANA: BRFplus-based determination vs classic NACE | Practice | Recurring on L2C requirements | M | Ready |
| P2 | CDS access control (DCL) patterns for row-level authorization | Practice | Auth design questions on most models | M | Ready |
| P2 | Enterprise Event Enablement: RAP raise-event to Integration Suite | Practice | Async integration pattern used across interfaces | M | Ready |
| P2 | Joule for developers / AI in ABAP tooling — current state | AI | AI thread; separate hype from what's usable today | M — needs fresh research | Blocked on research |
| P2 | Debugging RAP: common runtime errors and how to read them | Practice | Reduce time-to-fix in build phase | M | Ready |
| P2 | Side-by-side on BTP ABAP: when and how it talks to S/4 | Practice | Architecture decisions need shared understanding | M | Ready |
| P3 | ADT productivity: quick fixes, templates, refactoring, ABAP Cleaner | Practice | Nice quality-of-life session | S | Ready |
| P3 | abapGit workflows for cloud development | Practice | If the project adopts it | S | Ready |
| P3 | AMDP and CDS table functions — when performance justifies them | Practice | Occasional mass-data need | M | Ready |

## Recently delivered (move rows here briefly before archiving to the log)

_(none yet)_
