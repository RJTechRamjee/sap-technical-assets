# SAP Technical Assets

Personal library of skills, prompts, and templates for Ramjee's SAP ABAP
architect work — Lead-to-Cash / SD / Invoicing solution design, Clean Core
architecture review, ABAP code quality, and the biweekly ABAP developer COE
knowledge-sharing program. Written once per topic, packaged for three tools:
**Claude** (Desktop + Code), **GitHub Copilot** (VS Code/Eclipse), and
**Gemini Notebook**.

See `docs/setup-guide.md` for install steps per tool. `CLAUDE.md` holds the
authoring rules for this repo; `reference/` holds the platform ground truth every
skill cites (default: **S/4HANA Cloud Private Edition, S/4HANA 2025, ABAP Cloud
first**).

## Structure

```
CLAUDE.md                  How to author/update assets here; default platform assumptions

reference/                 Ground truth every skill cites (don't restate it in skills)
  sap-project-standards.md   Platform, Clean Core dimensions, 3-tier extensibility, naming, released-API check, abapGit layout
  adt-mcp-usage.md           adt-mcp contract: read freely, write only on explicit confirmation

skills/                    Claude Skills (source of truth — the fullest version of each method)
  requirement-workshop-facilitator/
  solution-architect/            SDD above FS level: process/app/integration/data architecture + extensibility register
  functional-spec-writer/
  clean-core-extensibility-advisor/
  sap-innovation-radar/
  abap-object-generator/         Full abapGit-style RAP / CDS / OData / released-BAdI object sets
  abap-unit-test-writer/         RAP behavior + CDS + class test doubles, traced to FS rules
  clean-abap-code-reviewer/
  abap-cloud-readiness-checker/
  rfp-effort-estimator/          Technical build effort from an RFP: object breakdown, T-shirt sizing, roll-up, assumptions
  coe-session-planner/

.github/
  copilot-instructions.md  Repo-wide Copilot Chat instructions (copy into ABAP project repos)
  prompts/                 Copilot reusable prompt files (/prompt-name in Copilot Chat)

gemini/                    Copy-paste prompt templates for Gemini Notebook analysis

templates/                 Shared output templates every tool fills in
  functional-spec-template.md
  solution-design-document.md
  interface-spec-template.md
  workshop-notes-template.md
  clean-core-adr-template.md
  clean-abap-review-checklist.md
  effort-estimate-template.md
  km-session-template.md
  km-deck-outline.md

agents/                    Optional Claude Code subagent wrapper(s)

docs/
  setup-guide.md            How to install/use each tool's variant
  coe-session-log.md         Running history of KM sessions (append via coe-session-planner)
  coe-topic-backlog.md       Ranked backlog the session planner pulls from
```

## Coverage by responsibility

| Responsibility | Skill(s) |
|---|---|
| Requirement workshops | `requirement-workshop-facilitator` |
| Solution design & architecture | `solution-architect` (SDD, interface specs), `functional-spec-writer` |
| Clean Core architecture / extensibility | `clean-core-extensibility-advisor`, `sap-innovation-radar` |
| ABAP development (generate) | `abap-object-generator`, `abap-unit-test-writer` |
| Code quality / review | `clean-abap-code-reviewer`, `abap-cloud-readiness-checker` |
| RFP technical effort estimation | `rfp-effort-estimator` |
| COE lead / biweekly knowledge-sharing | `coe-session-planner` (uses `sap-innovation-radar`; pulls from `docs/coe-topic-backlog.md`) |

Typical chain: `requirement-workshop-facilitator` → `solution-architect` →
`functional-spec-writer` → `clean-core-extensibility-advisor` (ADR) →
`abap-object-generator` → `abap-unit-test-writer` → `clean-abap-code-reviewer`.

## How the three tool variants relate

Each `skills/<name>/SKILL.md` is the **canonical method** — the fullest
version of "how to do this well." The matching file under `.github/prompts/`
and `gemini/` is a condensed variant of the *same* method, adapted to what
each tool can actually do:

- **Claude** runs the full SKILL.md, including live web research
  (`sap-innovation-radar`, `coe-session-planner`) and multi-step drafting.
- **Copilot** prompt files are single-shot instructions triggered on
  selected code/text in VS Code — best for the code-facing skills
  (`clean-abap-review`, `abap-cloud-readiness`) and quick drafting.
- **Gemini Notebook** templates assume you've uploaded source documents
  (transcripts, FS drafts, release notes) and ask Gemini to analyze
  *those sources* specifically, rather than answer from general knowledge.

If you change a method, update the SKILL.md first, then bring the Copilot
and Gemini variants in line so all three stay consistent.

## Updating this repo

```bash
git add -A
git commit -m "describe the change"
git push
```
