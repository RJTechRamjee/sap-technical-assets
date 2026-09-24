# Internal API Discovery Hub — Business Requirement, Functional Design & Technical Architecture

**Working name:** API Atlas (placeholder — rename before socialising)
**Date:** 2026-09-22
**Target platform:** SAP S/4HANA Cloud Private Edition, release S/4HANA 2025 + SAP BTP
**Status:** Design direction for review — 9 open questions in §13
**Author's note:** product/service facts marked ✅ were verified against SAP documentation on 2026-09-22 (sources in Appendix A). Facts marked `[VERIFY]` could not be confirmed and must be checked before build.

---

## 0. What this document covers

Four deliverables in one, because they are not separable at this stage of an idea:

| § | Deliverable |
|---|---|
| 2 | Business requirement — the problem, who has it, what "solved" looks like |
| 3–4 | Functional design — standard-first check, capability map, screen behaviour |
| 5–6 | Technical architecture — options, recommended shape, clean-core position |
| 7–8 | Technical design — the data model (the hard part) and the pipeline |
| 14 | **AI provider strategy** — why extraction is not an AI problem, and how to keep the AI layer swappable (SAP or non-SAP) |
| 15 | **Deployment variants** — alternatives to CAP + HANA Cloud, and the port/adapter design that makes them configuration rather than redesign |
| 16 | **Data source evidence register** — what we read, which released API provides it, the underlying persistence, and how to prove it from the system |

§7 is the centre of gravity. Everything else can be re-decided later; a wrong data model cannot.

**Revision 2 (2026-09-24):** added §14–16 in response to review comments — AI provider flexibility including non-SAP options, alternatives to CAP/HANA Cloud, and table-level source evidence.

**Revision 3 (2026-09-24):** source evidence register updated from a Joule for Consultants session (§16.4). Two material changes: **risk R2 downgraded** — OData V4 usage statistics *are* obtainable via the HTTP statistics layer, reversing the earlier "does not exist" position; and the `/IWFND/` registry tables are **confirmed undocumented by SAP**, which is now used as the clean-core argument for the released-API-only design rather than treated as a gap.

---

## 1. Executive summary

We have `api.sap.com` (SAP Business Accelerator Hub) for SAP's *standard delivered* APIs. We have nothing equivalent for the OData services, SOAP services and RFCs that our own developers registered in our own systems. The only discovery tools today — `/IWFND/MAINT_SERVICE` and `/IWFND/V4_ADMIN` — search on technical name and description only, and our descriptions are thin, inconsistent, and in several cases just the developer's initials. The practical consequence is that developers cannot find what already exists, so they build it again.

**Proposal:** a side-by-side BTP application that (a) automatically harvests the service catalog and `$metadata` of every registered OData V2/V4 service across all S/4HANA systems, (b) parses that metadata into a normalised model down to entity, property, operation and annotation level, (c) uses an LLM via SAP Generative AI Hub to generate the business-language description that the metadata does not contain, and (d) exposes it through hybrid semantic + keyword search in a developer-facing web app.

**Clean core:** Level A. The application is side-by-side on BTP, reads S/4HANA only through published Gateway catalog services over HTTPS, and writes nothing. One optional on-stack component (§6.3) would drop to Level C and is scoped as an isolated, replaceable package behind an ADR exception.

**The strategic argument, not just the productivity one.** Reuse is the visible benefit. The bigger one is clean-core governance: a catalog that knows which Z-service exposes which CDS view and which table is also the impact-analysis tool for every upgrade, the evidence base for custom-code retirement, and — in Phase 3 — the thing that tells you "SAP now delivers a released API that does what `ZSD_ORDER_EXT_SRV` does; retire it." Pitch it as a clean-core asset that happens to help developers, not a developer convenience that happens to help clean core. That is the version that gets funded.

---

## 2. Business requirement

### 2.1 The problem

Discovery of internally-built APIs is a manual, oral tradition. To find out whether an API already exists for a given business need, a developer today must:

1. Guess at a naming fragment and search `/IWFND/MAINT_SERVICE` on it, per system
2. Repeat for `/IWFND/V4_ADMIN` because V4 services live in a separate registry with separate semantics (service groups, not services)
3. Open each candidate's `$metadata` in a browser and read raw EDMX to find out what it actually exposes
4. Ask a colleague who has been here longer

Steps 1–3 only work if you already guessed the right word. Nothing here searches *field* names, *entity* names, or business meaning. A service named `ZFI_EXT_SRV_02` with description `ext svc` is functionally invisible even though it may expose exactly the customer open-items data the developer needs.

### 2.2 Why the existing tooling does not solve it

| Tool | What it gives | Why it is not enough |
|---|---|---|
| `/IWFND/MAINT_SERVICE` | List of registered V2 services, name/description filter, per system | Name + description only. No entity/field search. No cross-system view. SAP GUI. No business-language content. |
| `/IWFND/V4_ADMIN` | V4 service groups and bindings | Same limits, plus the V4 model is unfamiliar to most developers, so services registered here get found even less often |
| `$metadata` in a browser | Complete truth about one service | Raw EDMX, unreadable at volume, one service at a time, no search |
| ADT / Eclipse object search | Finds development objects | Finds the *implementation*, not the *published contract*; no notion of "which service exposes this" |
| SAP Business Accelerator Hub | Excellent catalog UX | ✅ SAP standard APIs only. Customers cannot publish private or custom content there. |
| Confluence / SharePoint interface register | Business context | Hand-maintained, therefore stale within one release. Every organisation that has tried this has the same result. |

The last row is the important lesson and it should shape the design: **any solution that requires humans to enter API metadata will be out of date within six months.** The catalog must be harvested, not authored. Human input is allowed only as an *overlay* on harvested facts, never as the source of them.

### 2.3 Personas and their jobs-to-be-done

| # | Persona | The question they arrive with |
|---|---|---|
| P1 | ABAP / RAP developer | "Is there already a service that gives me delivery dates for an outbound delivery, or do I build one?" |
| P2 | Integration developer (Cloud Integration) | "Which endpoint, which entity set, which fields, which auth, does it support `$filter` and delta?" |
| P3 | Fiori / UI5 developer | "I need a value help for cost centre — is there a service, is it draft-enabled, is it V4?" |
| P4 | Solution architect | "How many services expose sales order header? Which do I retire?" |
| P5 | Security / Basis | "Which services are active in PRD but have had zero calls in 12 months?" |
| P6 | Release / test manager | "What changed in the API surface between the last release and this one, and is any of it breaking?" |
| P7 | Functional consultant / BA | "What data can we get out of SAP for this reporting requirement?" (needs business language, not EDMX) |
| P8 | AI coding assistant | Same as P1/P2, asked programmatically (see §8.9 — this is the highest-leverage consumer) |

P7 matters more than it looks. If the catalog is readable by a functional consultant, requirements arrive already grounded in what is technically available, which removes an entire round-trip from every interface design.

### 2.4 Value and success measures

| Outcome | Measure | Baseline | Target |
|---|---|---|---|
| Faster discovery | Median time to answer "does an API exist for X" | Hours–days (informal) | < 5 minutes |
| Less duplication | New interface builds where an existing API was found and reused | Not measured | ≥ 30% of candidate builds reuse |
| Clean-core posture | Custom services with an identified released SAP alternative | Unknown | Inventory established, retirement backlog created |
| Upgrade safety | Time to answer "what breaks if this CDS view changes" | Manual where-used, days | Minutes, from the lineage graph |
| Security surface | Active services with zero usage in 12 months | Unknown | Identified and decommission-proposed |
| Documentation coverage | Services with an owner and an accepted description | Low | ≥ 80% of custom services |

Baselines are unknown for most rows. **Capture them during Phase 0** — otherwise there is no story at the end of Phase 1.

### 2.5 Scope

**In scope, Phase 1:** OData V2 and OData V4 services registered in S/4HANA, both custom and SAP-standard-activated, across all systems in the landscape (DEV / QAS / PRD, plus any sandbox or project systems).

Including SAP-standard-activated services is deliberate and cheap — they come through the same pipeline. The value is high: "which SAP standard API is actually switched on in *our* PRD" is a question `api.sap.com` cannot answer, because it describes what SAP ships, not what we activated.

**In scope, later phases:** SOAP services (SOAMANAGER), released RFC/BAPI, Enterprise Event Enablement topics, CDS views exposed as analytical queries, Cloud Integration iFlow endpoints, API Management proxies, CAP services on BTP.

**Out of scope:** runtime traffic proxying (the hub is a catalog, not a gateway — API Management already does that, see §3), payload-level data, test data management, replacing `/IWFND` administration.

---

## 3. Standard-first check — what SAP already offers

Required discipline before proposing a custom build. Three candidates exist and none of them close the gap.

**SAP Integration Suite — Developer Hub** ✅ (the capability previously branded *API Business Hub Enterprise*; note the rename when reading older blogs). This is genuinely a customer-owned, internal API catalog and portal: developers browse API Products, read documentation, subscribe, and get application credentials. It is the right home for APIs we intend to *expose and govern* as products.

Why it does not solve this requirement: **it has no discovery mechanism.** ✅ An API appears in the Developer Hub only after someone manually creates an API Management proxy for the backend service, bundles it into a Product, and publishes it. Nothing crawls the Gateway catalog. So the Developer Hub tells you about the handful of APIs somebody already curated; it is silent about the several thousand registered services that are the actual problem.

**The right relationship is complementary, and it should be in the design:**

```
   All registered services                  Curated, governed, exposed subset
   (thousands, mostly undocumented)         (tens, proxied and productised)
   ┌──────────────────────────┐             ┌──────────────────────────┐
   │      API Atlas           │  promote →  │   Developer Hub          │
   │  inventory & discovery   │             │   (Integration Suite)    │
   │  harvested automatically │             │   publication & access   │
   └──────────────────────────┘             └──────────────────────────┘
```

API Atlas is the *inventory* layer; Developer Hub is the *publication* layer. A "Promote to Developer Hub" action in API Atlas (Phase 3) that creates the APIM proxy and Product from harvested metadata makes the two one workflow rather than two competing catalogs. Say this explicitly in any steering conversation, because the first challenge you will get is "don't we already have this in Integration Suite."

**SAP Business Accelerator Hub (api.sap.com):** ✅ public, SAP-delivered APIs only, no private customer content. Not a candidate. It *is* however a useful **input** to the hub — see §8.10.

**SAP LeanIX:** ✅ has Interface Modeling for documenting application-to-application interfaces in the EA landscape, and an adapter that imports Integration Suite artifacts. It is a governance and architecture-mapping tool operating at application-to-application granularity, not a runtime harvester of backend service catalogs, and it does not model entities, properties or operations. Relevant as a downstream consumer (publish confirmed interfaces into the EA map), not as the solution.

**SAP Cloud ALM / SAP Signavio:** ✅ neither has a custom API catalog capability. Not relevant.

**Conclusion:** the gap is real and the custom build is justified. The build is an *inventory and discovery* layer, and it must integrate with the Developer Hub rather than compete with it.

---

## 4. Functional design

### 4.1 Capability map

| # | Capability | Phase | Notes |
|---|---|---|---|
| F1 | Automated harvest of service catalog + `$metadata`, all systems | 1 | The foundation — everything else is a view over this |
| F2 | Hybrid search (natural language + keyword) across service, entity, property, operation | 1 | The hero feature |
| F3 | Faceted filtering and result ranking | 1 | |
| F4 | Service detail page — overview, entities, operations, annotations, raw metadata | 1 | |
| F5 | Entity detail — property table, capabilities, navigation, value helps | 1 | |
| F6 | AI-generated business description and classification | 1 | Advisory, always flagged as AI-generated |
| F7 | Field-level reverse lookup ("which API exposes net value?") | 1 | Falls out of the data model for free |
| F8 | Curation workbench — owner edits, approves, tags, deprecates | 2 | |
| F9 | Change detection between harvests, breaking-change classification | 2 | |
| F10 | Release snapshots and A-vs-B diff | 2 | The "what's coming in the next release" requirement |
| F11 | Subscriptions and notifications (email / Teams) | 2 | |
| F12 | Duplicate / overlap detection between services | 2 | Embedding-based clustering |
| F13 | Usage statistics and consumer mapping | 2 | V2 only — see the V4 gap in §6.3 |
| F14 | OpenAPI 3.x + Postman export, copy-paste code snippets | 2 | |
| F15 | Backend lineage (service → CDS view → table) | 3 | Best-effort; highest analytical value |
| F16 | SOAP / RFC / events / CPI / APIM sources | 3 | |
| F17 | Comparison against SAP standard APIs from api.sap.com | 3 | The custom-code retirement engine |
| F18 | "Promote to Developer Hub" | 3 | |
| F19 | MCP server — catalog as a tool for AI coding assistants | 2 | Disproportionate value, small effort (§8.9) |

### 4.2 Search behaviour — the part that must be right

Search is the product. If it returns the wrong three things, nobody comes back.

**Query types to support:**

| Query the user types | What must happen |
|---|---|
| `ZSD_SALES_SRV` | Exact technical name match, ranked first, always |
| `sales order` | Lexical match on labels + semantic match on descriptions |
| `which API gives me customer credit exposure` | Semantic — no literal term overlap with the metadata |
| `NETWR` | Property-level match, return the services containing it |
| `net value` | Property *label* match — labels are the richest semantic signal in EDMX and must be indexed |
| `I_SalesOrder` | Lineage match — services built on that CDS view |
| `delta enabled billing api` | Semantic + capability facet combination |

**Ranking model.** Hybrid retrieval, fused with Reciprocal Rank Fusion:

1. **BM25 lexical** over a denormalised text document per searchable object (name, label, description, tags, synonyms, property labels)
2. **Vector similarity** over an embedding of the same document ✅ (HANA Cloud supports both natively, with RRF fusion — no PAL required)
3. **Boosts applied after fusion:**
   - Exact technical-name match → pin to top
   - Human-curated description present → ×1.4 (curation should visibly pay off, this is what drives adoption of F8)
   - High usage in PRD → ×1.2 (popular APIs are usually the right answer)
   - Lifecycle `DEPRECATED` → ×0.3, `RETIRED` → excluded unless explicitly filtered in
   - Origin `SAP_STANDARD` released → ×1.3 **(deliberate clean-core nudge: if a released SAP API and a Z-service both match, the standard one surfaces first)**

