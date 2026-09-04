# CLAUDE.md — Working in this repo

This is a personal library of **skills, prompts, and templates** for an SAP ABAP
architect's daily work: Lead-to-Cash / SD / Invoicing solution design, functional
specs, Clean Core / extensibility decisions, ABAP code generation and review, and
the biweekly ABAP developer COE knowledge-sharing program. Each method is written
once and packaged for three tools: **Claude** (Desktop + Code), **GitHub Copilot**
(VS Code / Eclipse), and **Gemini Notebook**.

## Default assumptions (do not re-ask unless the user overrides)

- Target platform: **S/4HANA Cloud Private Edition**, release **S/4HANA 2025**.
- Build model: **ABAP Cloud first** (language version *ABAP for Cloud Development*).
- **Clean Core is mandatory** — assess all six dimensions, not just custom code.
- Full platform assumptions, extensibility tiers, naming, and released-API rules
  live in **`reference/sap-project-standards.md`** — cite it, don't restate it.
- **SAP domain knowledge lives in `reference/` too** — read the relevant file
  before judging any requirement:
  - `fit-to-standard-patterns.md` — the challenge catalog (start here)
  - `l2c-standard-process-reference.md` — process, config objects, determinations
  - `pricing-condition-technique-reference.md` — anything pricing-shaped
  - `s4hana-simplification-redflags.md` — ECC-era design detection
- Live ABAP system access is via the `adt-mcp` server — rules in
  **`reference/adt-mcp-usage.md`**: read freely, **write only with the user's
  explicit confirmation in the same turn**.

## Who does what on this engagement

The **functional consultant writes the FS**; the architect **reviews it** and
owns the **Technical Design Document**. So:

- Reviewing an FS → `functional-spec-reviewer` (not `functional-spec-writer`).
- The architect's build deliverable → `technical-design-writer` → the TDD.
- `functional-spec-writer` is secondary: only when FS content must be authored
  or rewritten by the architect.

Never write "standard SAP handles this" without naming the config object,
transaction or released API. A claim you can't name a mechanism for is not a claim.

## Repo layout

```
reference/     Ground truth every skill cites (platform standards, ADT MCP contract, SAP domain knowledge)
skills/        Claude Skills — the canonical, fullest version of each method
.github/       copilot-instructions.md (repo-wide) + prompts/*.prompt.md (Copilot slash prompts)
gemini/        Copy-paste prompt templates for Gemini Notebook (source-grounded analysis)
templates/     Shared output templates every tool fills in (FS, SDD, ADR, checklists, KM)
agents/        Claude Code subagent wrappers
docs/          setup-guide.md, coe-session-log.md, coe-topic-backlog.md
```

## Authoring rules

1. **`skills/<name>/SKILL.md` is canonical.** It holds the fullest version of the
   method, including multi-step drafting and live research/ADT use.
2. When you change a method: update the SKILL.md **first**, then bring its
   `.github/prompts/<name>.prompt.md` and `gemini/<name>.md` variants in line so
   all three tools apply the same logic. The README's "How the three tool
   variants relate" section explains the intended differences.
3. Skills reference templates and reference docs **by relative path**
   (`templates/functional-spec-template.md`, `reference/sap-project-standards.md`).
4. Skills **produce filled artifacts**, never a description of what the artifact
   should contain. Use `[CONFIRM]`, `[ASSUMPTION — confirm]`, `N/A` — never a
   blank field.
5. Keep a SKILL.md scannable (~40–70 lines). Push detail into templates and
   reference docs.
6. New skill → add it to the README structure list and the coverage table, and
   to `docs/setup-guide.md` if its install differs.
7. **Grow the domain reference files.** When an engagement teaches you a new
   fit-to-standard pattern, a config nuance, or an S/4 red flag, add it to the
   matching `reference/` file. That layer is the part of this repo that
   compounds — the skills only get better because it does. Never assert an SAP
   released CDS/BAdI/API technical name in a reference file without verifying it;
   classic config objects, tables and transactions are safe to state.

## Commit convention

```
<verb> <scope>: <what changed>

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```

Commit and push only when the user asks.
