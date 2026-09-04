# COE Biweekly Knowledge-Sharing Session

| Field | Value |
|---|---|
| Session # | 01 |
| Topic | AI-assisted ABAP with the tools we already have — Copilot, Claude Code, and the ABAP MCP Server |
| Presenter | Ramjee |
| **`ppt_date_time`** | `2026-09-11 14:00 IST` `[CONFIRM — day/time slot not yet fixed]` |
| Duration | 60 min |
| Meeting link | `[CONFIRM]` |
| Deck file | [`COE-S01_2026-09-11_ai-assisted-abap.pptx`](decks/COE-S01_2026-09-11_ai-assisted-abap.pptx) — 15 slides, speaker notes in the notes pane. Source: [`.deck.md`](decks/COE-S01_2026-09-11_ai-assisted-abap.deck.md); rebuild with `python tools/build_deck.py <deck>.deck.md` |
| Recording link | (fill after delivery) |
| Audience | ABAP developer community (offshore) |
| Status | Planned |
| Format | **Demo-led** — ~25 of 60 minutes is live tooling |
| Scope note | **Joule for Developers is deliberately out of scope** — we have no licence. Everything demonstrated here runs on tooling the team already has. |
| Related repo assets | `.github/copilot-instructions.md` · `.github/prompts/*` · `reference/adt-mcp-usage.md` · `reference/sap-project-standards.md` §4–§7 |

## 1. Why This Topic, Now

We do not have a Joule licence, so the SAP-native AI assistant is not available to
us. That is not the constraint people assume it is — **we already own the tools
that close most of the gap**, and we are barely using them:

- Every developer has **GitHub Copilot** in VS Code and Eclipse, and most use it as
  autocomplete — ungrounded, unaware of our release, our standards or our naming.
- We have an **ABAP MCP server** configured, which lets an agent read the real
  system instead of inventing plausible answers. Almost nobody is using it.
- The `sap-technical-assets` repo now contains **repo-wide Copilot instructions and
  eleven reusable prompt files** encoding our Clean Core and Clean ABAP rules —
  written, committed, and so far unused by the team.

The gap is not licensing. It is that we are running the tooling at level 1 when it
goes to level 3. This session closes that, and rolls out the repo assets.

## 2. Learning Objectives

By the end, attendees should be able to:

1. **Install and use the repo's Copilot assets in their own project repo** —
   `copilot-instructions.md` plus the prompt files — and run at least two prompts
   end to end (`/rap-bo-scaffold`, `/abap-unit-test`).
2. **Explain and demonstrate why an MCP-connected agent answers differently** from
   plain chat — grounded in real object metadata and API state versus plausible
   invention — and say when the difference matters.
3. **Apply the two guardrails to any generated line**: the released-API check still
   applies regardless of who wrote it, and generated code is reviewed exactly like
   hand-written code, with the author owning it.

## 3. Agenda (60 min)

| Time | Segment |
|---|---|
| 0–5 min | Why: no Joule licence, and why that matters less than you think |
| 5–15 min | The three levels of AI assistance — the frame |
| 15–40 min | **DEMO** (three staged demos) |
| 40–48 min | The failure gallery: where it gets ABAP wrong |
| 48–55 min | Guardrails + how we adopt this on Monday |
| 55–60 min | Cheat sheet, discussion, next session |

## 4. Core Content Outline

**A. The three levels of AI assistance (10 min) — the frame for everything**

| Level | What it is | What it knows | What you get |
|---|---|---|---|
| **1. Ungrounded** | Copilot as autocomplete, no configuration | Generic ABAP from training data | Classic patterns, invented SAP names, no awareness of our release |
| **2. Instructed** | Repo-wide instructions + reusable prompt files | Our platform, standards, naming, Clean Core rules | ABAP Cloud-shaped output, correct layering, `[CONFIRM]` instead of invention |
| **3. Grounded / agentic** | Level 2 + MCP server connected to the system | The *actual* objects, field lists, API release states | Answers from system truth; multi-step tasks with real tool calls |

