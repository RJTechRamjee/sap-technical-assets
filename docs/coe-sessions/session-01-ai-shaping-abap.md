# COE Biweekly Knowledge-Sharing Session

| Field | Value |
|---|---|
| Session # | 01 |
| Topic | How AI is reshaping ABAP — Joule for Developers, the ABAP MCP Server, and building AI into our own code |
| Presenter | Ramjee |
| **`ppt_date_time`** | `2026-09-11 14:00 IST` `[CONFIRM — day/time slot not yet fixed]` |
| Duration | 60 min |
| Meeting link | `[CONFIRM]` |
| Deck file | `COE-S01_2026-09-11_ai-shaping-abap.pptx` |
| Recording link | (fill after delivery) |
| Audience | ABAP developer community (offshore) |
| Status | Planned |
| Research verified | 2026-09-04 — see §8. Re-verify before delivery; this topic moves monthly. |
| Related repo assets | `reference/adt-mcp-usage.md` · `reference/sap-project-standards.md` §4, §7 · `skills/clean-abap-code-reviewer/SKILL.md` |

## 1. Why This Topic, Now

Three things landed in 2026 that change how this team writes ABAP, and all three
are live *now* rather than on a roadmap:

- **Joule for Developers, ABAP AI capabilities** reached general availability for
  **S/4HANA Cloud Private Edition, all releases from 2021 onwards** — delivered as
  a BTP hub service, so it does not depend on our backend release. We are on
  PCE 2025; this applies to us today.
- **The ABAP MCP Server went GA at Sapphire 2026**, exposing ABAP development
  operations as MCP tools that *any* compatible agent can drive — GitHub Copilot,
  Claude Code, Amazon Q. We already use Copilot and Claude; this is the supported
  way to point them at a real ABAP system.
- **The ABAP AI SDK (powered by ISLM) is in standard delivery from release 2025**
  for Private Edition and on-premise — meaning we can call an LLM *from inside*
  our own ABAP code, not just use AI to write it.

There is also a commercial clock: the **free promotional period for Joule for
Developers ran to September 2026**, and pricing moved to consumption-based
**AI Units** activated through SAP for Me. Someone on this project needs to own
that conversation, and the team should know what it is consuming.

## 2. Learning Objectives

By the end, attendees should be able to:

1. **Name the three AI surfaces available to us and say which problem each solves** —
   Joule for Developers (in-IDE assistant), the ABAP MCP Server (agentic access
   from any MCP client), and the ABAP AI SDK/ISLM (AI *inside* our ABAP apps).
2. **Use at least two Joule capabilities in ADT** — explain an unfamiliar object,
   and generate ABAP Unit tests for an existing class — and judge the output
   rather than accepting it.
3. **State the two governance rules that apply to every AI suggestion on this
   project**: it is not compliant because an AI wrote it (released-API rules still
   apply), and generated code is reviewed the same as hand-written code.

## 3. Agenda (60 min)

| Time | Segment |
|---|---|
| 0–5 min | The three surfaces — one slide that frames everything |
| 5–18 min | AI writing our ABAP: Joule for Developers, what it actually does |
| 18–28 min | Agentic: the ABAP MCP Server, and what "agentic" changes |
| 28–40 min | Demo |
| 40–48 min | ABAP writing AI: the ABAP AI SDK / ISLM on our PCE 2025 |
| 48–55 min | Governance: the honest limits, cost, and our two rules |
| 55–60 min | Cheat sheet, discussion prompt, next session |

## 4. Core Content Outline

**A. The three surfaces (5 min) — the frame for the whole session**

| Surface | What it is | Where it runs | Our status |
|---|---|---|---|
| **Joule for Developers, ABAP AI** | AI assistant inside ADT (Eclipse) and ADT for VS Code | BTP hub service → AI Core | Applies to PCE 2021+ → **available to us** |
| **ABAP MCP Server** | ABAP dev operations exposed as MCP tools for any agent | Eclipse + VS Code | **GA** — works with Copilot / Claude Code / Amazon Q |
| **ABAP AI SDK (ISLM)** | Call an LLM *from* ABAP code via SAP AI Core | In-stack | **Standard delivery from release 2025** → we qualify |

Say plainly: the first two change *how we write code*; the third changes *what our
code can do*.

**B. Joule for Developers — what it actually does (13 min)**
- **Explain** — ABAP and CDS explained in plain language. The highest-value use for
  this team: understanding inherited custom code before touching it.
- **Predictive code completion** — next-line suggestions from context.
- **Generate CDS from natural language** — describe the view, get syntactically
  correct, Clean-Core-shaped CDS.
- **RAP business logic prediction** — validations and determinations generated
  in-context following RAP patterns. Ties directly to session 2.
- **OData UI Service wizard + Joule chat** — entities, behavior, service binding
  in one flow.
- **ABAP Unit test generation** — for public/protected/private methods of global
  classes and public methods of local classes; includes dependency analysis, test
  double support, explanation of generated tests, refactoring, and splitting test
  classes.
