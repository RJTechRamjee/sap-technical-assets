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
- Live ABAP system access is via the `adt-mcp` server — rules in
  **`reference/adt-mcp-usage.md`**: read freely, **write only with the user's
  explicit confirmation in the same turn**.

## Repo layout

```
reference/     Ground truth every skill cites (platform standards, ADT MCP contract)
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

## Commit convention

```
<verb> <scope>: <what changed>

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```

Commit and push only when the user asks.