The point to land: **the model does not get smarter between levels — we give it
context.** Level 2 costs one file copy. Level 3 costs a connection.

**B. Demo (25 min) — see §5. This is the session.**

**C. The failure gallery — where it gets ABAP wrong (8 min)**

Be specific and honest; this is what earns developer trust:

- **Invents SAP names that look right** — table, field and BAPI names that are
  plausible and wrong. The most dangerous failure because it survives review by
  people who don't know the object.
- **Defaults to classic ABAP** — `SELECT` straight off `VBAK`, dynpro-era thinking,
  pre-7.4 syntax. The training data is overwhelmingly classic on-premise ABAP.
- **Doesn't know our released-API set** — it has no idea what is released in
  S/4HANA 2025, and Private Edition will happily compile the mistake.
- **Confidently wrong on RAP save-sequence rules** — side effects in the wrong
  handler, missing `FAILED` alongside `REPORTED`. Leads directly into session 2.
- **Generates tests that assert the implementation, not the rule** — they pass, and
  they prove nothing.
- **Knows nothing of our naming, packages or transports** unless we tell it.

Every one of these is an argument for level 2 and level 3, not against the tooling.

**D. Adoption — what to do on Monday (7 min)**

1. Copy `.github/copilot-instructions.md` from `sap-technical-assets` into your
   project repo. Copilot Chat picks it up automatically for every chat in that repo.
2. Copy `.github/prompts/*.prompt.md` into the same repo. The ones you'll use most:
   `/rap-bo-scaffold` · `/cds-view-scaffold` · `/abap-unit-test` ·
   `/odata-service-expose` · `/clean-abap-review` · `/abap-cloud-readiness`
3. Select the code or spec text first, then run the prompt — `${selection}` is what
   it works on.
4. Connect the ABAP MCP server for anything where system truth matters.
5. **The two guardrails:**
   - **Released-API rules are unchanged.** A generated `SELECT` on a non-released
     table is still a Clean Core violation. Session 3 is the check itself.
   - **Generated code is reviewed like hand-written code, and the author owns it.**
     "Copilot wrote it" is not a defence in review.

## 5. Demo Plan

**Environment:** VS Code with Copilot + ADT; the ABAP MCP server configured against
`[CONFIRM — DEV system]`; a scratch project repo for the before/after.

> **Prep dependency — treat as blocking.** The ABAP MCP server has failed to
> connect before. Verify the connection the day before *and* an hour before the
> session. Demo 2 is the centrepiece and does not degrade gracefully.

### Demo 1 — Level 1 → Level 2: same ask, two results (10 min)

1. In a bare repo with no instructions, ask Copilot: *"create a CDS view for sales
   order items with customer data."* Read the output aloud — expect direct table
   access, invented field names, no ABAP Cloud awareness, no layering.
2. Copy in `.github/copilot-instructions.md`, then run `/cds-view-scaffold` with the
   same requirement.
3. Compare side by side: `ZI_`/`ZC_` layering, released-CDS sourcing, `@UI` pushed
   to a metadata extension, `[CONFIRM in ADT]` where it doesn't know — instead of a
   confident invention.
4. Say the line: *"Same model. Same question. We gave it our standards."*

### Demo 2 — Level 3: grounding via the ABAP MCP Server (10 min)

1. Ask, **without** MCP: *"what fields does `<our custom entity>` have, and is
   `<some SAP object>` released?"* → plausible, unverifiable answer.
2. Ask the same **with** the MCP server connected → real field list read from the
   system, real API release state.
3. Then a small multi-step task: read an object → syntax check → report back.
   Show the tool calls happening so it's visibly using the system, not memory.
4. Say the line: *"Level 2 stops it inventing our standards. Level 3 stops it
   inventing our system."*

### Demo 3 — the guardrail (5 min)

1. Ask for something that would consume a non-released object.
2. Show what comes back — it will look fine.
3. Run `/clean-abap-review` on it and watch it flagged 🔴.
4. Punchline: **the tooling helps; the contract does not move.** Hook to session 3.