That last boost is a one-line rule that makes the search engine an instrument of clean-core policy. Worth calling out to the architecture board.

4. Optional **LLM re-rank** of the top 20 for natural-language queries only. Adds ~1s latency and per-query cost; make it a setting, measure whether it beats RRF on the golden set before switching it on by default.

**Result presentation:** each hit shows service name, AI or curated one-line summary, API type badge, system availability badges (`DEV QAS PRD`), matched-field highlighting ("matched on property label: *Net Amount*"), usage indicator, and lifecycle status. Showing *why* something matched is what makes a search engine feel trustworthy.

### 4.3 Screens

| Screen | Purpose | Key content |
|---|---|---|
| **S1 Search** | Landing page. Single search box, facet rail, ranked results | Facets: system, API type, OData version, origin, business domain, lifecycle, owner, draft-enabled, has-actions, changed-since |
| **S2 Service detail** | Everything about one service | Header (name, type, version, systems, owner, lifecycle, usage sparkline); tabs: Overview (AI/curated summary, business purpose, tags, sample query), Entities, Operations, Annotations, Lineage, Consumers, Changelog, Raw `$metadata` |
| **S3 Entity detail** | Property-level truth | Property grid (name, label, EDM type, length, key, nullable, creatable/updatable/filterable/sortable, unit/currency ref, value help, backing field); navigation properties with cardinality; capability summary |
| **S4 Operation detail** | Actions / functions / function imports | Kind, bound entity, HTTP method, parameters, return type, side-effecting flag |
| **S5 Compare / diff** | Two services, or one service across two snapshots | Added / removed / changed, colour-coded by breaking classification |
| **S6 Curation workbench** | Owner-facing. Review AI output, accept/edit, assign owner, set lifecycle | Work queue: "12 services you own have unreviewed AI descriptions" |
| **S7 Governance dashboard** | Architect / Basis facing | Documentation coverage, unowned services, duplicate candidates, zero-usage active services, deprecated-but-still-called, breaking changes this release |
| **S8 Release view** | Snapshot selector + delta feed | "What's new in Release 24.3" — the future-enhancement requirement, promoted to a first-class screen |

### 4.4 AI enrichment — functional behaviour

What the LLM is asked to do, and — more importantly — what it is *not* allowed to do.

**Generates, per service and per entity:** a one-line summary, a business purpose paragraph, a line-of-business classification (SD / MM / FI / PP / QM / PM / CROSS) with confidence, suggested tags, search synonyms, a plausible sample OData query, and consumption warnings ("entity has 180 properties and no server-side paging annotation").

**Hard rules, enforced in the prompt and validated in code:**

- The model may only describe what is in the metadata. It must not infer business process behaviour it cannot see.
- If a service's names and labels are too cryptic to interpret, it must return `null` and a `reason`, not a guess. **A confident wrong description is worse than no description**, because a developer will act on it.
- Output is strict JSON against a fixed schema; anything that fails validation is discarded and retried once, then logged as an enrichment failure.
- Every AI-generated field is stored separately from harvested facts and from human-curated content, is displayed with an "AI-generated" marker, and is **never** written over a human edit.

**Curation loop:** owner reviews in S6 → accept / edit / reject. Accepted and edited content becomes curated content, which outranks AI content in display and in search. Rejected content triggers a prompt-improvement backlog item. Plus a lightweight crowdsourced layer — any developer can 👍/👎 a description or leave a usage note. Cheap, and it surfaces the bad descriptions far faster than a review campaign will.

### 4.5 Change detection and release variants

Two related requirements from the original idea, and they share one mechanism.

**Change detection.** Every harvest computes a hash of the normalised metadata per service. Unchanged → stamp `lastSeenAt`, stop. Changed → structural diff against the previous version, emitting typed change events classified as **breaking / potentially breaking / non-breaking** (rules in §8.4). This drives the changelog tab, the change feed, notifications, and the governance dashboard.

**Release variants.** A `ReleaseSnapshot` pins the exact set of metadata versions present in a system at a moment, under a label — `PRD 2026-09`, `QAS Release 24.3`, `SBX after 2025 FPS02`. The UI gets a snapshot selector; all search and detail views can be pinned to one. Then:

- *"What is coming in Release 24.3"* = diff(`PRD current`, `QAS Release 24.3`)
- *"What did the SAP upgrade change"* = diff(`SBX before FPS02`, `SBX after FPS02`), which is a genuinely painful question today
- *"What is in DEV that never made it to PRD"* = set difference, and a good hygiene report

This is why release variants need to be in the data model from day one even though the feature ships in Phase 2. Retrofitting history into a model that only stores current state is a rewrite. **Design for snapshots now, build the UI later.**

### 4.6 Governance and ownership

An API with no owner gets no curation and no lifecycle decisions. Seed ownership automatically: `TADIR` author and package → responsible team, via a mapping table. Then let teams correct it. An unowned custom service is itself a governance finding and belongs on the S7 dashboard.

Lifecycle states: `DRAFT` → `ACTIVE` → `DEPRECATED` (with `deprecatedOn`, `replacedBy`, and a reason) → `RETIRED`. Deprecated services stay searchable but rank low and carry a visible banner with the replacement. "Deprecated but still receiving calls" is one of the most actionable reports the hub can produce.

### 4.7 Non-functional requirements

| Area | Requirement | Note |
|---|---|---|
| Search latency | p95 < 1 s without LLM re-rank; < 2.5 s with | |
| Catalog scale | 5,000 services / 100,000 entities / 2,000,000 properties | `[ASSUMPTION — confirm]` against actual counts in Phase 0 |
| Harvest window | Full landscape harvest < 4 h, off-peak | Delta harvests minutes |
| Source system impact | Read-only, throttled, no PRD impact during business hours | Hard constraint — this must never be the reason PRD is slow |
| Freshness | DEV daily, QAS/PRD daily, on-demand harvest available | |
| Availability | 99% business hours. Not business-critical — if it's down, developers wait | Keep the SLA honest; it changes the cost |
| Data classification | Metadata only. No business data ever leaves S/4HANA | See §9 |
| Accessibility | SAP Fiori accessibility standards | |
| Browser | Chromium + Edge current, as per corporate standard | |

---

## 5. Solution options considered

| # | Option | Verdict |
|---|---|---|
| A | **Use Integration Suite Developer Hub as-is** | ❌ Rejected. No auto-discovery; every API must be manually proxied and curated (§3). Solves publication, not the discovery problem. Retained as a Phase-3 integration target. |
| B | **On-stack only** — RAP application inside S/4HANA | ❌ Rejected. Single-system by nature (cross-system harvest needs outbound HTTP anyway); consumes ERP resources for a developer tool; hybrid vector search and LLM orchestration are far weaker on-stack; a developer portal has no business living in the ERP. |
| C | **Side-by-side, BTP ABAP Environment (Steampunk) + RAP** | ⚠️ Viable. Strong if the team is ABAP-only — RAP + Fiori Elements + a familiar toolchain. Weaker for the AI pipeline, EDMX/JSON parsing ergonomics, and the freestyle search UX. Keep as fallback if CAP/Node skills are unavailable. |
| D | **Side-by-side, BTP CAP (Node.js) + HANA Cloud + Generative AI Hub** | ✅ **Recommended.** Best fit for the AI enrichment pipeline (official SDK, §6.2), native hybrid vector search in HANA Cloud, good XML/JSON parsing ecosystem, freestyle UI where needed, Fiori Elements where it fits. |
| E | **Non-SAP stack** — Python/FastAPI + Postgres/pgvector + React | ❌ Rejected. Fastest to prototype and the team could go faster short-term, but loses BTP SSO/IAS, destination and Cloud Connector integration, Work Zone placement, and the operational model. Acceptable *only* as a throwaway Phase-0 spike, and only if nothing built there is carried forward. |
| F | **Buy a commercial API catalog** (Backstage, Apicurio, commercial API governance tooling) | ⚠️ Worth a Phase-0 look. Backstage + a custom S/4 harvester plugin is a real option and gives the portal shell for free. Rejected as the primary recommendation because the hard part — SAP-specific harvesting, EDMX semantics, lineage, clean-core classification — is custom either way, and BTP keeps it inside the SAP identity and operations model. `[CONFIRM]` whether corporate already has a developer-portal standard we must adopt. |

---

## 6. Recommended architecture

### 6.1 Component view

```
┌─ SAP S/4HANA landscape ──────────────┐
│  DEV        QAS        PRD    SBX    │
│   │          │          │      │     │
│   └──── Gateway catalog services ────┤   released, read-only, HTTPS
│         + $metadata endpoints        │
│   [optional] ZAPI_CATALOG_PROBE      │   on-stack gap-filler, §6.3
└───────────────┬──────────────────────┘
                │  Cloud Connector (no inbound to S/4)
┌───────────────▼──────────────────────────────────────────────┐
│ SAP BTP — Cloud Foundry                                      │
│                                                              │
│  ┌────────────┐   ┌────────────┐   ┌──────────────────────┐  │
│  │ Collector  │──▶│  Parser &  │──▶│  Diff & Change       │  │
│  │ (per sys)  │   │  Normaliser│   │  Classifier          │  │
│  └────────────┘   └────────────┘   └──────────┬───────────┘  │
│        ▲                                      │              │
│  Job Scheduling                               ▼              │
│                              ┌───────────────────────────┐   │
│                              │  SAP HANA Cloud           │   │
│  ┌────────────────┐          │  • staging (raw EDMX)     │   │
│  │ AI Enrichment  │◀────────▶│  • core catalog model     │   │
│  │ @sap-ai-sdk    │          │  • enrichment + curation  │   │
│  └───────┬────────┘          │  • REAL_VECTOR + fulltext │   │
│          │                   └───────────────┬───────────┘   │
│          ▼                                   │               │
│  ┌────────────────┐          ┌───────────────▼───────────┐   │
│  │ SAP AI Core /  │          │  CAP service layer        │   │
│  │ Generative AI  │          │  OData V4 + REST + MCP    │   │
│  │ Hub            │          └───────────────┬───────────┘   │
│  └────────────────┘                          │               │
│                              ┌───────────────▼───────────┐   │
│                              │ UI5 search app (freestyle)│   │
│                              │ + Fiori Elements back-off │   │
│                              └───────────────────────────┘   │
│  XSUAA + IAS · Destination · Connectivity · Alert Notif.     │
└──────────────────────────────────────────────────────────────┘
        │ Phase 3
        └──▶ Integration Suite Developer Hub  ·  SAP LeanIX  ·  api.sap.com ingest
```

### 6.2 BTP services required

| Service | Plan | Purpose | Note |
|---|---|---|---|
| SAP HANA Cloud | HANA database | Catalog + staging + vector + full-text | Sizing in §7.5 |
| Cloud Foundry runtime | — | CAP app, collector, enrichment worker | ~3–4 GB total `[ASSUMPTION — confirm]` |
| SAP AI Core | extended | Generative AI Hub access | `extended` plan needed for GenAI Hub `[VERIFY]` |
| Destination + Connectivity | lite | Reach S/4 via Cloud Connector | |
| Authorization & Trust (XSUAA) | application | Scopes / role collections | |
| Identity Authentication (IAS) | — | Corporate SSO | Presumably already in place |
| Job Scheduling | standard | Harvest schedules | Or Kyma CronJob if Kyma is the standard runtime |
| Alert Notification | standard | Subscription emails, harvest failure alerts | |
| Application Logging / Cloud Logging | standard | | |
| SAP Build Work Zone | standard | Launchpad placement | Optional but improves discoverability of the discovery tool |

**LLM access from CAP:** use the **SAP Cloud SDK for AI** — ✅ the `@sap-ai-sdk/*` npm family (`@sap-ai-sdk/orchestration` for the orchestration service with content filtering / masking / model fallback, `@sap-ai-sdk/foundation-models` for direct calls). ✅ SAP's own architecture guidance now directs new productive use cases here; the community `cap-llm-plugin` is described as limited-scope and for existing implementations only — **do not start with it.**

**Note for the ABAP option (C):** ✅ if the build goes on-stack, calling Generative AI Hub from ABAP is officially supported — the **ABAP AI SDK powered by ISLM**, included in standard delivery for S/4HANA 2025, which is our target release. So option C is not blocked on AI access; it is chosen against on ergonomics, not capability.

### 6.3 Collector design, and the honest gap list

Harvesting is where the design meets reality. Three of the four sources we want are cleanly available; some are not.

**Available as published catalog services over HTTPS — no S/4 footprint:**

| What | Endpoint | Status |
|---|---|---|
| V2 service list | `/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/ServiceCollection` | ✅ Verified. Returns registered + activated V2 services with technical name, namespace, description, endpoint URL |
| V2 entity sets per service | `ServiceCollection('<id>')/EntitySets` | ✅ |
| V4 service groups | `/sap/opu/odata4/iwfnd/config/default/iwfnd/catalog/0002/ServiceGroups` | ✅ Verified. Use `$expand=DefaultSystem($expand=Services)` to reach individual services |
| Metadata, any service | `<serviceUrl>/$metadata` | The authoritative content |

**The gaps — state these plainly, they shape the plan:**

1. **V4 service groups must be *published*** (via `/IWFND/V4_ADMIN` → Publish Service Groups → system alias `LOCAL`) before they appear in the V4 catalog. ✅ Verified. Unpublished groups are invisible to the harvester. So the catalog will initially under-report V4 — and discovering *that* is itself a useful finding. **Mitigation:** cross-check catalog output against the developer-side registry and report the delta as a governance finding ("14 V4 service bindings exist that are not published").

2. **No released CDS view or API for V4 service binding enumeration** was found. ✅ (searched; none in current documentation) `[VERIFY]` against the S/4HANA 2025 released-objects list in ADT before accepting this. If none exists, the only complete source is the `/IWFND/` namespace tables, which are **not released**.