- Behind it: **SAP-ABAP-1**, SAP's own ABAP foundation model, trained on 250M+
  lines of ABAP and 30M+ lines of CDS plus technical documentation — purpose-built
  to explain and generate modern ABAP, with no model management on our side.

**C. Agentic and the ABAP MCP Server (10 min)**
- The 2026 shift: from *skills you invoke* to *agents that carry out a task*.
- **ABAP MCP Server** is built on the ABAP Language Server and exposes ABAP
  development capabilities as MCP tools — object management, transport request
  handling, syntax checks, documentation and feature-matrix access.
- MCP is an open protocol, so **any compatible agent can drive it** — which is why
  our existing Copilot and Claude Code setups matter here.
- **ADT for VS Code reached GA on 29 May 2026** — but read the scope honestly:
  initial focus is Fiori app development, and **Eclipse is still required for full
  ABAP development** and complex backend objects. Do not tell the team to migrate.
- **Three custom code agents** aimed at S/4HANA migration: Mass S/4 Custom Code
  Conversion (Q2 2026), Mass Clean Core Adoption (later 2026), Web Dynpro → Fiori
  Modernization (later 2026). Design principle worth repeating: they **explain and
  understand existing code before proposing changes**. SAP targets a 40% efficiency
  gain on custom code transformation — internal evaluation, no independent benchmark.

**D. Demo (12 min) — see §5**

**E. ABAP AI SDK / ISLM — building AI into our apps (8 min)**
- Lets ABAP code call LLMs through the **generative AI hub in SAP AI Core**.
- **Standard delivery for PCE and on-premise as of release 2025** (lower releases
  via TCI, where the ISLM TCI is a prerequisite for the ABAP AI SDK TCI).
- Connection is via communication scenario **`SAP_COM_0A69`** — a customer outbound
  integration requiring manual setup, plus the usual ISLM configuration.
- Where it could matter for Lead-to-Cash: classifying inbound customer
  correspondence, summarising a disputed invoice's history, drafting a first-pass
  response — always with a human decision point.
- Architect's note: this is an **integration and a cost centre**, not a library
  call. It goes in the TDD like any other external dependency.

**F. Governance — the honest limits (7 min)**
- **Adoption is early.** Reported figures put Joule production use at roughly 3% of
  SAP customers. We are early adopters, not laggards catching up.
- **No governance framework yet** for autonomous agent decisions in productive ERP
  systems. That gap is ours to fill on this project.
- **Cost is genuinely hard to predict** — agentic workloads make consumption
  "harder by design" to estimate up front. AI Units, activated via SAP for Me.
- **Not everyone qualifies** — on-premise systems without RISE/GROW contracts and
  cloud connectivity are excluded.
- **Our two rules** (the part they must remember):
  1. **AI authorship is not compliance.** A generated `SELECT` on a non-released
     table is still a Clean Core violation. The released-API check is unchanged —
     that's session 3.
  2. **Generated code is reviewed exactly like hand-written code.** Same checklist,
     same severities, and the author owns it — "Joule wrote it" is not a defence.

## 5. Demo Plan

- **Environment:** `[CONFIRM — DEV system + Eclipse ADT with current patch level;
  Joule for Developers entitlement active]`
- **Prep dependency (important):** confirm the Joule entitlement and the ADT patch
  level a week ahead. If entitlement is not in place, run the MCP half only — that
  path works today with our existing Copilot / Claude Code setup — and use SAP's
  published demo material for the Joule half.
- **Steps:**
  1. **Explain** — open a genuinely gnarly inherited custom object from our
     codebase; ask Joule to explain it. Compare with what we know is true.
     *This is the credibility moment: pick something you already understand.*
  2. **Generate ABAP Unit tests** — take a class we have with no tests; generate;
     read the generated tests critically as a group. What did it miss?
  3. **Agentic via MCP** — from VS Code or Claude Code with the ABAP MCP Server,
     ask for a small multi-step task (read an object, syntax check, report back).
     Show that it uses real system state, not a guess.
  4. **The guardrail** — ask for something that would consume a non-released
     object. Show what comes back, then show the review catching it. This is the
     slide the team should remember.
- **Fallback:** recordings of steps 1–3 from the dry run, plus screenshots.

## 6. Discussion Questions

1. Where in your current work item would "explain this object" have saved you the
   most time this month — and what stopped you from trusting the answer?
2. If an agent can create objects and handle transport requests, what should it
   *never* be allowed to do on this project without a human approving it first?

## 7. Takeaways / Cheat Sheet

> **AI for ABAP — where we stand, Sept 2026**
>
> **Three surfaces**
> · **Joule for Developers** — explain · complete · generate CDS · RAP validations
>   & determinations · **generate ABAP Unit tests**. In ADT (Eclipse) and VS Code.
>   Applies to PCE 2021+ via a BTP hub service → **available to us**.
> · **ABAP MCP Server** (GA) — ABAP dev operations as MCP tools; drive it from
>   Copilot, Claude Code, Amazon Q. Object management, transports, syntax checks, docs.
> · **ABAP AI SDK / ISLM** — call an LLM **from** ABAP via SAP AI Core.
>   Standard delivery from **release 2025**; comm scenario `SAP_COM_0A69`.
>
> **Behind Joule:** SAP-ABAP-1, SAP's ABAP-trained foundation model.
>
> **Watch out**
> · ADT for VS Code is GA (29 May 2026) but **Eclipse is still required** for full
>   ABAP development — don't migrate yet.
> · Pricing is consumption-based **AI Units** via SAP for Me; agentic usage is hard
>   to forecast.
> · No governance framework yet for autonomous agents in productive ERP.
>
> **Our two rules**
> 1. **AI authorship ≠ compliance.** Released-API rules are unchanged.
> 2. **Generated code is reviewed like hand-written code. The author owns it.**

