# Setup Guide

## Before anything: the ground-truth files

The `reference/` folder is cited by almost every skill — **keep it next to
`skills/` wherever you deploy**, or the fit-to-standard challenge degrades to
generic advice.

| File | What it drives |
|---|---|
| `sap-project-standards.md` | Platform, extensibility tiers, naming, released-API rules. Edit this first when a project-wide assumption changes. |
| `adt-mcp-usage.md` | How skills use the live ABAP system |
| `fit-to-standard-patterns.md` | The 48-pattern challenge catalog used in FS review and workshops |
| `l2c-standard-process-reference.md` | Process spine, config objects, determinations, billing relevance, output |
| `pricing-condition-technique-reference.md` | Condition technique depth, copy-control pricing type, settlement management |
| `s4hana-simplification-redflags.md` | ECC→S/4 scan list for FS review |

Add to the domain files after every engagement — that's the layer that compounds.

## ADT MCP (`adt-mcp`) — live ABAP system access

The code and architecture skills use an abap-adt-api based MCP server for live
system reads (object source, DDIC/CDS metadata, where-used, API release state,
ATC, ABAP Unit) and, on explicit confirmation, writes (create/activate/transport).

1. Configure the `adt-mcp` server in your Claude Code / Claude Desktop MCP
   settings with the target ABAP system's connection and credentials.
2. Verify it connects (`/mcp` in Claude Code, or the MCP status panel). If it
   fails, skills fall back to working from pasted code and mark released-API
   claims `[CONFIRM in ADT]` — they don't stall.
3. Safety rule enforced by every skill: **reads are automatic, writes never
   happen without you confirming the exact object list + package + transport in
   the same turn.** Review skills (`clean-abap-code-reviewer`,
   `abap-cloud-readiness-checker`, `architecture-reviewer`) never write.

## Claude Desktop

1. Copy the folders under `skills/` into your personal Claude skills
   directory (Settings → Capabilities → Skills → add from folder, or the
   equivalent skills directory Claude Desktop uses on your machine — each
   subfolder here is already in the right shape: a folder containing one
   `SKILL.md`).
2. Claude picks up the skill automatically based on its `description` when
   a matching task comes up — e.g. mention "functional spec" or paste
   workshop notes, and `functional-spec-writer` / `requirement-workshop-facilitator`
   will trigger. You can also invoke by name.
3. Keep `templates/` alongside the skills (or referenced by path) — the
   skills point to them by relative path (`templates/functional-spec-template.md`).

## Claude Code (VS Code / terminal)

1. From any project you're working in, either:
   - Symlink or copy `skills/*` into that project's `.claude/skills/`
     directory, or
   - Keep this whole repo cloned locally and point Claude Code's global
     skills directory at it.
2. Skills work the same way as Desktop — auto-trigger by description, or
   invoke with `/skill-name`.
3. The `agents/architecture-reviewer.md` file is written in Claude Code's
   subagent format — copy it into a project's `.claude/agents/` folder to
   use it as a delegated subagent (`Task` tool) rather than a plain skill.

## GitHub Copilot (VS Code + Eclipse)

1. **Repo-wide instructions**: copy `.github/copilot-instructions.md` into
   the root of each ABAP project repository (or wherever your
   Eclipse/ADT-linked working copy mirrors to) as `.github/copilot-instructions.md`.
   Copilot Chat in VS Code picks this up automatically for every chat in
   that repo. (Eclipse Copilot support for custom instructions varies by
   extension version — check your installed Copilot extension's docs; at minimum,
   paste the file's content into the chat manually there.)
2. **Reusable prompts**: copy `.github/prompts/*.prompt.md` into the same
   `.github/prompts/` folder in your ABAP project repo. In VS Code Copilot
   Chat, run them with `/workshop-notes`, `/functional-spec-draft`,
   `/clean-core-extensibility-check`, `/clean-abap-review`,
   `/abap-cloud-readiness`, `/coe-session-planner`, `/functional-spec-review`,
   `/technical-design-draft`, `/solution-design-review`, `/rap-bo-scaffold`,
   `/cds-view-scaffold`, `/abap-unit-test`, `/odata-service-expose` — select
   code/text first so `${selection}` has something to work on. The generation prompts assume the standards in
   `reference/sap-project-standards.md`; copy `reference/` into the project repo
   too, or paste the relevant rules when Copilot can't see it.
3. Keep this `sap-technical-assets` repo as the source of truth; re-copy
   into project repos when you update a prompt here.

## Gemini Notebook

1. Create a Notebook per engagement (or one for solution-design work in
   general) and upload your source documents: workshop transcripts, draft
   FS documents, SAP release notes/roadmap exports, code exports.
2. Open the matching file in `gemini/` and copy its content into the
   Notebook's query box, filling in the `Sources:` line at the bottom with
   the actual document names you uploaded.
3. These are analysis/review templates (Gemini Notebook doesn't run
   multi-step agents) — use them for reviewing and structuring content
   grounded in what you've uploaded, then take the output into
   `functional-spec-writer` (Claude) or the FS template directly for final
   drafting.

## Keeping things in sync

Treat `skills/<name>/SKILL.md` as canonical. When you improve a method:

1. Update the SKILL.md.
2. Update the matching `.github/prompts/<name>.prompt.md` and `gemini/<name>.md`
   so all three tools apply the same logic.
3. Commit and push:
   ```bash
   git add -A
   git commit -m "update <skill-name>: <what changed>"
   git push
   ```

## COE knowledge-sharing cadence

`coe-session-planner` (Claude skill) or `/coe-session-planner` (Copilot
prompt) drafts each biweekly session. After delivering a session, append a
row to `docs/coe-session-log.md` so there's a running record for the COE.
