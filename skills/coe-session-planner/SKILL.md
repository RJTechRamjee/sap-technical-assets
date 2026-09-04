---
name: coe-session-planner
description: Use to plan a biweekly COE (Center of Excellence) knowledge-sharing session for the ABAP developer community — the full pipeline from picking/researching a topic (S/4HANA innovations, Clean Core, AI-driven ABAP development) through to a ready-to-deliver session using the km-session-template.
---

# COE Session Planner

You run the end-to-end pipeline for the biweekly ABAP developer knowledge-sharing session: topic selection → research → content drafting → session log entry. You are producing material for an SPOC/lead to actually deliver, not a generic training outline.

## Pipeline

### Step 1 — Topic selection

First check `docs/coe-topic-backlog.md` — if it has a P1 item with status
"Ready", propose that as the default pick (plus the next one down as an
alternative). Only generate fresh candidates if the backlog is empty or nothing
fits the moment. When a topic is chosen, update its row status in the backlog.

If no topic is given and the backlog doesn't settle it, propose 3 candidates
balancing:
- **A current S/4HANA/BTP innovation** (use `sap-innovation-radar` to research this — don't guess)
- **A recurring code-review or architecture pain point** seen recently (ask the user, or use `recent-work`/review history if available) — teaching from real findings lands better than generic theory
- **An AI-driven ABAP development topic** (GitHub Copilot patterns, AI-assisted code review, Joule for developers, prompt patterns for ABAP) — this COE explicitly wants AI-driven content as a recurring thread

For each candidate give: one-line pitch, why it's timely, estimated prep effort (S/M/L).

### Step 2 — Research

Once a topic is chosen, research it properly (web search for current SAP docs/release notes if it's a product topic; pull from the relevant skill's domain knowledge if it's a practice topic like Clean ABAP). Do not draft content from stale/unverified memory for anything version-specific (release names, product names, feature availability) — verify first, the same way `sap-innovation-radar` does.

### Step 3 — Draft the session

Fill `templates/km-session-template.md` completely:
- Learning objectives that are specific and checkable "attendees can identify when to use in-app vs side-by-side extensibility" — not "understand Clean Core better"
- A concrete demo plan — prefer a real, runnable example (a small RAP object, a before/after Clean ABAP diff, a Copilot prompt walkthrough) over slides-only
- Discussion questions that surface how this applies to *this team's* actual project work, not abstract SAP theory
- A one-page "cheat sheet" takeaway section developers can screenshot and keep — this is often the highest-value artifact from the whole session

### Step 3b — Build the deck

Write the deck as `docs/coe-sessions/decks/COE-S<nn>_<YYYY-MM-DD>_<topic-slug>.deck.md`
following the format in `templates/km-deck-outline.md`, then build it:

```bash
python tools/build_deck.py docs/coe-sessions/decks/<deck>.deck.md
```

12–16 slides, one takeaway each; a demo replaces slides rather than adding them.
**Speaker notes are what the presenter will actually say** — the lines to land
verbatim, the questions to ask the room, and a `FALLBACK:` line on every demo
slide. The session is not planned until the deck builds.

### Step 4 — Save the plan and log it

1. Write the filled session plan to `docs/coe-sessions/session-<nn>-<topic-slug>.md`.
2. Append a row to `docs/coe-session-log.md`:

| # | `ppt_date_time` | Topic | Presenter | Status | Deck file | Session plan |
|---|---|---|---|---|---|---|

3. Update the topic's row in `docs/coe-topic-backlog.md` to **Scheduled — S`<nn>`, `<date>`**.

**`ppt_date_time` discipline:** every session carries a concrete
`YYYY-MM-DD HH:MM` + timezone, and the deck file name is derived from it
(`COE-S<nn>_<YYYY-MM-DD>_<topic-slug>.pptx`). If the slot isn't fixed, propose one
on the biweekly cadence and mark it `[CONFIRM]` — never leave it blank, because
the whole cadence stalls on an unscheduled session. Always fill §11 Next Session
with the following topic and its proposed `ppt_date_time`.

## Recurring topic bank (seed ideas, refresh via sap-innovation-radar before using any of these)

- Clean Core deep-dive: reading a real extensibility decision end-to-end
- RAP fundamentals for classic ABAP developers (managed vs unmanaged BOs)
- ABAP Unit + CDS test doubles: making RAP logic testable
- Using GitHub Copilot effectively for ABAP: what it's good/bad at, prompt patterns that work
- Reviewing SAP release notes as a team: what changed this quarter for SD/Invoicing
- AI in the SAP landscape: Joule, AI Launchpad/Hub — what's relevant to developers vs functional teams
- Common Clean ABAP violations from our own recent code reviews (anonymized, pattern-focused)
- OData V4 / RAP-based Fiori app exposure walkthrough

## Cadence discipline

- Sessions are biweekly — keep scope to what's deliverable in 45-60 minutes; split larger topics across two sessions rather than cramming.
- Always end a session plan with a suggested next-session topic so the cadence doesn't stall waiting for inspiration.
