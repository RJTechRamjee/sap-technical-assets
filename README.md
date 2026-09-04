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
  sap-project-standards.md              Platform, Clean Core dimensions, extensibility tiers, naming, released-API check, abapGit layout
  adt-mcp-usage.md                      adt-mcp contract: read freely, write only on explicit confirmation
  l2c-standard-process-reference.md     O2C process, config objects, determinations, billing relevance, output, master data
  pricing-condition-technique-reference.md  Condition technique in depth, pricing type, settlement management, the VOFM trap
  s4hana-simplification-redflags.md     ECC→S/4 deltas: the FS-review scan list
  fit-to-standard-patterns.md           48-pattern challenge catalog: ask → standard answer → question → when it's a real gap

skills/                    Claude Skills (source of truth — the fullest version of each method)
  requirement-workshop-facilitator/
  functional-spec-reviewer/      Review someone else's FS: fit-to-standard challenge, S/4 red flags, architect's solution position
  technical-design-writer/       The TDD — the architect's build-ready deliverable
  solution-architect/            SDD above FS level: process/app/integration/data architecture + extensibility register
  clean-core-extensibility-advisor/
  sap-innovation-radar/
  abap-object-generator/         Full abapGit-style RAP / CDS / OData / released-BAdI object sets
  abap-unit-test-writer/         RAP behavior + CDS + class test doubles, traced to FS rules
  clean-abap-code-reviewer/
  abap-cloud-readiness-checker/
  rfp-effort-estimator/          Technical build effort from an RFP: object breakdown, T-shirt sizing, roll-up, assumptions
  coe-session-planner/
  functional-spec-writer/        Secondary — only when you must draft/rewrite FS content yourself

.github/
  copilot-instructions.md  Repo-wide Copilot Chat instructions (copy into ABAP project repos)
  prompts/                 Copilot reusable prompt files (/prompt-name in Copilot Chat)

gemini/                    Copy-paste prompt templates for Gemini Notebook analysis

templates/                 Shared output templates every tool fills in
  workshop-notes-template.md
  fs-review-report.md            Architect's FS review + solution position
  technical-design-document.md   The TDD
  solution-design-document.md
  interface-spec-template.md
  clean-core-adr-template.md
  clean-abap-review-checklist.md
  effort-estimate-template.md
  km-session-template.md
  km-deck-outline.md
  functional-spec-template.md    (secondary — the functional consultant normally owns the FS)

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
| **Reviewing the functional consultant's FS** | `functional-spec-reviewer` |
| **Technical Design Document** (the architect's build deliverable) | `technical-design-writer` |
| Solution architecture above FS level | `solution-architect` (SDD, interface specs) |
| Clean Core architecture / extensibility | `clean-core-extensibility-advisor`, `sap-innovation-radar` |
| ABAP development (generate) | `abap-object-generator`, `abap-unit-test-writer` |
| Code quality / review | `clean-abap-code-reviewer`, `abap-cloud-readiness-checker` |
| RFP technical effort estimation | `rfp-effort-estimator` |
| COE lead / biweekly knowledge-sharing | `coe-session-planner` (uses `sap-innovation-radar`; pulls from `docs/coe-topic-backlog.md`) |

**The main chain** — the FS is written by the functional consultant; the
architect reviews it and owns the technical design:

```
requirement-workshop-facilitator
      ↓  (functional consultant writes the FS)
functional-spec-reviewer          ← challenge against standard, produce the solution position
      ↓
clean-core-extensibility-advisor  ← ADR, when the decision is non-trivial
      ↓
technical-design-writer           ← the TDD
      ↓
abap-object-generator → abap-unit-test-writer → clean-abap-code-reviewer
```

`solution-architect` sits above this when a whole workstream (not one requirement)
needs designing. `functional-spec-writer` is secondary — only when you must draft
FS content yourself.

## Domain knowledge layer

`reference/` is what makes the fit-to-standard challenge real rather than
generic. The skills don't restate SAP knowledge; they read it from:
`fit-to-standard-patterns.md` (48 requirement patterns → the standard answer →
the question to ask → when it's genuinely a gap), plus the process, pricing and
S/4-simplification references. **Extend these files after every engagement** —
they're the part of this repo that compounds.

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