3. **OData V4 call statistics are not in `/IWFND/STATS` — but they are obtainable elsewhere.** ✅ Verified — SAP KBA 3732359 confirms `/IWFND/STATS` shows V2 only and that there is no dedicated V4 monitoring transaction. **However, the same KBA documents a workaround:** transaction **`STATS`** with Task Type `T` (HTTPS) or `H` (HTTP), then the *Gateway* tab. KBA 2629143 additionally points to **ST03 Web Server Statistics filtered on `*opu/odata*`**. Both work for V4 because V4 calls are ordinary HTTP calls — the gap is in the Gateway-specific statistics layer, not in the HTTP layer beneath it.
   **Consequence:** usage features (F13, zero-usage reports, usage ranking boost) are **available for both V2 and V4, from two different sources at different granularity** — per-service metering for V2, HTTP-path-level statistics for V4. Model this in `UsageStat.dataSource` (values `IWFND_STATS`, `STATS_HTTP`, `ST03_WEBSTATS`, `APIM`, `CPI`) and **display the granularity honestly in the UI** rather than implying the two are equivalent. Per-service attribution for V4 requires parsing the service path out of the HTTP URL — feasible, since the path contains the service name, but `[VERIFY]` the field is not truncated at the lengths involved.

4. **SOAP, RFC, lineage** have no HTTP catalog equivalent at all.

**Therefore: an optional thin on-stack collector, `ZAPI_CATALOG_PROBE`.** A read-only ABAP Cloud RAP service exposing a single OData V4 API that returns what HTTPS cannot reach: complete V4 binding inventory, V2 usage statistics, SOAP service registry, and (Phase 3) lineage resolved via XCO from service definition → projection view → base view → tables.

**Clean-core position on this component, stated honestly:**

- Everything it can read through released APIs and XCO → **Level A**.
- Where it must read `/IWFND/` statistics or registry tables directly → **Level C** (non-released SAP objects, no stability contract, changelog check required at every upgrade).
- **Containment:** one dedicated package (`ZAPI_PROBE`), every non-released read isolated behind a single interface with one implementation class per source, an ATC allowlist entry per object, a dated ADR exception with a named owner, and a remediation trigger — "replace with the released API the moment SAP publishes one."
- The BTP application itself never becomes non-compliant; it consumes `ZAPI_CATALOG_PROBE` as just another OData source.

**Phase the probe.** Phase 1 uses HTTPS catalog services only — Level A throughout, no ABAP transport, no exception paperwork, fastest to value. Introduce the probe in Phase 2 when usage statistics and complete V4 coverage are needed, by which time the hub has proven itself and the exception is easy to justify.

### 6.4 Clean core assessment

**Overall: 🟢 Level A** for the recommended Phase-1 architecture. 🟡 Level A with one contained Level-C component from Phase 2, under a documented exception.

Assessed across all six dimensions per our project standards:

| Dimension | Position |
|---|---|
| 1. Software stack | No modification to SAP standard. Phase 1 adds nothing to S/4HANA except a technical user and a role. |
| 2. Extensions | Tier 3 (side-by-side BTP). The optional on-stack probe is Tier 2 where it uses released APIs, Tier 4 where it reads `/IWFND/` tables — exception-gated, contained, with a remediation target. |
| 3. Data | Read-only throughout. No writes to any SAP table, ever. Metadata only — no business data is extracted, stored, or sent to an LLM. |
| 4. Integrations | Consumes published Gateway catalog services over HTTPS via Cloud Connector. No RFC, no point-to-point custom interface. Phase-3 outbound publication goes through Integration Suite. |
| 5. Processes | Adds no business process. Changes a *development* process — and in the direction SAP wants: reuse before build, released API before custom. |
| 6. Operations | Standard BTP operations — Job Scheduling, Alert Notification, Cloud Logging. Harvest is throttled and off-peak so PRD is never affected. |

**The self-referential point worth making:** this tool's purpose is to improve dimensions 2, 4 and 5 across the whole estate. A clean-core programme without an inventory of what is actually exposed is running blind. That framing is the business case.

---

## 7. Data model

> The critical step, as stated in the original idea. Everything below is designed so that features F7–F19 are *queries*, not schema changes.

### 7.1 Design principles

Seven decisions, each of which is expensive to reverse later.

1. **Separate the logical API from its deployments.** `ApiAsset` is the logical thing ("the billing request service"); `ApiDeployment` is its presence in one system at one point in time. Without this split you cannot answer "is this in PRD yet" or "does DEV differ from PRD" without duplicating every row per system.

2. **Separate metadata *version* from deployment.** Schema detail (entities, properties, operations) hangs off `MetadataVersion`, keyed by a content hash — not off the deployment. When DEV, QAS and PRD all run identical metadata, the entity/property rows are stored **once** and three deployments point at them. At ~2M property rows across 4 systems this is the difference between 2M rows and 8M, and — more importantly — it makes "has this actually changed between systems?" a single hash comparison instead of a deep diff.

3. **Separate harvested fact / AI inference / human curation into three layers.** Never one `description` column. Harvested facts are overwritten freely on every run; AI content is regenerated when the input hash changes; curated content is sacred and is never touched by the pipeline. Conflating these means the next harvest silently destroys a week of curation, which kills adoption permanently.

4. **Store annotations generically, project selectively.** OData annotation vocabularies (`Common`, `UI`, `Capabilities`, `Core`, `Analytics`, `ObjectModel`, plus the whole `sap:` V2 family) are open-ended and grow every release. Modelling each as a column guarantees schema churn. Store all of them in a generic `ApiAnnotation` bag, and *project* the dozen that drive features (creatable, filterable, value list, semantic object, draft) into typed columns on the entity/property rows for query performance.

5. **Model change as first-class data, not as an audit log.** `ChangeEvent` rows are queryable, classifiable, notifiable and reportable. A generic change-document table is not.

6. **Make snapshots explicit from day one.** Even though the release-variant UI is Phase 2 (see §4.5).

7. **Make the API type an attribute, not a table.** `ApiAsset.apiType` covers `ODATA_V2 | ODATA_V4 | SOAP | REST_ICF | RFC_BAPI | EVENT_TOPIC | CDS_VIEW | CPI_IFLOW | APIM_PROXY`. Everything downstream generalises: a SOAP operation and an OData function import are both `ApiOperation`; a WSDL complex type and an EDM entity type are both `ApiEntity`. Phase 3 then adds parsers, not schema. **This is the decision that makes the tool outlive the OData-only version of the idea.**

### 7.2 Entity overview

```
SapSystem ──< ApiDeployment >── ApiAsset ──< CuratedContent
    │              │                 │
    │              │                 ├──< ApiEnrichment
    │              │                 ├──< ChangeEvent
    │              │                 └──< ApiConsumption >── Consumer
    │              │
    │              ├── MetadataVersion ──< ApiEntity ──< ApiProperty
    │              │          │                │              │
    │              │          │                ├──< ApiNavigation
    │              │          │                └──< ApiLineage >── BackendObject
    │              │          ├──< ApiOperation ──< ApiOperationParameter
    │              │          ├──< ApiComplexType ──< ApiComplexTypeProperty
    │              │          └──< ApiAnnotation      (polymorphic target)
    │              │
    │              └──< UsageStat
    │
    ├──< HarvestRun ──< HarvestError
    └──< ReleaseSnapshot ──< SnapshotContent

SearchDocument   (denormalised, rebuilt from the above — fulltext + REAL_VECTOR)
DuplicateCandidate · Subscription · Feedback · OwnerTeam
```

### 7.3 CDS definitions

CAP CDS. Compiles to HANA; `[CONFIRM]` field lengths against real data in Phase 0.

```cds
namespace com.acme.apicatalog;

using { cuid, managed } from '@sap/cds/common';

// ─────────────────────────────────────────────────────────────
// Landscape and harvest control
// ─────────────────────────────────────────────────────────────

entity SapSystem : cuid, managed {
  sid                 : String(3)  @mandatory;   // e.g. S4D
  client              : String(3);
  description         : String(120);
  systemRole          : SystemRole;              // DEV | QAS | PRD | SBX | PROJECT
  productVersion      : String(60);              // 'S/4HANA 2025'
  supportPackage      : String(20);              // 'SP02' / 'FPS02'
  baseUrl             : String(255);
  destinationName     : String(120);             // BTP destination
  isActive            : Boolean default true;
  harvestSchedule     : String(60);              // cron
  harvestEnabled      : Boolean default true;
  sortOrder           : Integer;                 // DEV<QAS<PRD for UI badges
  deployments         : Association to many ApiDeployment on deployments.system = $self;
}

type SystemRole   : String(10) enum { DEV; QAS; PRD; SBX; PROJECT; }
type HarvestStatus: String(12) enum { RUNNING; SUCCESS; PARTIAL; FAILED; }

entity HarvestRun : cuid {
  system              : Association to SapSystem;
  startedAt           : Timestamp;
  finishedAt          : Timestamp;
  status              : HarvestStatus;
  triggerType         : String(12);              // SCHEDULED | MANUAL | SNAPSHOT
  triggeredBy         : String(120);
  servicesDiscovered  : Integer;
  servicesNew         : Integer;
  servicesChanged     : Integer;
  servicesRemoved     : Integer;
  servicesFailed      : Integer;
  collectorVersion    : String(20);
  parserVersion       : String(20);
  errors              : Composition of many HarvestError on errors.run = $self;
}

entity HarvestError : cuid {
  run                 : Association to HarvestRun;
  serviceName         : String(120);
  serviceUrl          : String(500);
  phase               : String(20);              // CATALOG | METADATA | PARSE | PERSIST | ENRICH
  httpStatus          : Integer;
  message             : String(2000);
  isRetryable         : Boolean;
  occurredAt          : Timestamp;
}

// A pinned view of a system at a point in time — powers release variants (§4.5)
entity ReleaseSnapshot : cuid, managed {
  label               : String(80) @mandatory;   // 'QAS Release 24.3'
  system              : Association to SapSystem;
  harvestRun          : Association to HarvestRun;
  snapshotType        : String(16);              // RELEASE | UPGRADE | BASELINE | ADHOC
  plannedGoLive       : Date;
  description         : String(500);
  isLocked            : Boolean default false;   // locked snapshots are never purged
  content             : Composition of many SnapshotContent on content.snapshot = $self;
}

entity SnapshotContent : cuid {
  snapshot            : Association to ReleaseSnapshot;
  apiAsset            : Association to ApiAsset;
  metadataVersion     : Association to MetadataVersion;
  isActiveInSystem    : Boolean;
}

// ─────────────────────────────────────────────────────────────
// The logical API and its physical presence
// ─────────────────────────────────────────────────────────────

type ApiType        : String(16) enum {
  ODATA_V2; ODATA_V4; SOAP; REST_ICF; RFC_BAPI; EVENT_TOPIC;
  CDS_VIEW; CPI_IFLOW; APIM_PROXY; CAP_SERVICE;
}
type ApiOrigin      : String(16) enum { SAP_STANDARD; CUSTOM; PARTNER; BTP_NATIVE; }
type SourceTech     : String(20) enum { RAP; SEGW; SADL; SOAMANAGER; CLASSIC_BOR; CAP; UNKNOWN; }
type Lifecycle      : String(12) enum { DRAFT; ACTIVE; DEPRECATED; RETIRED; }
type ReleaseState   : String(20) enum { RELEASED; RELEASED_RESTRICTED; NOT_RELEASED; UNKNOWN; }

entity ApiAsset : cuid, managed {
  technicalName       : String(120) @mandatory;  // ZSD_SALES_ORDER_SRV
  namespaceName       : String(60);              // /SAP/ or customer namespace
  title               : String(255);             // harvested description
  apiType             : ApiType;
  apiOrigin           : ApiOrigin;
  sourceTechnology    : SourceTech;

  // Repository provenance — from TADIR / probe, best effort
  packageName         : String(60);
  softwareComponent   : String(30);
  createdByUser       : String(60);
  createdOn           : Date;
  lastChangedByUser   : String(60);
  lastChangedOn       : Date;

  // Governance
  ownerTeam           : Association to OwnerTeam;
  ownerContact        : String(255);
  lifecycleStatus     : Lifecycle default 'ACTIVE';
  deprecatedOn        : Date;
  deprecationReason   : String(500);
  replacedBy          : Association to ApiAsset;          // retirement chain
  sapReleaseState     : ReleaseState;                     // for SAP_STANDARD assets
  criticality         : String(10);                       // LOW|MEDIUM|HIGH|CRITICAL

  // Classification — AI-proposed, curator-confirmed
  businessDomain      : String(20);              // SD | MM | FI | PP | QM | PM | CROSS
  businessSubdomain   : String(60);
  domainConfidence    : Decimal(3,2);
  domainConfirmedBy   : String(120);

  deployments         : Composition of many ApiDeployment  on deployments.apiAsset = $self;
  versions            : Composition of many MetadataVersion on versions.apiAsset  = $self;
  enrichment          : Composition of many ApiEnrichment  on enrichment.apiAsset = $self;
  curated             : Composition of one  CuratedContent on curated.apiAsset    = $self;
  changes             : Composition of many ChangeEvent    on changes.apiAsset    = $self;
  consumption         : Composition of many ApiConsumption on consumption.apiAsset= $self;
}

entity ApiDeployment : cuid {
  apiAsset            : Association to ApiAsset;
  system              : Association to SapSystem;
  metadataVersion     : Association to MetadataVersion;

  serviceVersion      : Integer;                 // V2 technical service version
  serviceGroupId      : String(120);             // V4
  serviceBindingName  : String(120);             // V4
  systemAlias         : String(60);              // V4 default system, usually LOCAL
  relativeUrl         : String(500);             // /sap/opu/odata/sap/ZXYZ_SRV
  isActive            : Boolean;
  isPublished         : Boolean;                 // V4: published to the catalog
  authMethods         : String(120);             // BASIC,OAUTH2,SAML,X509,PRINCIPAL_PROP
  csrfRequired        : Boolean;

  firstSeenAt         : Timestamp;
  lastSeenAt          : Timestamp;               // stamped every harvest
  lastChangedAt       : Timestamp;               // only when the hash changes
  lastHarvestRun      : Association to HarvestRun;
  usage               : Composition of many UsageStat on usage.deployment = $self;
}

// Deduplicated schema snapshot. Identical metadata across systems = one row.
entity MetadataVersion : cuid {
  apiAsset            : Association to ApiAsset;
  contentHash         : String(64) @mandatory;   // sha256 of normalised document
  odataVersion        : String(10);              // 2.0 | 4.0
  schemaNamespace     : String(120);
  edmxVersion         : String(10);

  entityCount         : Integer;
  propertyCount       : Integer;
  operationCount      : Integer;
  navigationCount     : Integer;
  annotationCount     : Integer;
  documentSizeBytes   : Integer;

  parsedAt            : Timestamp;
  parserVersion       : String(20);
  firstSeenAt         : Timestamp;
  rawDocumentRef      : String(500);             // Object Store key; not inline
  rawDocument         : LargeString;             // only if < threshold, else null

  entities            : Composition of many ApiEntity       on entities.metadataVersion   = $self;
  operations          : Composition of many ApiOperation    on operations.metadataVersion = $self;
  complexTypes        : Composition of many ApiComplexType  on complexTypes.metadataVersion = $self;
}
```

