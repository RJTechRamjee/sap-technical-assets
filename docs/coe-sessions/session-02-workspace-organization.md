# COE Biweekly Knowledge-Sharing Session

| Field | Value |
|---|---|
| Session # | 02 |
| Topic | Organizing an ABAP project repo for GitHub Copilot — the `.github/` folder layer by layer: rules, scoped rules, agents, skills, prompts |
| Presenter | Ramjee |
| **`ppt_date_time`** | `2026-09-25 14:00 IST` `[CONFIRM — day/time slot not yet fixed]` |
| Duration | 60 min |
| Meeting link | `[CONFIRM]` |
| Deck file | [`COE-S02_2026-09-25_workspace-organization.pptx`](decks/COE-S02_2026-09-25_workspace-organization.pptx) — source: [`.deck.md`](decks/COE-S02_2026-09-25_workspace-organization.deck.md); rebuild with `python tools/build_deck.py <deck>.deck.md` |
| Recording link | (fill after delivery) |
| Audience | ABAP developer community (offshore) — senior developers, ADT/Eclipse-first |
| Status | Planned |
| Format | Live build-from-empty demo — a scratch ABAP repo with no `.github/` folder, built up one layer at a time |
| Related SAP note / doc links | VS Code agent customization — `https://code.visualstudio.com/docs/agent-customization/custom-instructions` · Copilot feature matrix — `https://docs.github.com/en/copilot/reference/copilot-feature-matrix` · Custom instructions support by client — `https://docs.github.com/en/copilot/reference/custom-instructions-support` `[all verified 2026-09-16 — re-check before delivery]` |
| Related repo assets | **`examples/zl2c-billing-ext/` — the worked example repo shared with attendees** · `.github/copilot-instructions.md` · `.github/prompts/*.prompt.md` · `docs/setup-guide.md` · `reference/sap-project-standards.md` |
| Handout | `examples/zl2c-billing-ext/` — every file from the folder slide, working. Attendees copy it and swap in their own `src/`. Share the link during the "Do This Monday" slide, not after the session. |

## 1. Why This Topic, Now

Session 1 ended on "copy these files into your project repo" and left the obvious
follow-up unanswered: *what are those files, why that folder, and what makes each
one run?* Nobody on the team can currently build a `.github/` folder from an empty
repo without copying ours, which means nobody can adapt it, debug it, or extend it.

Re-checking the documentation before drafting this session turned up two facts
that were not on session 1's slides, both of which change the advice:

1. **Prompt files have never been supported in the Eclipse Copilot extension** —
   not at the current 0.14.0, not at any version back to 0.1.0. Session 1 told an
   Eclipse-first room to install eleven of them.
2. **Prompt files are being retired.** They are deprecated for Agent Host and
   auto-migrating to agent skills, with the migration enabled by default. Even the
   frontmatter moved: `mode:` has been replaced by `agent:`.

The counterweight is genuinely good news: **custom agents are supported in
Eclipse**, added in extension 0.13.0 (they were ✗ at 0.12.0). So the rich,
persona-plus-tools layer *does* run in ADT — it just isn't the layer we told
people to invest in.

This session therefore teaches the whole folder rather than one file type, and
ranks the five layers by what survives the trip into Eclipse, which is where this
room spends its day (`reference/sap-project-standards.md` §1).

## 2. Learning Objectives

By the end, attendees should be able to:

1. **Build the `.github/` folder from scratch** in an empty ABAP repo — all five
   file types, at the correct paths, with correct frontmatter, without copying
   from an existing repo.
2. **Name the invocation trigger for each layer** — automatic, `applyTo` glob
   match, user-selected, model-selected, or typed slash command — and use that to
   diagnose *which* layer is responsible when an answer comes back wrong.
3. **Choose the right layer for a given rule**, knowing which layers run in
   Eclipse chat, which run only in Eclipse agent mode, and which are VS Code only.

## 3. Agenda (60 min)

| Time | Segment |
|---|---|
| 0–4 min | The correction from session 1, and what changed in the docs |
| 4–12 min | The five layers, and the folder as a whole |
| 12–28 min | One slide per layer — path, frontmatter, trigger |
| 28–36 min | **DEMO** — build the folder from an empty repo, one file at a time |
| 36–43 min | How the layers compose; what actually fires in Eclipse |
| 43–50 min | Conventions, Monday actions, cheat sheet |
| 50–60 min | Discussion, next session |

## 4. Core Content Outline

**A. The correction (3 min)**

Own it directly — the room will trust the rest of the session more for it. Session 1
recommended the one layer that does not run in their primary IDE and is on its way
out. Reframe immediately onto what did get better: custom agents in Eclipse 0.13.0.

**B. The five layers — the spine (5 min)**

| Layer | Path | Who pulls the trigger |
|---|---|---|
| Rules | `.github/copilot-instructions.md` | Nobody — every request, automatically |
| Scoped rules | `.github/instructions/*.instructions.md` | The `applyTo` glob (and now semantic description matching) |
| Agents | `.github/agents/*.agent.md` | You — selected from the agent list |
| Skills | `.github/skills/<name>/SKILL.md` | The model, when it judges the skill relevant |
| Prompts | `.github/prompts/*.prompt.md` | You — typing `/name` |

