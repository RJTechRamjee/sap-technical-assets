# `zl2c-billing-ext` — a worked example ABAP repo

This is the repository shown in **COE Session 02 — Organizing an ABAP Repo for
GitHub Copilot**. It is a *fictional* L2C billing extension project, complete
enough to open in VS Code or Eclipse and watch each Copilot customization layer
fire.

Copy this folder into a new repo of your own, replace `src/` with your real ABAP,
and adjust the rules. Nothing here is engagement-specific.

## What's in it

| Path | Layer | What pulls the trigger |
|---|---|---|
| `.github/copilot-instructions.md` | Rules | Nobody — loaded on **every** request |
| `.github/instructions/*.instructions.md` | Scoped rules | The `applyTo` glob matching the open file |
| `.github/agents/*.agent.md` | Agents | **You**, from the agent picker |
| `.github/skills/pricing-review/SKILL.md` | Skills | The **model**, when it judges the skill relevant |
| `.github/prompts/clean-abap-review.prompt.md` | Prompts | **You**, typing `/clean-abap-review` |
| `.vscode/mcp.json` | MCP | Server config — the one Copilot file not in `.github/` |
| `reference/released-apis.md` | — | Ours, not Copilot's. Instruction files *link* to it |

## Try it in five minutes

1. Open this folder as a workspace in VS Code with Copilot enabled.
2. Ask Copilot Chat: *"Write me a report that reads billing document data."*
   The repo-wide rules push it toward ABAP Cloud and released APIs without you
   saying so.
3. Open `src/zi_billingdocitem_ext.ddls.asddls`, ask the same thing, and watch
   `cds-views.instructions.md` add the CDS-specific rules on top — because its
   `applyTo: '**/*.asddls'` now matches.
4. Open `src/zcl_bill_output.clas.abap` and ask again. Different file, different
   rules, same question.
5. Select the **FS Reviewer** agent and ask it to review any requirement text.

## Reality check before you rely on this

Copilot's customization surface moves. As verified **2026-09-16**:

- Prompt files are **deprecated** (auto-migrating to agent skills) and have
  **never** been supported in the Eclipse extension, at any version.
- Custom agents were renamed from *custom chat modes* in VS Code 1.106. The old
  `.github/chatmodes/*.chatmode.md` still works; new files go in
  `.github/agents/*.agent.md`.
- In **Eclipse**, scoped `instructions/` files load in **agent mode only**, not
  in plain Copilot Chat. Only `copilot-instructions.md` loads in both — which is
  why the load-bearing rules belong there.

Re-check before you build a habit on it:
`https://docs.github.com/en/copilot/reference/copilot-feature-matrix`

## What is deliberately *not* asserted here

`reference/released-apis.md` teaches you how to **check** an API's release state
in ADT rather than listing technical names. A list of released CDS views in a
Markdown file goes stale silently and is then wrong in a way nobody notices. The
system is the source of truth; this repo points at it.