**Schema detail — entities, properties, operations:**

```cds
entity ApiEntity : cuid {
  metadataVersion     : Association to MetadataVersion;
  entityTypeName      : String(120) @mandatory;  // A_SalesOrderType
  entitySetName       : String(120);             // A_SalesOrder  (null if not addressable)
  label               : String(255);             // sap:label / @EndUserText.label — the gold
  labelLanguage       : String(2);
  qualifiedName       : String(255);

  isAddressable       : Boolean;
  isDraftEnabled      : Boolean;
  draftSiblingName    : String(120);
  isParameterized     : Boolean;                 // V2 parameterised entity sets
  isMediaEntity       : Boolean;
  hasStream           : Boolean;

  // Capabilities — projected from annotations for queryability (principle 4)
  isCreatable         : Boolean;
  isUpdatable         : Boolean;
  isDeletable         : Boolean;
  isSearchable        : Boolean;
  isFilterable        : Boolean;
  isSortable          : Boolean;
  isCountable         : Boolean;
  isPageable          : Boolean;
  requiresFilter      : Boolean;                 // sap:requires-filter — big consumption gotcha
  supportsDelta       : Boolean;
  maxPageSize         : Integer;

  semanticObject      : String(60);              // UI.SemanticObject
  keyPropertyNames    : String(500);             // denormalised, comma-separated, for display
  propertyCount       : Integer;

  properties          : Composition of many ApiProperty    on properties.entity = $self;
  navigations         : Composition of many ApiNavigation  on navigations.sourceEntity = $self;
  lineage             : Composition of many ApiLineage     on lineage.apiEntity = $self;
}

entity ApiProperty : cuid {
  entity              : Association to ApiEntity;
  name                : String(120) @mandatory;
  label               : String(255);             // sap:label — primary semantic signal
  quickInfo           : String(500);             // sap:quickinfo / @EndUserText.quickInfo
  ordinalPosition     : Integer;

  edmType             : String(60);              // Edm.String, Edm.Decimal, ...
  maxLength           : Integer;
  precisionValue      : Integer;
  scaleValue          : Integer;
  isNullable          : Boolean;
  defaultValue        : String(255);

  isKey               : Boolean;
  keyPosition         : Integer;
  isCreatable         : Boolean;
  isUpdatable         : Boolean;
  isFilterable        : Boolean;
  isSortable          : Boolean;
  isRequired          : Boolean;
  isHidden            : Boolean;                 // UI.Hidden

  unitProperty        : String(120);             // Measures.Unit reference
  currencyProperty    : String(120);             // Measures.ISOCurrency reference
  isUnitField         : Boolean;
  isCurrencyField     : Boolean;
  semanticType        : String(60);              // sap:semantics — tel, email, url ...

  valueHelpEntity     : String(120);             // Common.ValueList target
  valueHelpProperty   : String(120);
  hasFixedValues      : Boolean;
  fixedValuesJson     : LargeString;

  // Lineage, best effort — Phase 3
  backingCdsField     : String(120);
  backingTableField   : String(120);
  dataElement         : String(60);
  domainName          : String(60);

  // Classification
  sensitivityClass    : String(20);              // NONE | INTERNAL | PII | FINANCIAL
  sensitivitySource   : String(12);              // RULE | AI | HUMAN
}

entity ApiNavigation : cuid {
  sourceEntity        : Association to ApiEntity;
  name                : String(120);
  label               : String(255);
  targetEntity        : Association to ApiEntity;    // null when unresolved / cross-service
  targetEntityName    : String(255);                 // always populated
  cardinality         : String(6);                   // 0..1 | 1 | 0..* | 1..*
  isCollection        : Boolean;
  isComposition       : Boolean;                     // RAP composition vs association
  containsTarget      : Boolean;
  partnerName         : String(120);
  constraintsJson     : LargeString;                 // [{source,target}] referential constraints
}

type OperationKind : String(16) enum {
  FUNCTION_IMPORT; ACTION; FUNCTION; BOUND_ACTION; BOUND_FUNCTION; SOAP_OPERATION; RFC_MODULE;
}

entity ApiOperation : cuid {
  metadataVersion     : Association to MetadataVersion;
  name                : String(120) @mandatory;
  label               : String(255);
  operationKind       : OperationKind;
  isBound             : Boolean;
  boundEntity         : Association to ApiEntity;
  httpMethod          : String(8);               // GET | POST | PUT | PATCH | DELETE
  returnTypeName      : String(255);
  returnsCollection   : Boolean;
  returnEntity        : Association to ApiEntity;
  isSideEffecting     : Boolean;
  isComposable        : Boolean;
  parameters          : Composition of many ApiOperationParameter on parameters.operation = $self;
}

entity ApiOperationParameter : cuid {
  operation           : Association to ApiOperation;
  name                : String(120);
  label               : String(255);
  edmType             : String(60);
  maxLength           : Integer;
  isNullable          : Boolean;
  isCollection        : Boolean;
  ordinalPosition     : Integer;
  direction           : String(6);               // IN | OUT | INOUT  (RFC/SOAP)
}

entity ApiComplexType : cuid {
  metadataVersion     : Association to MetadataVersion;
  name                : String(120);
  label               : String(255);
  isEnum              : Boolean;
  properties          : Composition of many ApiComplexTypeProperty on properties.complexType = $self;
}

entity ApiComplexTypeProperty : cuid {
  complexType         : Association to ApiComplexType;
  name                : String(120);
  label               : String(255);
  edmType             : String(60);
  isNullable          : Boolean;
  ordinalPosition     : Integer;
}

// Generic annotation bag (principle 4) — keeps the model release-proof
entity ApiAnnotation : cuid {
  metadataVersion     : Association to MetadataVersion;
  targetKind          : String(12);              // SERVICE|ENTITY|PROPERTY|OPERATION|NAVIGATION|PARAM
  targetId            : UUID;                    // polymorphic — resolved in the service layer
  targetPath          : String(500);             // A_SalesOrder/NetAmount — human-readable fallback
  vocabulary          : String(40);              // Common|UI|Capabilities|Core|Analytics|ObjectModel|sap
  term                : String(120);
  qualifier           : String(120);
  valueJson           : LargeString;
}
```

**Lineage, enrichment, curation, change, usage, governance:**

```cds
// ── Lineage: the impact-analysis backbone (Phase 3)
entity BackendObject : cuid {
  system              : Association to SapSystem;
  objectType          : String(20);              // CDS_VIEW|TABLE|CLASS|FUNCTION_MODULE|BAPI|RAP_BO|BDEF
  name                : String(120);
  packageName         : String(60);
  softwareComponent   : String(30);
  apiReleaseState     : ReleaseState;            // is this a released SAP object?
  isCustom            : Boolean;
}

entity ApiLineage : cuid {
  apiEntity           : Association to ApiEntity;
  backendObject       : Association to BackendObject;
  relationType        : String(16);              // EXPOSES | READS | WRITES | DERIVED_FROM
  depth               : Integer;                 // 0 = direct, n = transitive
  resolutionSource    : String(12);              // XCO | PARSE | AI | MANUAL
  confidence          : Decimal(3,2);
}

// ── Layer 2: AI inference. Regenerated when inputHash changes. Never authoritative.
type ReviewStatus : String(16) enum { AI_GENERATED; HUMAN_REVIEWED; HUMAN_EDITED; REJECTED; }

entity ApiEnrichment : cuid, managed {
  apiAsset            : Association to ApiAsset;
  scopeKind           : String(12);              // ASSET | ENTITY | OPERATION | PROPERTY
  scopeId             : UUID;

  summaryShort        : String(200);
  summaryLong         : LargeString;
  businessPurpose     : LargeString;
  lobClassification   : String(20);
  lobConfidence       : Decimal(3,2);
  suggestedTags       : String(500);             // comma-separated
  synonyms            : String(500);             // feeds the lexical index
  sampleUseCase       : LargeString;
  sampleQuery         : String(1000);            // e.g. $filter=SalesOrderType eq 'OR'
  consumptionWarnings : LargeString;             // JSON array

  // Reproducibility and cost control
  modelId             : String(80);
  promptVersion       : String(20);
  inputHash           : String(64);              // skip regeneration if unchanged
  generatedAt         : Timestamp;
  inputTokens         : Integer;
  outputTokens        : Integer;

  reviewStatus        : ReviewStatus default 'AI_GENERATED';
  reviewedBy          : String(120);
  reviewedAt          : Timestamp;
  rejectionReason     : String(500);
}

// ── Layer 3: human truth. The pipeline NEVER writes here.
entity CuratedContent : cuid, managed {
  apiAsset            : Association to ApiAsset;
  description         : LargeString;
  usageGuidance       : LargeString;
  doNotUseReason      : String(1000);
  knownLimitations    : LargeString;
  exampleCode         : LargeString;
  documentationLinks  : String(2000);            // JSON array of {label,url}
  relatedTicketRefs   : String(500);
  manualTags          : String(500);
  lastReviewedAt      : Timestamp;
  reviewDueAt         : Date;                    // drives "stale documentation" reporting
}

// ── Change tracking
type ChangeType : String(28) enum {
  SERVICE_ADDED; SERVICE_REMOVED; SERVICE_DEACTIVATED; SERVICE_REACTIVATED;
  ENTITY_ADDED; ENTITY_REMOVED; ENTITYSET_RENAMED;
  PROPERTY_ADDED; PROPERTY_REMOVED; PROPERTY_TYPE_CHANGED; PROPERTY_LENGTH_CHANGED;
  PROPERTY_NULLABILITY_CHANGED; KEY_CHANGED;
  OPERATION_ADDED; OPERATION_REMOVED; OPERATION_SIGNATURE_CHANGED;
  NAVIGATION_ADDED; NAVIGATION_REMOVED; CARDINALITY_CHANGED;
  CAPABILITY_CHANGED; ANNOTATION_CHANGED; LABEL_CHANGED;
}
type Compatibility : String(20) enum { BREAKING; POTENTIALLY_BREAKING; NON_BREAKING; }

entity ChangeEvent : cuid {
  apiAsset            : Association to ApiAsset;
  system              : Association to SapSystem;
  harvestRun          : Association to HarvestRun;
  fromMetadataVersion : Association to MetadataVersion;
  toMetadataVersion   : Association to MetadataVersion;

  changeType          : ChangeType;
  compatibility       : Compatibility;
  objectPath          : String(500);             // A_SalesOrder/NetAmount
  oldValue            : String(1000);
  newValue            : String(1000);
  detectedAt          : Timestamp;
  aiChangeSummary     : String(1000);            // plain-language, for the change feed
  acknowledgedBy      : String(120);
  acknowledgedAt      : Timestamp;
}

// ── Usage and consumers  (V2 only — see the V4 gap in §6.3)
entity UsageStat : cuid {
  deployment          : Association to ApiDeployment;
  periodStart         : Date;
  periodType          : String(8);               // DAY | WEEK | MONTH
  callCount           : Integer64;
  errorCount          : Integer64;
  avgResponseMs       : Integer;
  maxResponseMs       : Integer;
  distinctUsers       : Integer;
  dataSource          : String(16);              // IWFND_STATS (V2, per-service) | STATS_HTTP (V4, path-level)
                                                 // | ST03_WEBSTATS | APIM | CPI | UNKNOWN
  granularity         : String(12);              // PER_SERVICE | PER_URL_PATH — display honestly, §6.3
}

entity Consumer : cuid, managed {
  name                : String(255);
  consumerType        : String(20);              // FIORI_APP|CPI_IFLOW|EXTERNAL|BTP_APP|MOBILE|SCRIPT
  ownerTeam           : Association to OwnerTeam;
  contactEmail        : String(255);
}

entity ApiConsumption : cuid {
  apiAsset            : Association to ApiAsset;
  consumer            : Association to Consumer;
  discoverySource     : String(16);              // STATS | MANUAL | APIM | CPI
  confidence          : Decimal(3,2);
  firstSeenAt         : Timestamp;
  lastSeenAt          : Timestamp;
}

// ── Governance and community
entity OwnerTeam : cuid, managed {
  name                : String(120);
  contactEmail        : String(255);
  packagePrefixes     : String(500);             // seeds automatic ownership assignment
  teamsChannelUrl     : String(500);
}

entity DuplicateCandidate : cuid {
  apiAssetA           : Association to ApiAsset;
  apiAssetB           : Association to ApiAsset;
  similarityScore     : Decimal(4,3);
  overlapSummary      : LargeString;             // shared entities / properties
  detectionMethod     : String(16);              // EMBEDDING | FIELD_OVERLAP | LINEAGE
  reviewStatus        : String(12);              // OPEN | CONFIRMED | DISMISSED
  reviewedBy          : String(120);
  resolutionNote      : String(1000);
}

entity Subscription : cuid, managed {
  userId              : String(120);
  scopeFilterJson     : LargeString;             // {domain:'SD', systems:['PRD'], apiAssets:[...]}
  channel             : String(12);              // EMAIL | TEAMS
  frequency           : String(12);              // IMMEDIATE | DAILY | WEEKLY
  onlyBreaking        : Boolean default false;
  isActive            : Boolean default true;
}

entity Feedback : cuid, managed {
  apiAsset            : Association to ApiAsset;
  userId              : String(120);
  rating              : Integer;                 // -1 | +1
  comment             : String(2000);
  feedbackType        : String(16);              // QUALITY | DOC_ERROR | USAGE_TIP
}

// ── Search index: denormalised, rebuilt by the pipeline
entity SearchDocument : cuid {
  docType             : String(12);              // ASSET | ENTITY | PROPERTY | OPERATION
  refId               : UUID;
  apiAsset            : Association to ApiAsset;
  system              : Association to SapSystem;

  titleText           : String(500);
  bodyText            : LargeString;             // name + labels + descriptions + tags + synonyms
  facetJson           : LargeString;             // pre-computed facet values
  boostFactor         : Decimal(3,2) default 1.0;
  embedding           : Vector(768);             // HANA REAL_VECTOR
  embeddingModel      : String(80);
  indexedAt           : Timestamp;
}
```