## 8. References — verified 2026-09-04

*Re-verify before delivery; this topic changes monthly, and product names shift.*

- [Sapphire 2026 recap: Joule for Developers Agentic ABAP AI is generally available](https://community.sap.com/t5/technology-blog-posts-by-sap/sapphire-2026-recap-joule-for-developers-agentic-abap-ai-is-generally/ba-p/14405739) — GA announcement
- [Our 2026 Roadmap for Joule for Developers ABAP AI capabilities](https://community.sap.com/t5/technology-blog-posts-by-sap/our-2026-roadmap-for-joule-for-developers-abap-ai-capabilities/ba-p/14360358)
- [SAP Joule for Developers, ABAP AI capabilities including agentic capabilities is now available](https://community.sap.com/t5/artificial-intelligence-blogs-posts/sap-joule-for-developers-abap-ai-capabilities-including-agentic/ba-p/14417633)
- [Entering the New Era of Agentic AI for ABAP Development](https://community.sap.com/t5/technology-blog-posts-by-sap/entering-the-new-era-of-agentic-ai-for-abap-development/ba-p/14394643)
- [SAP Joule for Developers, ABAP AI capabilities for S/4HANA Cloud Private Edition 2025](https://community.sap.com/t5/technology-blog-posts-by-sap/sap-joule-for-developers-abap-ai-capabilities-for-sap-s-4hana-cloud-private/ba-p/14236954)
- [SAP Help — Joule for Developers, ABAP AI Capabilities (ADT user guide)](https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/joule-for-developers-abap-ai-capabilities)
- [SAP-ABAP-1 — SAP foundation model for ABAP](https://www.sap.com/products/artificial-intelligence/sap-abap.html)
- [SAP Joule for Developers product page](https://www.sap.com/products/artificial-intelligence/joule-for-developers.html)
- [SAP Help — Set Up ABAP AI SDK powered by ISLM](https://help.sap.com/docs/abap-ai/generative-ai-in-abap-cloud/set-up-abap-ai-sdk-powered-by-intelligent-scenario-lifecycle-management)
- [ABAP AI SDK for Generative AI (SAP Developers)](https://developers.sap.com/concepts/abap-ai-sdk/)
- [SAP Help — Generative AI for ISLM](https://help.sap.com/docs/SAP_S4HANA_CLOUD/6aa39f1ac05441e5a23f484f31e477e7/fd682bfef603494b9023b1f1b93f27e0.html)
- [Generating ABAP Unit Tests with SAP Joule (SAP Learning)](https://learning.sap.com/courses/deepening-your-abap-programming-knowledge/generating-abap-unit-tests-with-sap-joule)
- [ABAP Goes Agentic: MCP Server, VS Code, and the Price of AI Support](https://www.rotecodefraktion.de/en/blog/abap-mcp-server-agentic-ai-sapphire-2026/) — independent analysis; source of the adoption, governance and cost caveats

## 9. Notes

**Prep notes** — Research verified 2026-09-04 against the sources in §8.
**Re-verify the week of delivery**: SAP renames and re-scopes AI products
frequently, and several items here were announced within the last two quarters.

Two claims are deliberately attributed rather than stated as fact: the ~3%
production adoption figure and the 40% custom-code-transformation efficiency
target (SAP internal evaluation, no independent benchmark). Present both as
reported, not as established — the team's trust depends on that distinction.

The demo's credibility rests on step 1 using an object **you already understand**,
so you can judge the explanation live rather than admiring it. Confirm the Joule
entitlement and ADT patch level a week ahead; if it isn't there, the MCP half
still works with our existing tooling and the session survives.

Deliberately excluded to protect the runtime: Joule Studio, BTP AI Foundation
beyond what the SDK needs, and the broader Joule-for-business-users story. Park
them as follow-up sessions if the discussion pulls that way.

**Delivery notes** — (fill after the session)

## 10. Feedback / Follow-ups Logged After Session

| Item | Raised by | Action | Owner | Status |
|---|---|---|---|---|

## 11. Next Session

| Field | Value |
|---|---|
| Proposed topic | RAP managed Business Object end-to-end for classic ABAP developers |
| Proposed `ppt_date_time` | `2026-09-25 14:00 IST` `[CONFIRM]` |
| Why this next | Session 1 showed Joule generating RAP validations and determinations. That's only useful to a developer who can judge whether the generated logic sits in the right place — which is exactly session 2. Natural hook: "it will write your determination; you still have to know it should have been a validation." |
