# ABAP Cloud — zl2c-billing-ext

Repo-wide context for GitHub Copilot. Loaded automatically on every chat request
in this workspace. No frontmatter, no `applyTo`, no invocation.

Keep this file short. Every line here rides along on every request forever —
anything artefact-specific belongs in `.github/instructions/` instead.

## Platform

- Target: **SAP S/4HANA Cloud Private Edition**, release **S/4HANA 2025**.
- Language version: **ABAP for Cloud Development**. Not standard ABAP.
- This is a greenfield extension project. There is no ECC-era custom code to
  stay compatible with.

## Non-negotiable rules

- **Released APIs only.** Do not read or call an SAP object unless it is
  released for cloud development. If you are not certain an object is released,
  say so instead of guessing.
- **Never propose a core modification**, an implicit enhancement, or an access
  key. If a requirement seems to need one, say the requirement needs rework.
- **Name the mechanism.** Never write "standard SAP handles this" without naming
  the config object, transaction or released API that does it. A claim you
  cannot name a mechanism for is not a claim — say you don't know.
- **Do not invent technical names.** SAP table, field, BAdI and CDS view names
  that "look plausible" are the single most common failure here. If you need a
  name you are not sure of, mark it `[CONFIRM in ADT]` and move on.

## Conventions

- Custom objects are `Z*`, in package `ZL2C_BILLING`.
- Fit-to-standard first: configuration, then a released extension point, then a
  side-by-side app. A custom build is the last option, not the first.
- Follow Clean ABAP. Short methods, meaningful names, no obsolete statements.
- Project ground truth lives in [`reference/released-apis.md`](../reference/released-apis.md).
