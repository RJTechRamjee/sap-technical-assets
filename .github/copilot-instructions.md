<!--
HOW TO USE THIS FILE
This file is written to live at the root of an ABAP development repo (or your
Eclipse/ADT-linked project mirror) as `.github/copilot-instructions.md`, where
GitHub Copilot Chat in VS Code (and Eclipse via the Copilot extension, where
supported) picks it up automatically as persistent context for every chat.
Copy this file into each ABAP project repo you work in. Keep one canonical
copy here in sap-technical-assets and re-copy when it changes.
-->

# Copilot Instructions — SAP ABAP / S/4HANA Cloud (Lead-to-Cash, SD, Invoicing)

You are assisting an SAP ABAP developer/architect working on an S/4HANA Cloud
transformation and greenfield implementation, focused on Lead-to-Cash, SD,
and Invoicing. Follow these rules for every suggestion and chat response.

Target platform unless told otherwise: **S/4HANA Cloud Private Edition, release
S/4HANA 2025**, built with **ABAP Cloud** (language version *ABAP for Cloud
Development*). Full standards — extensibility tiers, naming, released-API rules,
abapGit object layout — are in `sap-technical-assets/reference/sap-project-standards.md`.

## Non-negotiable: Clean Core

- Never suggest code that accesses a non-released SAP table, function
  module, class, or BAdI directly. Always check for a released API/CDS
  equivalent first, and say so if you're substituting one.
- Never suggest modifying SAP standard objects or using classic user-exits
  when a released BAdI, RAP extension point, or in-app extensibility tool
  (Custom Fields and Logic, Custom CDS Views) exists.
- Default to ABAP Cloud-restricted syntax: no `EXPORT/IMPORT TO MEMORY`,
  no dynamic subroutine pools, no classic dynpro (`CALL SCREEN`), no
  `NATIVE SQL`. If the target system is confirmed Private Cloud/on-prem
  and classic syntax is explicitly requested, it's allowed but call out
  that it is not ABAP Cloud / Public Cloud portable.
- Prefer RAP (RESTful Application Programming Model) for new transactional
  logic: managed or unmanaged Business Objects, proper `VALIDATE` /
  `DETERMINE` / save-sequence contract, `MAPPED`/`REPORTED`/`FAILED` used
  correctly — not classic BAPI wrappers unless there's a stated reason.

## Clean ABAP style (apply automatically, don't wait to be asked)

- Meaningful names — no `lv_x`, `ls_data`, single-letter variables outside
  a trivial loop scope.
- Small methods that do one thing. Extract instead of nesting past 2-3
  `IF` levels; prefer early `RETURN`.
- Use functional/constructor expressions (`VALUE`, `COND`, `SWITCH`, `NEW`)
  over verbose classic statement sequences where it improves readability.
- No `SELECT` inside a `LOOP` — use `FOR ALL ENTRIES`, a `JOIN`, or a CDS
  association instead.
- Real exception handling with a proper exception class hierarchy, not
  silent `sy-subrc` swallowing.
- Suggest ABAP Unit tests for new business logic; keep business logic
  separated from direct database access so it's testable.

## Domain context to assume unless told otherwise

- Process area is Lead-to-Cash / SD / Invoicing: sales order → delivery →
  billing → payment, condition technique for pricing, billing document
  types, credit management, output determination (BRFplus-based in
  S/4HANA Cloud, not classic NACE exits).
- When a pricing/output/billing requirement comes up, check for a standard
  config or released BAdI/extensibility fit before generating custom
  developer code.
- Target release is S/4HANA Cloud Private Edition, S/4HANA 2025. Classic ABAP
  is technically possible here but is a documented exception (Tier 4 in
  `reference/sap-project-standards.md` §3), never a default. If a repo is
  confirmed Public Edition, treat classic as unavailable entirely.

## When generating a new object (not just a snippet)

- Prefer producing the **full object set** in abapGit layout, each block headed
  by a comment with object name, type, and the FS/requirement ID — per
  `sap-technical-assets/skills/abap-object-generator/SKILL.md`.
- RAP BO default: `managed`, `strict ( 2 )`, `with draft` for UI services,
  behavior impl class `ZBP_I_<Entity>`, one method per determination/validation/
  action traced to a numbered business rule; results only via
  `MAPPED`/`REPORTED`/`FAILED`.
- CDS: interface view `ZI_*` (no `@UI`), projection `ZC_*`, `@UI` in a separate
  metadata extension, `@AccessControl.authorizationCheck` set, DCL when
  row-level auth applies.
- Naming follows `reference/sap-project-standards.md` §5. Don't invent SAP field
  or table names — write `[CONFIRM in ADT]`.
- Every new object must compile under *ABAP for Cloud Development* and use
  released APIs only; end with a "verify before activation" list of the released
  dependencies used.
- Offer an ABAP Unit test class (see the `abap-unit-test` prompt) for any new
  business logic — don't consider generation done without it.

## When reviewing code (not just generating it)

Apply the same checklist as `templates/clean-abap-review-checklist.md` in
the sap-technical-assets repo: flag Clean Core/ABAP Cloud violations as
blockers first, then language-rule, error-handling, performance, and
testability issues, each with a concrete suggested fix — not just a
comment that something is wrong.

## What NOT to do

- Don't invent SAP standard field names, table names, or BAPI signatures —
  if unsure, say so and suggest how to verify (ADT "Where Used", API Hub)
  rather than guessing a plausible-looking name.
- Don't suggest hardcoding business-relevant values that belong in
  customizing or constants.
- Don't silently pick classic extensibility as a shortcut because it's
  simpler to generate — always name it as a Clean Core exception if used.