**Fallback:** capture all three demos as recordings during the dry run.
Specifically pre-record Demo 1's level-1 output — model behaviour varies between
runs and you cannot rely on it being reliably bad live. Screenshots of the MCP
tool calls as a second fallback.

## 6. Discussion Questions

1. Where did Copilot last give you something confidently wrong in ABAP — and what
   would have caught it: the instructions file, the MCP connection, or review?
2. If an MCP-connected agent can read objects, run syntax checks and touch
   transport requests, what should it never be allowed to do on this project
   without a human approving it first?

## 7. Takeaways / Cheat Sheet

> **AI-assisted ABAP — what we can do today (no Joule licence needed)**
>
> **Three levels — move up two of them this week**
> · **L1 Ungrounded** — plain Copilot. Invents SAP names, writes classic ABAP.
> · **L2 Instructed** — copy `.github/copilot-instructions.md` + `.github/prompts/*`
>   into your project repo. One file copy. Biggest single win.
> · **L3 Grounded** — connect the ABAP MCP server. It reads real objects, real
>   field lists, real API states instead of guessing.
>
> **Prompts to use:** `/rap-bo-scaffold` · `/cds-view-scaffold` · `/abap-unit-test`
> · `/odata-service-expose` · `/clean-abap-review` · `/abap-cloud-readiness`
> *(select the code or spec text first)*
>
> **Where it will fail you:** invented SAP table/field/BAPI names · classic ABAP by
> default · no idea what's released in our system · RAP save-sequence rules · tests
> that assert the implementation instead of the rule
>
> **The two rules that don't change**
> 1. **AI authorship ≠ compliance.** Released-API rules apply to every line.
> 2. **Generated code is reviewed like hand-written code. The author owns it.**

## 8. References

- `sap-technical-assets` repo — `.github/copilot-instructions.md`, `.github/prompts/`,
  `docs/setup-guide.md` (install steps per tool)
- `reference/adt-mcp-usage.md` — the MCP contract: read freely, write only on
  explicit confirmation
- `reference/sap-project-standards.md` §4 (ABAP Cloud language & API rules),
  §5 (naming), §7 (how to verify an object is released)
- GitHub Copilot custom instructions and prompt files documentation `[CONFIRM current link]`

*(Note: SAP's own Joule for Developers and the SAP-delivered ABAP MCP Server exist
and reached GA in 2026, but both require entitlement we don't hold. Mention in one
line if asked; do not build the session on them.)*

## 9. Notes

**Prep notes** — The session's value is the demo, so protect it. Two things will
sink it: the MCP server not connecting (verify twice), and Demo 1's level-1 output
being accidentally good (pre-record a bad run in the dry run and use that).

Pick a real custom object for Demo 2 — one the room recognises — so the "it read
the actual field list" moment is verifiable by the audience rather than taken on trust.

This session is also the delivery vehicle for the repo assets. Have the repo URL on
the cheat-sheet slide, and consider making the level-2 file copy a live exercise in
the room if the meeting format allows — adoption drops sharply if it's homework.

Deliberately out of scope: Joule (no licence), SAP's delivered ABAP MCP Server
(entitlement), and the ABAP AI SDK / ISLM — the last is a genuine follow-up now
that BTP + AI Core is available, proposed as S04.

**Delivery notes** — (fill after the session)

## 10. Feedback / Follow-ups Logged After Session

| Item | Raised by | Action | Owner | Status |
|---|---|---|---|---|

## 11. Next Session

| Field | Value |
|---|---|
| Proposed topic | RAP managed Business Object end-to-end for classic ABAP developers |
| Proposed `ppt_date_time` | `2026-09-25 14:00 IST` `[CONFIRM]` |
| Why this next | Session 1 showed the tooling will generate RAP behavior code that looks right. Session 2 is the judgement to tell whether it *is* right — whether a rule belongs in a determination or a validation, and what the save sequence will and won't allow. The tool is only as good as the developer supervising it. |