**HANA-specific DDL applied on top** (CAP does not express these):

```sql
-- Full-text index for the BM25 lexical leg of hybrid search
CREATE FULLTEXT INDEX FTI_SEARCHDOC_BODY
  ON "COM_ACME_APICATALOG_SEARCHDOCUMENT" ("BODYTEXT")
  TEXT ANALYSIS ON LANGUAGE DETECTION ('EN','DE') FUZZY SEARCH INDEX ON;

-- Hot paths
CREATE INDEX IDX_DEPLOY_SYS_ACTIVE ON ..._APIDEPLOYMENT (SYSTEM_ID, ISACTIVE);
CREATE INDEX IDX_METAVER_HASH      ON ..._METADATAVERSION (CONTENTHASH);
CREATE INDEX IDX_PROP_NAME         ON ..._APIPROPERTY (NAME);
CREATE INDEX IDX_PROP_LABEL        ON ..._APIPROPERTY (LABEL);
CREATE INDEX IDX_CHANGE_ASSET_TIME ON ..._CHANGEEVENT (APIASSET_ID, DETECTEDAT DESC);
```

✅ `REAL_VECTOR` supports 1–65,000 dimensions; a `HALF_VECTOR` variant exists if memory becomes a concern. Note the constraint: **`REAL_VECTOR` columns cannot be used in `GROUP BY`, `ORDER BY` or arithmetic expressions** — similarity must go through `COSINE_SIMILARITY`/`L2DISTANCE` functions. Design queries accordingly.

### 7.4 Why these decisions — the ones that will be challenged

| Decision | Likely challenge | Answer |
|---|---|---|
| `ApiAsset` ⟷ `ApiDeployment` split | "Why not one row per service per system?" | Because "is it in PRD yet", "does DEV differ", ownership and lifecycle are all asset-level, while URL and activation are system-level. Merging them duplicates governance data 4× and makes it inconsistent. |
| `MetadataVersion` deduplicated by hash | "Extra join for no reason" | 4× storage reduction on the largest tables, plus cross-system drift becomes a hash comparison rather than a deep diff. The join is cheap; the deep diff is not. |
| Three content layers (fact / AI / curated) | "Just use one description column with a flag" | A flag does not stop the next harvest overwriting curated text. One silent overwrite of a curator's work and they never curate again. The separation is what makes curation safe. |
| Generic `ApiAnnotation` bag | "Untyped data in a relational model is a smell" | Annotation vocabularies are open and grow every release. The bag absorbs the unknown; typed projections on `ApiEntity`/`ApiProperty` serve the known. Both, not either. |
| `apiType` as attribute, not subtype tables | "OData and SOAP are different things" | At catalog level they are the same shape: a service with entities, operations and parameters. One model means Phase 3 adds parsers, not schema. |
| `SearchDocument` denormalised | "Duplicated data" | Search must not join eight tables at query time. It is a derived, disposable index rebuilt from the model — the model stays normalised. |
| Snapshots in Phase 1 schema, Phase 2 UI | "YAGNI" | History cannot be reconstructed retroactively. Every day without snapshots is a day of history permanently lost. |

### 7.5 Volumetrics and sizing

`[ASSUMPTION — confirm in Phase 0 by counting actual services]`

| Table | Est. rows | Driver |
|---|---|---|
| `ApiAsset` | 3,000–6,000 | Distinct services incl. SAP-activated |
| `ApiDeployment` | 12,000–24,000 | × 4 systems |
| `MetadataVersion` | 8,000–15,000 | Deduplicated; grows with change history |
| `ApiEntity` | 80,000–150,000 | ~15 entities per service average |
| `ApiProperty` | 1.5M–3M | ~20 properties per entity |
| `ApiAnnotation` | 3M–8M | The largest table by far — annotations outnumber properties |
| `ChangeEvent` | 50k–200k/year | Depends on release cadence |
| `SearchDocument` | 100,000–200,000 | Assets + entities + selected operations |

Initial HANA Cloud sizing: **32 GB memory / 120 GB storage** as a starting point, with the annotation table and raw EDMX documents as the two things to watch. Move raw `$metadata` to Object Store rather than `LargeString` once average document size exceeds ~500 KB — some SAP standard services have multi-megabyte metadata and they will dominate the database otherwise.

**Retention:** keep all `ChangeEvent` rows (they are small and they are the history). Keep `MetadataVersion` rows referenced by a locked `ReleaseSnapshot` forever; purge unreferenced versions older than 24 months. Purge raw documents after 12 months except for snapshot-referenced versions.

---

## 8. Technical design

### 8.1 Harvest pipeline

```
for each SapSystem where harvestEnabled:
  ├─ 1. open HarvestRun
  ├─ 2. discover
  │     ├─ V2: GET /sap/opu/odata/IWFND/CATALOGSERVICE;v=2/ServiceCollection?$format=json
  │     └─ V4: GET /sap/opu/odata4/iwfnd/config/default/iwfnd/catalog/0002/ServiceGroups
  │              ?$expand=DefaultSystem($expand=Services)
  ├─ 3. for each discovered service, with bounded concurrency (8):
  │     ├─ GET <serviceUrl>/$metadata     (Accept-Language: en)
  │     ├─ V2 only: GET <serviceUrl>/$metadata?sap-value-list=all   → value help annotations
  │     ├─ V4: follow edmx:Reference / IncludeAnnotations to external annotation documents
  │     ├─ normalise (§8.2) → sha256
  │     ├─ if hash == current deployment hash:  stamp lastSeenAt; CONTINUE
  │     ├─ parse EDMX → staging rows
  │     ├─ diff vs previous MetadataVersion → ChangeEvent rows (§8.3)
  │     ├─ upsert MetadataVersion + schema rows; repoint ApiDeployment
  │     └─ queue for enrichment
  ├─ 4. detect disappearances: deployments with lastSeenAt < runStart → SERVICE_REMOVED
  ├─ 5. rebuild SearchDocument rows for affected assets; generate embeddings
  ├─ 6. run duplicate detection on new/changed assets
  ├─ 7. evaluate Subscriptions → dispatch notifications
  └─ 8. close HarvestRun with counters; alert if status != SUCCESS
```

**Resilience rules, all mandatory:**

- One service's failure must never fail the run. Catch per service, write `HarvestError`, continue. A run with 40 failures out of 4,000 is `PARTIAL`, not `FAILED`.
- Per-request timeout 60 s; three retries with exponential backoff on 5xx and timeouts; **no retry** on 401/403/404.
- Streaming XML parse (SAX-style) — some `$metadata` documents are multi-megabyte and a DOM parse will exhaust memory at concurrency 8.
- Bounded concurrency per system, configurable, default 8. Never harvest PRD during business hours.
- Full run is idempotent — safe to re-run at any time. This matters more than it sounds during the first months.

### 8.2 Normalisation before hashing

Naive hashing of the raw EDMX produces false-positive changes on every harvest, because attribute order, whitespace, namespace prefixes and generation timestamps vary. Before hashing:

1. Parse to an internal structure
2. Sort collections deterministically (entities by name, properties by ordinal then name, annotations by vocabulary+term+qualifier)
3. Drop volatile content — generation timestamps, cache tokens, `sap:` metadata ETags, comments
4. Serialise canonically (sorted keys, no whitespace) and hash that

Version the normaliser (`parserVersion`). When the normaliser changes, hashes change globally — guard against that being interpreted as "everything changed" by comparing the *parsed model*, not the hash, when `parserVersion` differs between the stored and current version.

### 8.3 Diff and breaking-change classification

The diff walks the parsed model, not the XML. Classification rules — these are the design, so they belong in the document rather than in code comments:

**BREAKING** — an existing consumer can fail:
- Entity set or entity type removed
- Property removed, or key properties changed
- Property EDM type changed to an incompatible type
- `maxLength` / `precision` **decreased**
- Property changed nullable → non-nullable (for creatable properties)
- Operation removed, or a required parameter added
- Navigation property removed
- A capability withdrawn (was filterable/sortable/creatable, now not)
- `requiresFilter` newly set to true

**POTENTIALLY_BREAKING** — needs a human look:
- Navigation cardinality changed
- Default value changed
- `sap:semantics` or unit/currency reference changed
- Value help target changed
- Entity set renamed (breaking in practice, but sometimes accompanied by an alias)

**NON_BREAKING**:
- New entity set, new optional property, new operation, new navigation
- `maxLength` increased
- Label or `quickInfo` changed
- Annotation added that does not withdraw a capability

Every `ChangeEvent` also gets a plain-language `aiChangeSummary` so the change feed reads like release notes rather than a schema dump — that is the difference between a feature people subscribe to and one they mute.

### 8.4 AI enrichment design

**Trigger:** a new or changed `MetadataVersion`, or a prompt-version bump. Skip when `inputHash` is unchanged — this is the single biggest cost control and it means a steady-state daily harvest costs almost nothing.

**Input construction** (what actually goes to the model):

```
Service: ZSD_DELIV_TRACK_SRV   (custom, RAP, package ZSD_LOGISTICS)
Title:   "Delivery tracking"
Entities:
  DeliveryHeader  [label: "Outbound Delivery"]  keys: DeliveryDocument
    DeliveryDocument      Edm.String(10)   label "Delivery"
    ActualGoodsMovementDate Edm.Date       label "Actual Goods Movement Date"
    ShippingPoint         Edm.String(4)    label "Shipping Point"
    ...
  DeliveryItem    [label: "Outbound Delivery Item"]
    ...
Operations: ConfirmPickingStatus (bound action on DeliveryHeader)
Backing CDS (if known): ZI_DeliveryTracking
```

**Labels are the payload.** Technical names in a badly-documented Z-service carry almost no signal; `sap:label` values carry most of it, because they were maintained for the UI. Harvesting labels properly — including the `Accept-Language` handling — is what makes enrichment work at all. If labels are missing too, the model should decline rather than invent.

**Output contract** — strict JSON schema, validated before persistence:

```json
{
  "summaryShort":      "string, max 200 chars, or null",
  "businessPurpose":   "string or null",
  "lobClassification": "SD|MM|FI|PP|QM|PM|CROSS|UNKNOWN",
  "lobConfidence":     0.0,
  "tags":              ["string"],
  "synonyms":          ["string"],
  "sampleQuery":       "string or null",
  "consumptionWarnings": ["string"],
  "insufficientMetadata": false,
  "reason":            "string, required when insufficientMetadata is true"
}
```

**Prompt rules (fixed, versioned in source control):**
- Describe only what the metadata shows. Do not infer process behaviour.
- If names and labels are too cryptic, set `insufficientMetadata: true` and explain — do not guess.
- `lobConfidence` below 0.6 means the classification is shown as "uncertain" in the UI and is queued for human confirmation.
- Never claim an API is released, supported, or recommended — that is governance data, not inference.

**Model selection:** small/fast model for classification and tagging; larger model for `businessPurpose` on custom services only (SAP standard services already have `api.sap.com` documentation to link to instead). Route through `@sap-ai-sdk/orchestration` so content filtering, masking and model fallback are configuration rather than code. Pin the model ID in `ApiEnrichment.modelId` for reproducibility.

**Quality gate — non-negotiable.** Build a **golden set of 50 hand-labelled services** in Phase 0, spanning well-documented and badly-documented, custom and standard, all major LoBs. Measure: LoB classification accuracy, human acceptance rate of summaries, and hallucination rate (summaries asserting something not in the metadata). Ship only above **80% acceptance** and **<5% hallucination**. Re-run the golden set on every prompt or model change, and record the result — this is what stops silent quality regression when someone "improves" the prompt.

### 8.5 Search implementation

```
query
 ├─ classify: exact-technical-name? keyword? natural language?
 ├─ lexical leg   → SCORE() over FULLTEXT index, top 100
 ├─ vector leg    → embed query (type QUERY) → COSINE_SIMILARITY over SearchDocument.embedding, top 100
 ├─ RRF fusion    → score = Σ 1 / (k + rank_i),  k = 60
 ├─ apply structured facet filters (system, type, domain, lifecycle, ...)
 ├─ apply boosts (§4.2) — curated ×1.4, usage ×1.2, SAP released ×1.3, deprecated ×0.3
 ├─ [optional] LLM re-rank top 20 for NL queries
 └─ group by ApiAsset, return with matched-field evidence
```

✅ HANA Cloud supports BM25 keyword search and vector search with RRF fusion natively — no PAL dependency.

**Embedding generation.** Two options, and the choice is worth a deliberate decision:

- **In-database** `VECTOR_EMBEDDING(text, 'DOCUMENT'|'QUERY', model)` ✅ — GA, no network hop, no per-token cost, but currently limited to the single bundled model `SAP_NEB.20240715` at 768 dimensions, and the HANA NLP service must be explicitly enabled.
- **External** via Generative AI Hub embedding models, stored back as `REAL_VECTOR` — free model choice, better multilingual and domain performance, but network cost and per-token spend.

