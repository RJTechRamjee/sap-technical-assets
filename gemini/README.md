# Gemini Notebook Prompt Templates

Gemini Notebook doesn't have a skill/plugin system like Claude or a prompt-file system like Copilot — these are **copy-paste prompt templates**. Typical use: upload your source documents (workshop transcripts, FS drafts, SAP release notes, code exports) as sources in a Notebook, then paste the matching template as your query so Gemini analyzes *those specific sources* against a consistent lens instead of a generic answer.

Each template:
- States the role/lens explicitly (so answers stay grounded to this project's context — L2C/SD/Invoicing, Clean Core, ABAP Cloud).
- Ends with `Sources: <list the documents you uploaded>` — fill this in so Gemini grounds its answer in the notebook's sources rather than general knowledge.
- Mirrors the corresponding Claude skill / Copilot prompt in `../skills/` and `../.github/prompts/`, so the same underlying method is applied consistently across all three tools.

| Template | Mirrors | Use for |
|---|---|---|
| `solution-design-analysis.md` | `requirement-workshop-facilitator` | Analyzing workshop transcripts/notes for structured requirements |
| `functional-spec-review.md` | `functional-spec-writer` | Reviewing/critiquing a drafted FS before sign-off |
| `clean-core-architecture-review.md` | `clean-core-extensibility-advisor` | Extensibility decision support, ADR drafting |
| `code-quality-review.md` | `clean-abap-code-reviewer` | Pasted-code review when away from the IDE |
| `coe-topic-research.md` | `sap-innovation-radar` + `coe-session-planner` | Researching a KM session topic against uploaded SAP docs |