The teaching point: these five differ less in *what they contain* than in *who
invokes them*. That framing is what makes the rest of the session navigable.

**C. The folder, whole (5 min) — the slide people photograph**

A realistic L2C billing extension repo, showing `.github/` fully populated
alongside `src/` with real ADT/abapGit extensions (`.clas.abap`, `.asddls`,
`.asbdef`) so the `applyTo` globs are visibly matched to real filenames. Two
things to call out: everything Copilot-related lives in `.github/` **except**
`mcp.json`, which lives in `.vscode/` and should be committed; and `reference/`
is ours, not Copilot's — instruction files *link* to it rather than duplicating it.

**D. One slide per layer (16 min)**

- **Layer 1** — plain Markdown, no frontmatter, must be at `.github/` in the
  workspace **root** (wrong path = silent no-op). On every request, so every line
  is a permanent cost. Repo-wide truths only: release, language version, naming,
  released-API rule.
- **Layer 2** — `applyTo` glob relative to workspace root; comma-separate several
  inside one string; folders searched recursively. Highest-leverage layer for ABAP
  because our artefact types have clean distinct extensions. Note that `description`
  is now used for **semantic matching**, not just hover text.
- **Layer 3** — renamed from *custom chat modes* in VS Code 1.106; old
  `.github/chatmodes/*.chatmode.md` still works and is treated as a custom agent,
  with an editor quick fix to migrate. Persona + restricted tool set. The rename is
  itself the best argument for this session's verify-first discipline.
- **Layer 4** — a **folder** per skill, not a file, so the method can bundle its own
  checklists and scripts. Frontmatter fields deliberately left as `[CONFIRM]` on the
  slide rather than asserted from memory. Not supported in Eclipse — don't start here.
- **Layer 5** — filename *is* the slash command. Show the mechanic, then the three
  caveats: `mode:` → `agent:`, the variables table has been withdrawn from the docs
  (only `${input:...}` and `${selection}` are currently documented), and it is
  deprecated and Eclipse-unsupported. Don't delete the existing eleven; don't write a twelfth.

**E. How the layers compose (3 min)**

One request pulls: always-on instructions → any `applyTo`-matched instruction files
→ whatever you invoked → your selection and attachments. Four layers, one of which
you typed. This is the diagnostic tool — wrong platform assumptions means layer 1,
right-for-classes-wrong-for-CDS means a layer 2 glob, right rules wrong job means
the wrong agent.

Caveat to state: all instruction files are provided to the model and **no ordering
is guaranteed** between them. Design non-overlapping rules; don't rely on one
file overriding another.

**F. What actually fires in Eclipse (4 min) — verified 2026-09-16**

Eclipse Copilot extension **0.14.0**:

| Feature | Eclipse |
|---|---|
| Chat, agent mode, MCP | ✅ Full |
| `.github/copilot-instructions.md` | 🟡 Preview — works in **chat and agent mode** |
| `.github/instructions/*.instructions.md` | 🟡 **Agent mode only — not plain chat** |
| `AGENTS.md` | 🟡 Agent mode only |
| Custom agents (`.github/agents/*.agent.md`) | ✅ Supported — new in 0.13.0 |
| Prompt files | 🔴 Not supported, at any version |
| Agent skills | 🔴 Not supported |

Source: `docs.github.com/en/copilot/reference/copilot-feature-matrix` and
`.../custom-instructions-support`, verified 2026-09-16.

**The single most consequential line for this room:** scoped instruction files work
in Eclipse **agent mode** but not in plain Copilot Chat. A quick question in the ADT
chat panel loads `copilot-instructions.md` only. Therefore: **put the load-bearing
rules in `copilot-instructions.md`** and use scoped files for refinement.

Say out loud that custom agents flipped from ✗ to ✓ between 0.12.0 and 0.13.0 —
that is the live proof that remembering this table is not good enough.

**G. Conventions and Monday actions (5 min)**

One file one concern · keep layer 1 short (it rides on every request) · write
`description` like it will be read semantically, because it is · link to
`reference/` rather than pasting · match globs to ADT extensions not invented
folder names.

Monday, in this order — 1) `copilot-instructions.md`, 2) two or three scoped
instruction files, 3) one agent, 4) skills/prompts only if the team really works
in VS Code. The order is ranked by what survives into Eclipse.

## 5. Demo Plan

- **Environment:** one scratch ABAP project repo with **no `.github/` folder at
  all**, open in VS Code with Copilot. A second checkout open in Eclipse/ADT for
  the Eclipse contrast. `[CONFIRM — DEV system for the ADT side]`.
- **One fixed question**, asked four times, unchanged — chosen in advance to
  contain an obvious ECC-vs-ABAP-Cloud trap so the ungrounded baseline answer is
  visibly wrong.