**Recommendation: start in-database.** It is simpler, cheaper and fast enough, and the golden set will tell you whether the bundled model is good enough for SAP technical vocabulary. If recall is poor on the golden set, switch to an external model — the `embeddingModel` column exists precisely so both can coexist during migration. Note that query and document embeddings must come from the same model; a mixed index silently returns nonsense.

### 8.6 Service layer

CAP, exposing three faces over one model:

- **`/odata/v4/catalog`** — the UI service. Read-only projections plus curation write entities, with draft handling on `CuratedContent`.
- **`/api/v1/*`** — a clean REST facade for programmatic consumers, deliberately stable and versioned, so that CI pipelines can ask "does an API already exist that exposes field X" as a pre-build check. **Register this API in the catalog itself.**
- **`/mcp`** — see §8.9.

Custom handlers where CAP's generic ones will not do: hybrid search (native SQL against HANA), diff computation, on-demand harvest trigger, OpenAPI export.

### 8.7 UI design

**Two apps, deliberately, with different technology choices — and the justification matters because our standard is Fiori Elements first.**

**App 1 — Developer search (freestyle SAPUI5).** Working through the layered extension ladder honestly: a List Report with facets gets maybe 60% of the way. What it cannot express through annotations is the *hero* experience: a single relevance-ranked result list with matched-field snippet highlighting, a natural-language query box, side-by-side schema diff, a try-it console, syntax-highlighted code snippets, and an interactive lineage graph. That is a search-engine interaction pattern, not a master-detail one. **Freestyle is justified here** — and the justification is the interaction model, not developer preference.

Mitigation for what freestyle gives up: use UI5 controls and the SAP Horizon theme throughout, reuse Fiori Elements building blocks (`sap.fe.macros`) for the property tables and value helps so the standard behaviours come along, and verify accessibility explicitly rather than assuming it.

**App 2 — Curation and governance back-office (Fiori Elements, List Report + Object Page).** This one *is* classic master-detail: list of services I own, filter by review status, object page with editable curated fields and draft handling. Annotation-driven, cheap to build, free draft and message handling. **No reason to build this freestyle.**

Both surfaced through SAP Build Work Zone. Splitting this way means ~70% of the *screens* are templated even though the flagship screen is not.

**Screen-to-floorplan mapping:**

| Screen | Technology |
|---|---|
| S1 Search, S5 Compare | Freestyle UI5 |
| S2/S3/S4 Detail pages | Freestyle shell embedding `sap.fe.macros` tables |
| S6 Curation workbench | Fiori Elements — List Report + Object Page |
| S7 Governance dashboard | Fiori Elements — Overview Page (cards from ≥2 sources) or Analytical List Page |
| S8 Release view | Freestyle (diff visualisation) |

### 8.8 Scheduling

| Job | Cadence | Notes |
|---|---|---|
| Delta harvest, DEV | Daily 02:00 | Highest change rate |
| Delta harvest, QAS/PRD | Daily 03:00 | Off-peak, throttled |
| Full re-harvest, all systems | Weekly, Sunday | Catches normaliser or parser changes |
| Usage statistics pull | Daily | V2 only, via the on-stack probe, Phase 2 |
| Enrichment worker | Continuous, queue-driven | Rate-limited to control spend |
| Embedding rebuild | After each harvest | Only for changed documents |
| Duplicate detection | Weekly | Expensive; not needed daily |
| Snapshot creation | Manual + on release-tag event | |
| Notification dispatch | Immediate / daily / weekly per subscription | |

### 8.9 MCP server — highest leverage per unit of effort

Expose the catalog as a **Model Context Protocol server** so AI coding assistants can query it while the developer is writing code. Tools: `search_apis(query, filters)`, `get_api_detail(name)`, `find_apis_exposing(cdsViewOrTable)`, `check_duplicate(proposedEntityList)`.

Why this is disproportionate value: the reuse decision happens at the moment a developer starts building, in the IDE — not when they remember to open a portal. An assistant that can answer *"before you build this, note that `ZSD_DELIV_TRACK_SRV` already exposes these fields"* changes behaviour at the point of decision. A web app only helps people who remember it exists.

Small effort — the search and detail logic already exist in the service layer; MCP is a thin protocol wrapper. Put it in **Phase 2**, not Phase 3.

### 8.10 Phase 3 — the custom-code retirement engine

Ingest SAP's own standard API catalog from `api.sap.com` (it exposes an OData catalog service) and match it against harvested custom services using entity/property embedding similarity. Output: *"`ZSD_ORDER_EXT_SRV` overlaps 84% with the released `API_SALES_ORDER_SRV`. Three consumers. Candidate for retirement."*

This turns the hub from a developer convenience into the evidence base for the clean-core roadmap. It is also the feature most likely to secure ongoing funding, because it produces a costed retirement backlog rather than a productivity anecdote. Keep it in Phase 3 — but mention it in the Phase 1 business case.

---

## 9. Security and authorization

**Source system access.** One technical read-only user per system, used only by the collector. Required authorizations: `S_SERVICE` for the catalog services and each harvested service endpoint, plus display access to the Gateway catalog. `[CONFIRM]` exact authorization objects and values with Basis — do **not** grant `SAP_ALL` to "get the pilot moving", because it will never be revoked. No inbound connectivity to S/4HANA; all traffic is outbound through Cloud Connector.

**Application authorization** — XSUAA scopes mapped to IAS groups:

| Role | Scope | Can |
|---|---|---|
| Viewer | `catalog.read` | Search, view all detail, export, rate |
| Curator | `catalog.curate` | Edit curated content, approve AI output, set lifecycle — **for assets their team owns** |
| Governance | `catalog.govern` | Assign ownership, resolve duplicates, set lifecycle anywhere, view dashboards |
| Admin | `catalog.admin` | System config, trigger harvest, manage snapshots, prompt configuration |
| Service | `catalog.api` | Programmatic REST/MCP access (technical users, CI pipelines, AI assistants) |

Instance-level restriction on Curator (own team only) is implemented in the CAP service layer against `ApiAsset.ownerTeam`, not in the UI.

**Data classification — the point that will be raised in security review.** The hub stores *metadata*, never business data. `$metadata` is schema: entity names, field names, types, labels. No customer records, no amounts, no personal data. Two consequences to state explicitly:

1. **Never harvest sample payloads from PRD.** A "try it" console must call DEV or a sandbox, with the *user's own* principal-propagated credentials — never the collector's technical user, and never PRD by default. This is the one place where a convenience feature could turn a metadata catalog into a data-exfiltration path. Design it conservatively or defer it.

2. **Metadata is still internal-confidential.** Custom field names disclose business design (`ZZ_COMPETITOR_PRICE_INDEX` tells a story). The hub is internal-only, behind SSO, never internet-exposed, and not published to any external portal.

**LLM data handling.** Service and field metadata is sent to SAP Generative AI Hub. Get explicit sign-off from Security/DPO before Phase 1, with three mitigations on the table: process in the same region as the BTP subaccount, route through the orchestration service so content filtering and masking are enforced centrally, and maintain an exclusion list of packages or namespaces that must never be sent to a model. `[CONFIRM]` whether any package falls into that last category.

**Audit.** All curation changes, lifecycle transitions and ownership reassignments are audit-logged with user and timestamp via `managed` aspects plus SAP Audit Log service.

---

## 10. Testing and quality gates