- **Steps:**
  1. Ask the question with no `.github/` folder. Baseline.
  2. Add `.github/copilot-instructions.md`. Ask again. Same model, same question.
  3. Add `.github/instructions/cds-views.instructions.md` with
     `applyTo: '**/*.asddls'`. Ask with a **class** open, then with a **CDS view**
     open — same repo, different file, different rules fire. This demonstrates
     `applyTo` rather than describing it.
  4. Add `.github/agents/fs-reviewer.agent.md`, select it, ask a third time.
- **Fallback if the live demo fails:** screen recording of all four steps captured
  during the dry run, plus a static slide showing the four answers side by side.
- **Prep required:** re-check the Eclipse extension version against the feature
  matrix the day before — custom-agent support changed between 0.12.0 and 0.13.0,
  and the matrix page itself is labelled public preview and subject to change.

## 6. Discussion Questions

1. Which rule do you find yourself repeating into Copilot Chat every single day?
   That is your layer 1 line — say it, and we'll collect them into a starter
   `copilot-instructions.md` for the team.
2. Which of your recurring jobs deserves its own agent, given that agents are the
   rich layer that actually runs inside ADT?

## 7. Takeaways / Cheat Sheet

> **The `.github/` folder — what goes where, and what pulls the trigger**
> *(verified 2026-09-16 — Copilot feature matrix + custom-instructions support reference; re-check before you rely on this)*
>
> | File | Trigger | Eclipse |
> |---|---|---|
> | `.github/copilot-instructions.md` | Always on, every request | ✅ chat + agent (Preview) |
> | `.github/instructions/*.instructions.md` | `applyTo` glob / description match | 🟡 agent mode only |
> | `.github/agents/*.agent.md` | You select it | ✅ since 0.13.0 |
> | `.github/skills/<name>/SKILL.md` | The model selects it | 🔴 |
> | `.github/prompts/*.prompt.md` | You type `/name` | 🔴 never — and deprecated |
> | `.vscode/mcp.json` | MCP server config — **commit it** | ✅ MCP supported |
>
> **Build order for an Eclipse-first team:** instructions file first, then scoped
> instruction files, then one agent. Skills and prompts only if you genuinely work
> in VS Code.
>
> **The rename:** custom chat modes → custom agents (VS Code 1.106).
> `.github/chatmodes/*.chatmode.md` still works; new files go in
> `.github/agents/*.agent.md`.

## 8. References

- VS Code — custom instructions —
  `https://code.visualstudio.com/docs/agent-customization/custom-instructions`
- VS Code — prompt files —
  `https://code.visualstudio.com/docs/agent-customization/prompt-files`
- VS Code — custom agents —
  `https://code.visualstudio.com/docs/agent-customization/custom-agents`
- VS Code — MCP servers —
  `https://code.visualstudio.com/docs/agent-customization/mcp-servers`
- VS Code 1.106 release notes (the chat-modes → custom-agents rename) —
  `https://code.visualstudio.com/updates/v1_106`
- GitHub — Copilot feature support matrix —
  `https://docs.github.com/en/copilot/reference/copilot-feature-matrix`
- GitHub — custom instructions support by client —
  `https://docs.github.com/en/copilot/reference/custom-instructions-support`
- `docs/setup-guide.md` — install steps per tool
- `reference/sap-project-standards.md` §1 — ADT/Eclipse as the primary build
  environment on this project

*(All external links verified 2026-09-16. The VS Code docs moved from
`/docs/copilot/customization/...` to `/docs/agent-customization/...`; old URLs
still redirect.)*

## 9. Notes

**Prep notes** — This session's factual claims are version-gated in two places:
the Eclipse Copilot extension version (custom-agent support changed between
0.12.0 and 0.13.0) and the VS Code version (the chat-mode → custom-agent rename
landed in 1.106). Re-fetch both the feature matrix and the custom-instructions
support reference the week of delivery, and confirm the installed Eclipse
extension version on the demo machine. The whole session argues for verifying
rather than reciting — do not deliver it from memory.

Two deliberate gaps, both to be left visible rather than papered over: the agent
skills `SKILL.md` frontmatter is marked `[CONFIRM]` on the slide, and the prompt
file variables table has been withdrawn from the official docs, so only
`${input:...}` and `${selection}` are presented as safe.

Tone: diagnostic, not apologetic. Session 1 was right about the tools and right
about the instructions file; the prompt-file recommendation aged badly in two
weeks. Audience is senior — no "what is Copilot" framing at any point.

**Delivery notes** — (fill after the session)

## 10. Feedback / Follow-ups Logged After Session

| Item | Raised by | Action | Owner | Status |
|---|---|---|---|---|

## 11. Next Session

| Field | Value |
|---|---|
| Proposed topic | RAP managed Business Object end-to-end for classic ABAP developers |
| Proposed `ppt_date_time` | `2026-10-09 14:00 IST` `[CONFIRM]` |
| Why this next | Content is already drafted (`docs/coe-sessions/session-rap-managed-bo.md`) and was the original session-2 promise from session 1 — this restores that thread once the workspace-organization detour is delivered. The released-API contract session is also drafted and queued behind it. |