| Layer | Approach |
|---|---|
| Parser | Unit tests against a fixture library of real `$metadata` documents — V2 and V4, tiny and multi-megabyte, malformed, with external annotation references. **Build this fixture library in Phase 0**; it is the single highest-value test asset and it pays for itself the first time SAP changes something. |
| Normaliser/hash | Property-based test: reordered but semantically identical documents must produce the same hash. Cosmetically changed documents must not. |
| Diff classifier | Table-driven tests, one case per rule in §8.3, asserting the compatibility verdict. |
| AI enrichment | Golden set of 50 services (§8.4). Acceptance ≥80%, hallucination <5%. Re-run on every prompt/model change; record results in the repo. |
| Search relevance | Golden query set — 30 realistic queries with known correct answers. Measure recall@5 and MRR. Re-run before every release; a relevance regression is a production incident. |
| Collector integration | Against a sandbox system; mocked HTTP for unit level. Explicitly test the failure paths: 401, 404, timeout, malformed XML, partial run. |
| Service layer | CAP integration tests, including authorization boundaries (Curator cannot edit another team's asset). |
| UI | OPA5 for the freestyle app; accessibility check with an automated axe-style scan plus one manual keyboard-only pass. |
| Performance | Load test search at target volume with synthetic data at 2× expected row counts before go-live. |

**Transport and CI/CD.** BTP components: Git → CI pipeline → MTA build → deploy DEV → QAS → PRD, gated on unit tests, golden sets and relevance tests. The optional on-stack probe follows the normal TMS track (DEV → QAS → PRD), with ATC clean including the documented allowlist entries for the non-released reads.

---

## 11. Roadmap and indicative sizing

| Phase | Scope | Duration | Team |
|---|---|---|---|
| **0 — Prove it** | Count actual services per system; validate both catalog endpoints and auth; parse 50 real `$metadata` documents; run 20 through an LLM and hand-score them; build the golden sets; capture the §2.4 baselines; decide on Backstage vs custom (option F) | 2–3 weeks | 1 architect + 1 dev |
| **1 — MVP** | V2+V4 harvest across all systems; full data model; AI enrichment; hybrid search; S1/S2/S3 screens; scheduled harvest | 8–10 weeks | 1 architect, 2 CAP devs, 1 UI5 dev, 0.5 BTP/Basis |
| **2 — Make it stick** | Change detection; release snapshots + S8; curation workbench S6; governance dashboard S7; subscriptions; OpenAPI export; duplicate detection; V2 usage stats + on-stack probe; **MCP server** | 6–8 weeks | same |
| **3 — Make it strategic** | SOAP/RFC/events/CPI/APIM sources; lineage; api.sap.com comparison and retirement backlog; Developer Hub promotion; LeanIX feed | 8–12 weeks | same + 0.5 ABAP |

Roughly **4–5 months to a genuinely useful Phase 2**, then Phase 3 as a funded follow-on justified by Phase 2's findings.

**Do not skip Phase 0.** Every significant risk in §12 is either eliminated or quantified by three weeks of work, and the parse-50-documents exercise alone will surface surprises in the real metadata that would otherwise land in week 6 of the build.

**Run-cost drivers:** HANA Cloud (dominant, and it is always-on), CF runtime, and AI Core consumption. Enrichment cost is a one-off spike on the initial backfill and near-zero in steady state thanks to hash-based skipping — model the backfill separately or the first invoice will look alarming.

---

## 12. Risks

| # | Risk | Impact | Mitigation |
|---|---|---|---|
| R1 | AI descriptions are wrong and developers act on them | Trust destroyed; tool abandoned | Golden-set gate before ship; `insufficientMetadata` path instead of guessing; every AI field visibly labelled; curated content always outranks AI; 👍/👎 to surface bad output fast |
| R2 | ~~V4 usage statistics do not exist~~ → **Downgraded 2026-09-24.** V4 usage is available, but from the HTTP statistics layer rather than Gateway metering, at coarser granularity ✅ | F13 covers V2 and V4, with different precision per source | Two documented sources: `STATS` Task Type `T`/`H` → Gateway tab (KBA 3732359) and ST03 Web Server Statistics on `*opu/odata*` (KBA 2629143). Record the source in `UsageStat.dataSource` and show granularity honestly in the UI. `[VERIFY]` URL-path parsing gives reliable per-service attribution for V4 |
| R3 | Unpublished V4 service groups are invisible to the catalog ✅ | Incomplete catalog | On-stack probe for complete inventory; report the delta as a governance finding — it is a real problem worth exposing |
| R4 | `/IWFND/` table reads are non-released → Level C | Clean-core exception needed | Contained package, one class per source, ATC allowlist, dated ADR with owner and remediation trigger; Phase 1 avoids it entirely |
| R5 | Security/DPO refuses metadata-to-LLM | Core feature blocked | Raise in Phase 0, not Phase 1. Fallbacks: in-database embeddings only (no generative step), or on-stack ABAP AI SDK so metadata never leaves the SAP-managed boundary ✅ |
| R6 | Nobody curates; catalog quality plateaus at "AI output" | Half the value lost | Automated harvest means it is never *stale*, only *thin*; seed ownership from TADIR; curation work queue; curated content outranks AI; coverage on the governance dashboard by team |
| R7 | Nobody uses it — the classic internal-tool failure | Total | MCP server in the IDE (§8.9) so it reaches developers where they work; Work Zone placement; make it the required pre-build check in the design review checklist |
| R8 | Metadata volume larger than modelled | Cost / performance | Phase 0 counts real volumes; raw documents to Object Store; retention policy from day one |
| R9 | Cloud Connector / technical user provisioning lead time | Schedule slip | Start the request in week 1 of Phase 0 — this is routinely the longest-lead item |
| R10 | SEGW-era services have no useful labels | Enrichment weak exactly where it is most needed | Accept and expose it: "insufficient metadata — needs an owner description" is itself a finding, and one that motivates the owning team to fix it |
| R11 | Scope creep into runtime governance / API gateway | Dilution and overlap with Integration Suite | Hold the line: this is an inventory and discovery tool. Runtime governance is API Management's job (§3). |

---

## 13. Open questions

| # | Question | Needed by |
|---|---|---|
| Q1 | How many OData services are actually registered per system, custom vs standard, V2 vs V4? Everything in §7.5 and §11 depends on this. | Phase 0 |
| Q2 | Does Security/DPO approve sending service and field metadata to Generative AI Hub? Any packages that must be excluded? | Phase 0 — blocking |
| Q3 | Is there a corporate developer-portal standard (Backstage or similar) we are expected to adopt rather than building on BTP? | Phase 0 — changes option F |
| Q4 | Is BTP Cloud Foundry or Kyma the standard runtime here? | Phase 0 |
| Q5 | Is AI Core already subscribed, and on which plan? Which models are enabled in our region? | Phase 0 |
| Q6 | Which systems are in scope beyond DEV/QAS/PRD — project systems, sandboxes, any second S/4 instance? | Phase 0 |
| Q7 | Who owns this tool after go-live? An unowned internal tool decays. | Phase 1 |
| Q8 | Is Integration Suite Developer Hub already in use, and by whom? Determines whether §3's promotion path is Phase 3 or earlier. | Phase 1 |
| Q9 | Exact authorization objects for the collector's technical user — Basis to confirm. | Phase 1 |

**`[VERIFY]` before build** (documentation was inconclusive on 2026-09-22):
- Whether S/4HANA 2025 released a CDS view or API for V4 service binding enumeration (none found — check the Released Objects app in ADT)
- Whether a recent SP or SAP Note has closed the OData V4 statistics gap
- Generative AI Hub orchestration service GA status and date (documented as production-ready; no explicit GA announcement retrieved)
- AI Core plan required for Generative AI Hub access

---

## 14. AI provider strategy — and why extraction is not an AI problem

### 14.1 The correction that de-risks the whole AI story

The original idea assumed "we have to use AI/LLM models" to read service metadata. **Metadata extraction must not use an LLM.** `$metadata` is EDMX — a deterministic XML schema with a published specification. An XML parser extracts entities, properties, types, capabilities and annotations with complete accuracy, in milliseconds, at zero marginal cost. An LLM doing the same work is slower, costs money per service, and is **non-deterministic** — the same service could be described differently on two consecutive runs. For a system whose entire value proposition is being the authoritative inventory, that is disqualifying.

This is good news, not a limitation. Once extraction is deterministic, **AI becomes an optional enrichment layer rather than a core dependency** — which is precisely the flexibility the review asked for.

Three distinct functions, with materially different provider requirements:

| Function | AI required | Data leaves tenant | Swappability |
|---|---|---|---|
| Metadata extraction | **No** — XML/EDMX parser | None | N/A |
| Embeddings (semantic search) | Yes, small model | **Optional** — can run in-database or in-container | High, trivial to swap |
| Generative enrichment (summaries, LoB classification, change summaries) | Yes, capable model | Yes | Must be pluggable |

### 14.2 Tiered AI dependency — the insurance policy

Build so the product degrades gracefully rather than failing if AI is vetoed (risk R5) or a provider is withdrawn:

| Tier | Requires | Delivers | Blocked by |
|---|---|---|---|
| **0 — No AI** | Nothing | Lexical BM25 search, structured facets, field-level reverse lookup, change detection, release variants | Nothing. Ships day one |
| **1 — Embeddings only** | A small embedding model, which can run **in-database or in-container with zero egress** | Semantic search — the hero feature | Nothing external |
| **2 — Generative** | A capable LLM | Business descriptions, classification, plain-language change summaries, duplicate explanations | Provider approval |

**State this explicitly in the proposal: the flagship capability — semantic search — survives a total veto on external AI**, because embeddings can be generated in-database (HANA `VECTOR_EMBEDDING()`) or by a local model in a container. That removes the single largest objection before it is raised.

### 14.3 Provider abstraction — one port, several adapters

```
EnrichmentProvider (port)                  EmbeddingProvider (port)
  ├─ SapGenAiHubAdapter    @sap-ai-sdk/*     ├─ HanaInDatabase   VECTOR_EMBEDDING(), no egress
  ├─ AnthropicAdapter      Claude API        ├─ LocalModel       BGE / E5 in container, no egress
  ├─ AzureOpenAiAdapter    likely pre-approved  └─ ExternalApi   OpenAI / Cohere / Voyage
  ├─ BedrockAdapter        multi-model, AWS
  ├─ VertexAiAdapter       Gemini
  └─ LocalModelAdapter     vLLM / Ollama, no egress
```

**Schema change:** add `provider : String(40)` to `ApiEnrichment` alongside the existing `modelId` and `promptVersion`. Every generated field then records which provider and model produced it, making output reproducible and allowing two providers to be A/B compared inside the same catalog.

**Two shortcuts instead of hand-writing adapters:**
- **LiteLLM proxy** — one OpenAI-compatible endpoint fronting 100+ providers. Your code has exactly one adapter; provider swap becomes proxy configuration. Best choice if provider churn is expected.
- **Vercel AI SDK** (`ai` package) — first-class typed provider modules with structured-output support, natural fit for a CAP Node.js codebase.

**Selection criteria that actually matter**, given the strict-JSON enrichment contract in §8.4:

1. **Constrained / structured output support** — non-negotiable, or the project drowns in JSON repair. Anthropic (tool use), Azure OpenAI (`json_schema`), Bedrock and Gemini all support it; local models need GBNF grammars via llama.cpp, or Outlines with vLLM.
2. **Data residency and retention terms** — EU region, zero-retention.
3. **Cost at backfill scale** — see §14.4.

**Model tier:** this task is schema comprehension and classification, not deep reasoning. A **small-to-mid model** is correct — Claude Haiku 4.5 or Sonnet 5, GPT-4o-mini class, or equivalent. A frontier model is wasted spend here; put the savings into running the golden set more often.

### 14.4 Cost, for the business case

Per service: roughly 2,000–6,000 input tokens (entity and property lists with labels) and ~500 output. At 5,000 services the one-off backfill is **~15–30M input tokens** — low hundreds of dollars on a mid-tier model at list prices, and less at negotiated enterprise rates. Steady state is **near zero** because of `inputHash`-based skipping (§8.4): an unchanged service is never re-enriched.

Model the backfill spike separately from run cost, or the first invoice will be misread as the ongoing rate.

### 14.5 What makes provider-swapping safe

The 50-service golden set from §8.4 is the enabling asset. It converts "which model should we use" from an argument into a measurement: run each candidate provider against the same 50 services, compare LoB accuracy, human acceptance rate and hallucination rate, and choose on evidence. Re-run it on every provider, model or prompt change.

Without the golden set, swapping providers is a gamble. With it, it is a routine, reversible decision.

`[CONFIRM]` — does Accenture or the client already operate an approved enterprise LLM platform? If Azure OpenAI is already governed and approved internally, it very likely beats both SAP Generative AI Hub and any direct provider on approval timeline, which is usually the binding constraint rather than capability.

---

## 15. Deployment variants — alternatives to CAP + HANA Cloud

### 15.1 Two things worth knowing up front

**CAP is more portable than it appears.** It is open source, runs in any Docker host — Azure, AWS, on-premise — and supports HANA (`@cap-js/hana`), **PostgreSQL** (`@cap-js/postgres`) and SQLite (`@cap-js/sqlite`) behind one model definition. Choosing CAP does not lock the solution to BTP, and it does not lock it to HANA.

**HANA Cloud is the most expensive and least necessary component in the recommended stack.** This is not an ERP transactional workload; it is a read-mostly search index of roughly 100,000 documents. HANA's justification is "already in the landscape, SAP-native operations, hybrid RRF and in-database embeddings built in" — all real, none technically required.

### 15.2 Runtime options

| Option | When it wins | Trade-off |
|---|---|---|
| **CAP Node.js on BTP Cloud Foundry** (recommended default) | SAP-native operations; destinations, Cloud Connector and XSUAA come free; best AI SDK support | BTP entitlement required |
| CAP Java | Team is Java-strong | Heavier; no advantage for this workload |
| **BTP ABAP Environment + RAP** | Team is ABAP-only; RAP + Fiori Elements is native ground | Weaker XML-parsing ergonomics and AI pipeline; freestyle search UI harder |
| **Kyma / any Kubernetes** | Containers wanted, local models needed, polyglot workers | Higher operations burden |
| **Non-SAP: NestJS or Python FastAPI on Azure App Service / AKS / AWS ECS** | No BTP entitlement, or corporate standard is a hyperscaler | Fastest for parsing and AI work, but SSO, destinations, Cloud Connector and Work Zone integration must be rebuilt |

### 15.3 Database and search options — the consequential choice

| Option | Lexical | Vector | Assessment |
|---|---|---|---|
| **HANA Cloud** | BM25 built in | `REAL_VECTOR` + native RRF fusion + in-DB embeddings | Best integration, highest cost, always-on. Overkill for a search index |
| **PostgreSQL + pgvector** | `tsvector` / `ts_rank` + `pg_trgm` | HNSW / IVFFlat | **The cost/benefit sweet spot.** Works through CAP unchanged; managed everywhere. RRF fusion is hand-written — roughly 20 lines of SQL. `[VERIFY]` PostgreSQL entitlement on the BTP subaccount |
| **OpenSearch / Elasticsearch** | Best-in-class BM25, faceting, snippet highlighting | Dense vector, hybrid built in | **Best pure technical fit** — one engine covers the entire §4.2 feature list including match highlighting. Pair with PostgreSQL as system of record. More moving parts |
| Typesense / Meilisearch | Excellent, superb DX | Yes | Fast to stand up; lighter enterprise tooling |
| Qdrant / Weaviate / Milvus | No | Excellent | Vector-only; needs a separate relational store. Adds a component for little gain over pgvector at this scale |

### 15.4 Recommended variants by scenario

| Scenario | Stack |
|---|---|
| **SAP-aligned default** | BTP CF + CAP Node.js + HANA Cloud + Generative AI Hub |
| **Cost-optimised** (recommended to lead with if budget or approval timeline is binding) | BTP CF + CAP Node.js + **PostgreSQL/pgvector** + pluggable LLM |
| **Search-optimised** | CAP or Node + PostgreSQL (system of record) + **OpenSearch** (index) |
| **Zero data egress** | Kyma + CAP + PostgreSQL/pgvector + **local embedding and LLM models in-cluster** |
| **No BTP entitlement** | Docker on Azure/AWS + NestJS or FastAPI + PostgreSQL/pgvector + Azure OpenAI |
| **Corporate developer-portal standard exists** | Backstage plugin + PostgreSQL (see option F, §5) |

The cost-optimised variant deserves emphasis: it keeps the SAP-native development model and the migration path to HANA open, at a materially lower run cost. **Winning the proposal on the cheap stack and upgrading later carries no architectural penalty**, because CAP abstracts the database.

### 15.5 The design decision that makes all of this cheap — ports and adapters

Structure the build hexagonally. The harvest → parse → normalise → diff → classify → rank pipeline is plain TypeScript with **four ports**:

```
                    ┌────────────────────────────────────────┐
   Source port ─────│  Core domain                           │───── Persistence /
   • S/4 catalog    │  harvest · parse · normalise · hash ·   │      search port
     OData          │  diff · classify · rank                │      • HANA
   • on-stack probe │  (no vendor types cross this boundary) │      • PostgreSQL
   • api.sap.com    └────────────────────────────────────────┘      • OpenSearch
   • SOAP / APIM            │                      │
                       LLM port            Embedding port
                    • GenAI Hub            • HANA in-DB
                    • Anthropic            • local model
                    • Azure OpenAI         • external API
                    • local model
```

**Rule: no vendor SDK type may cross a port boundary.** The core domain knows about `EnrichmentResult`, not about `@sap-ai-sdk` response objects. This is the difference between "that's a configuration change" and "that's a rewrite."

**Why this belongs in the proposal, prominently:** every architecture-board challenge of the form *"what if we don't want SAP AI / don't have HANA / must stay off BTP?"* is answered with "that is an adapter, already designed for" instead of a redesign. It is also the honest answer to the review comment — flexibility is a structural property, not a promise.

**What is genuinely portable vs. what is not:**

| Portable | Locked to the choice |
|---|---|
| Core pipeline, data model, diff rules, prompts, golden sets, OpenAPI export, MCP server | XSUAA/IAS SSO, destinations + Cloud Connector, Work Zone placement (BTP-specific) |
| CAP service definitions (HANA ↔ PostgreSQL ↔ SQLite) | Native SQL for hybrid search — needs one implementation per database engine |
| Fiori Elements back-office app | — |

The hybrid-search SQL is the one component requiring a per-database implementation. Budget it as ~2–3 days per additional engine, and isolate it behind the persistence port so the rest of the codebase never sees it.

---

## 16. Data source evidence register

> Purpose: demonstrate, source by source, exactly where every piece of information comes from — down to table level where relevant — with the clean-core consequence of each access path made explicit. This is the section that answers "have they actually thought this through, or is this a slide?"

### 16.1 How to read this register, and the argument it makes

The register has a deliberate shape, and the shape *is* the argument:

- **The released API column is the design.** It is what the tool actually uses, and it is Level A.
- **The persistence column is the evidence.** It proves we know the plumbing and have a fallback where the released path has a gap.
- **Naming a table is not the same as recommending it.** Direct table access is Level C — no stability contract, changelog check required at every upgrade.

A word on proposal strategy, because the instinct here can backfire. Leading with table access as the *primary* mechanism will be challenged immediately by any SAP architecture board, and correctly so — it is the anti-pattern the clean-core programme exists to eliminate. The stronger position is:

> *"We reach 90% of the required inventory through released catalog services at Level A. For the documented gaps — unpublished V4 service groups and V4 usage statistics — here is the exact persistence layer, the exact fallback, and the contained exception that governs it."*

**Demonstrating that you know the tables proves depth. Demonstrating that you do not need them proves architecture quality.** Present both; recommend the first.

### 16.2 The register

| # | Information needed | Released access path | Clean core | Underlying persistence | Status |
|---|---|---|---|---|---|
| 1 | List of activated OData **V2** services: name, namespace, description, endpoint | `GET /sap/opu/odata/IWFND/CATALOGSERVICE;v=2/ServiceCollection` | 🟢 A | `/IWFND/` namespace registry tables — **confirmed to be undocumented by SAP** (see §16.4) | Released path ✅ **confirmed**. Table names deliberately **not stated**: they carry no stability contract, so the released catalog service is the only defensible access path |
| 2 | Entity sets per V2 service | `GET …/ServiceCollection('<id>')/EntitySets` | 🟢 A | as above | ✅ confirmed |
| 3 | OData **V4** service groups and their services | `GET /sap/opu/odata4/iwfnd/config/default/iwfnd/catalog/0002/ServiceGroups?$expand=DefaultSystem($expand=Services)` | 🟢 A | `/IWFND/` V4 config tables — **undocumented** | Released path ✅ **confirmed** (publication procedure: SAP KBA 2948977). Only returns **published** groups — see row 7 for the unpublished case |
| 4 | Complete schema — entities, properties, types, operations, annotations | `GET <serviceUrl>/$metadata` | 🟢 A | Gateway metadata cache | ✅ confirmed. **This is the authoritative source and needs no table access at all** |
| 5 | V2 value-help annotations | `GET <serviceUrl>/$metadata?sap-value-list=all` | 🟢 A | — | ✅ confirmed |
| 6 | V4 external annotation documents | Follow `edmx:Reference` / `IncludeAnnotations` from `$metadata` | 🟢 A | — | ✅ confirmed |
| 7 | **V4 service bindings not yet published** (gap R3) | **Documented manual path exists:** navigate Service Definition (SRVD) → Service Group via `TADIR` and package structure, per **SAP KBA 3653272** | 🟡 B — `TADIR` is classic but documented, not an undocumented internal table | `TADIR` + package hierarchy; alternatively `/IWFND/` V4 registry (undocumented) | **Improved.** KBA 3653272 ✅ gives a sourced route that avoids undocumented tables. Also test XCO: `XCO_CP_ABAP_REPOSITORY=>OBJECT->FOR->SRVB->IN->SYSTEM_LIBRARY->GET->ALL` — pattern is consistent with XCO design but **`[VERIFY]` the exact method chain for 2025**; XCO APIs change across releases |
| 8 | **V2 usage statistics** | No released API. Transaction `/IWFND/STATS` is the supported tool | 🟡 B/C | **`/IWFND/L_METAGR`** — client-specific monthly aggregated OData metering; service name in field **`TECH_SRV_NAME`** ✅ **sourced, SAP KBA 2629143**. Also `/IWFND/L_MET_COL` (raw), `/IWFND/SU_STATS` (summary), `/IWFND/L_MET_DAT`, `/IWFND/D_MET_AGR`; reports `/IWFND/R_METERING_VIEW`, `/IWFND/R_METERING_AGGREGATE` | ✅ **confirmed** (KBA 2629143, KBA 2385250). `/IWFND/L_METAGR` is the **one registry-adjacent table with a documented KBA citation and a named field** — use it as the proposal's table-level evidence |
| 9 | **V4 usage statistics** | **Available, from a different source than V2.** Transaction **`STATS`**, Task Type `T` (HTTPS) or `H` (HTTP) → *Gateway* tab, per **KBA 3732359**. Also **ST03 Web Server Statistics** filtered on `*opu/odata*`, per **KBA 2629143** | 🟡 B | HTTP/web statistics layer, not the Gateway metering layer | ✅ **confirmed — corrected from the earlier "does not exist" position.** `/IWFND/STATS` shows V2 only, but V4 calls are ordinary HTTP calls and are visible at HTTP level. **Coarser granularity:** per-service attribution requires parsing the service name from the URL path. Supplementary: API Management analytics (proxied only), Cloud Integration monitoring (iFlow consumers only) |
| 10 | Repository provenance — package, author, created/changed dates | `TADIR` is classic but well-known; released alternative to be confirmed | 🟡 B | `TADIR` | `[VERIFY]` released alternative in S/4HANA 2025 |
| 11 | Backend lineage — service → CDS view → table | XCO repository APIs in ABAP for Cloud Development | 🟢 A if XCO suffices | Repository objects | `[VERIFY]` exact XCO class/method chain against the [XCO Library documentation](https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/xco-library) and test in the 2025 system — XCO APIs evolve across releases. Phase 3, best-effort |
| 12 | API release state of a backing object | *Released Objects* app in ADT; object Properties → API State; SAP Business Accelerator Hub. XCO exposes release-state properties for repository objects | 🟢 A | Release-contract persistence | `[VERIFY]` whether a released CDS view exposes release state programmatically, and which object types are covered. If unresolved, raise an SAP incident under component **`BC-DWB-TOO-XCO`** or **`BC-ESI-WS-ABA`** |
| 13 | SOAP service registry | SOAMANAGER is the supported tool; no released enumeration API identified | 🟡 B/C | `SRT_*` family `[VERIFY]` | Phase 3. Not yet researched |
| 14 | SAP standard API catalog, for the retirement engine (§8.10) | `api.sap.com` OData catalog service | 🟢 A | External to our landscape | ✅ catalog service exists and is queryable |

**What this register shows at a glance:** rows 1–6 — the entire Phase 1 scope — are **fully Level A with confirmed released endpoints and require no table access whatsoever.** Table access appears only in rows 7 and 8, both Phase 2, both containable inside `ZAPI_CATALOG_PROBE` (§6.3). That is a strong clean-core story, and it is stronger precisely *because* the fallback is documented rather than hidden.

### 16.3 How to derive the registry table names authoritatively — 30 minutes

Do not cite a blog for a table name in a proposal. Derive it from the system and cite your own trace; it is faster than searching and it is unarguable in review.

**Method A — SQL trace. The definitive answer, ~10 minutes.**
1. `ST05` → activate SQL trace, filtered to your own user
2. In a second session run `/IWFND/MAINT_SERVICE`; perform a service search and open one service
3. Return to `ST05` → deactivate trace → *Display Trace*
4. The exact tables, SELECT statements and fields are listed. Screenshot it — **this becomes your proposal evidence**
5. Repeat for `/IWFND/V4_ADMIN`

This is authoritative because it observes what the transaction actually does in *your* release, rather than what a blog said about some release.

**Method B — from the transaction to the code.**
`SE93` → `/IWFND/MAINT_SERVICE` → note the program or Web Dynpro component → open in `SE80`/ADT → inspect the data-access classes.

**Method C — DDIC search by pattern.**
`SE11` or ADT object search: name pattern `/IWFND/*`, object type Table. Read the short descriptions; the registry tables are identifiable from them. Repeat for `/IWBEP/*` for the backend/SEGW side.

**Method D — package browsing.**
`SE80` → browse the `/IWFND/` framework packages and their DDIC subpackages. Useful for understanding how the registry is structured, not just its table names.

**Method E — Joule for Consultants.** Executed 2026-09-24; results in §16.4. Strong on released APIs, KBA-documented behaviour and the standard-capability cross-check. As expected, it **declined to name the undocumented registry tables** — which turned out to be the most useful answer it gave (§16.4). Always require it to state whether each answer is officially documented and to cite the Note or KBA.

**Method F — SAP Notes and KBA search** for `/IWFND` plus "table", which is how the metering tables in row 8 were confirmed.

Use **A** for the answer and **E/F** for the citation. Record the result in §16.2, replacing every `[VERIFY]` with the confirmed name and the method that confirmed it.

### 16.4 Joule for Consultants findings (2026-09-24) — and why the "no answer" is the best answer

Joule for Consultants was queried on all seven source questions. Outcome:

**Confirmed as *not* officially documented by SAP** — the DDIC tables behind `/IWFND/MAINT_SERVICE` (V2 registry), `/IWFND/V4_ADMIN` (V4 service groups), and the `/IWBEP/` backend SEGW registry. SAP documents the *transactions* and their functional areas — Service Catalog, ICF Nodes, System Aliases — but not the persistence beneath them, in any Note, KBA or help.sap.com page.

**This apparent gap is actually the strongest clean-core argument in the proposal, and it should be presented that way:**

> If SAP does not document these tables, they carry **no stability contract**. Any solution reading them is Level C by definition — non-released objects requiring a changelog and impact check at every upgrade. Our design reads none of them for the entire Phase 1 scope, because the released catalog services provide the same information with a contract behind it.

Do not present the undocumented tables as a finding we are missing. Present them as a path we evaluated, sourced, and **deliberately rejected on clean-core grounds** — with the released alternative already proven for rows 1–6. An architecture board will recognise the difference immediately, and it converts a perceived weakness in the evidence base into a demonstration of design discipline.

**New sourced facts obtained** (all folded into §16.2):

| Finding | Source | Effect on the design |
|---|---|---|
| Transaction `STATS`, Task Type `T`/`H` → *Gateway* tab is the documented workaround for V4 monitoring | KBA 3732359 | **Reverses the earlier "V4 usage is impossible" position.** F13 now covers V4 at coarser granularity |
| ST03 Web Server Statistics filtered on `*opu/odata*` | KBA 2629143 | Second V4-capable usage source |
| `/IWFND/L_METAGR` holds monthly aggregated OData metering; service name in field `TECH_SRV_NAME` | KBA 2629143 | **The one table-level fact with a citable source and a named field** — use it as the register's table-level evidence |
| Documented navigation from Service Definition (SRVD) → Service Group via `TADIR` + package structure | KBA 3653272 | Partial answer to the unpublished-V4-bindings gap (row 7) that avoids undocumented tables entirely |
| V4 service group publication procedure | KBA 2948977 | Confirms the publication prerequisite behind gap R3 |
| XCO pattern `XCO_CP_ABAP_REPOSITORY=>OBJECT->FOR->SRVB->IN->SYSTEM_LIBRARY->GET->ALL` | Consistent with XCO design; **not confirmed for 2025** | Concrete hypothesis to test in Phase 0 — would make row 7 fully Level A |
| Support components for unresolved questions: `BC-ESI-WS-ABA`, `BC-DWB-TOO-XCO` | — | Route for closing the remaining `[VERIFY]` items via SAP |

**Still open after Joule** — carry into Phase 0: the exact XCO method chain for SRVB/SRVD enumeration in 2025; whether a released CDS view exposes API release state programmatically; whether any recent SP has added native V4 Gateway statistics; and the SOAP registry tables (row 13, not yet researched).

### 16.5 Phase 0 deliverable

Completing §16.2 is a named Phase 0 output, and it is the cheapest credibility the proposal can buy. Budget half a day. It closes Q1 and R8, converts rows 7, 10, 11, 12 and 13 from `[VERIFY]` to fact, and produces the screenshots that make the technical section unarguable.

---

## Appendix A — Verified sources (2026-09-22)

| Claim | Source |
|---|---|
| Developer Hub is the current name for API Business Hub Enterprise; manual proxy + product publication, no auto-discovery | SAP Help Portal — Developer Hub (SAP API Management); Centralized Developer Hub (SAP Integration Suite) |
| api.sap.com carries SAP standard APIs only; no private customer content | SAP Help Portal — What is SAP Business Accelerator Hub |
| V2 catalog endpoint `/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/ServiceCollection` | SAP Gateway documentation |
| V4 catalog endpoint `/sap/opu/odata4/iwfnd/config/default/iwfnd/catalog/0002/ServiceGroups`; service groups must be published via `/IWFND/V4_ADMIN` | SAP Community — OData V4 Service Catalog; SAP KBA 2947017 |
| OData V4 activity is not shown in `/IWFND/STATS`; no dedicated V4 monitoring transaction exists. **Documented workaround:** transaction `STATS` with Task Type `T` (HTTPS) or `H` (HTTP) → *Gateway* tab | SAP KBA 3732359 |
| V2 statistics tables `/IWFND/L_MET_COL`, `/IWFND/SU_STATS`; aggregation report `/IWFND/R_METERING_AGGREGATE` | SAP KBA 2385250 and Gateway documentation |
| HANA Cloud `REAL_VECTOR` / `HALF_VECTOR`, 1–65,000 dimensions; not usable in GROUP BY / ORDER BY / arithmetic | SAP Help Portal — REAL_VECTOR and HALF_VECTOR Data Types |
| BM25 + vector hybrid search with RRF fusion, native, no PAL | SAP Community — BM25 and Hybrid Search for RAG on SAP HANA Cloud |
| `VECTOR_EMBEDDING()` GA Q4 2024; bundled model `SAP_NEB.20240715`, 768 dimensions; NLP service must be enabled | SAP Help Portal — VECTOR_EMBEDDING Function |
| SAP Cloud SDK for AI (`@sap-ai-sdk/*`) is the recommended path for new productive CAP use cases; `cap-llm-plugin` is limited-scope, existing implementations only, not an SAP product | SAP Architecture Center — GenAI Applications golden path; SAP AI SDK FAQ; github.com/SAP/ai-sdk-js |
| ABAP AI SDK powered by ISLM — official SAP delivery, included in S/4HANA 2025 standard delivery (Oct 2025), TCI-based for earlier releases | SAP Help Portal — AI in ABAP Cloud; SAP Developer Center |
| SAP LeanIX Interface Modeling documents application-to-application interfaces; Integration Suite adapter imports integration artifacts; not a backend catalog harvester | SAP Help Portal — LeanIX Interface Modeling Guidelines |
| SAP Cloud ALM and SAP Signavio have no custom API catalog capability | SAP Community — LeanIX / Signavio / Cloud ALM data ownership |

### Added 2026-09-24 — via Joule for Consultants (see §16.4)

| Claim | Source |
|---|---|
| `/IWFND/L_METAGR` holds client-specific monthly aggregated OData request metering; service name in field `TECH_SRV_NAME`. ST03 Web Server Statistics can be filtered on `*opu/odata*` | SAP KBA 2629143 |
| Documented navigation from Service Definition (SRVD) to its Service Group via `TADIR` and package structure | SAP KBA 3653272 |
| Procedure for publishing OData V4 service groups via `/IWFND/V4_ADMIN` | SAP KBA 2948977 |
| Registered OData V4 services in SAP Gateway | SAP KBA 2947017 |
| The DDIC tables behind `/IWFND/MAINT_SERVICE`, `/IWFND/V4_ADMIN` and the `/IWBEP/` SEGW registry are **not published** in any SAP Note, KBA or help.sap.com page — SAP documents the transactions' functional areas only | Joule for Consultants, 2026-09-24; no contradicting source found. **Therefore these tables carry no stability contract — see the clean-core argument in §16.4** |
| XCO library reference for verifying repository-object enumeration APIs | help.sap.com — XCO Library, ABAP Development Tools User Guide |
| SAP support components for unresolved Gateway / XCO questions: `BC-ESI-WS-ABA`, `BC-DWB-TOO-XCO` | Joule for Consultants, 2026-09-24 |
