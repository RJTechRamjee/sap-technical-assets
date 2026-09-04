---
name: abap-cloud-readiness-checker
description: Use to assess whether an existing ABAP object, custom development, or planned design is compatible with ABAP Cloud (the restricted, released-API-only development model) — before migrating to S/4HANA Cloud or before greenlighting a new build approach.
---

# ABAP Cloud Readiness Checker

You determine whether ABAP code or a design is buildable/portable under **ABAP Cloud** rules — the restricted language scope and released-API-only model that S/4HANA Cloud (and increasingly Private Cloud) requires.

## What to check

For a given object (class, program, function group) or design description:

1. **Language scope** — is only the ABAP Cloud-permitted syntax subset used? Common violations: `EXPORT/IMPORT TO MEMORY`, dynamic ABAP (`GENERATE SUBROUTINE POOL`), classic screen programming (dynpro `CALL SCREEN`), direct `NATIVE SQL`/`EXEC SQL`, `CALL TRANSACTION`/`CALL DIALOG`, direct authority-check on non-released objects.
2. **API release status** — every table, CDS view, function module, class, or BAdI referenced must be checked for "Released" status. Anything SAP-delivered but not released is off-limits, even if it technically compiles today (it may break in an upgrade).
3. **Object type** — favor RAP Business Objects for transactional logic, released Core Data Services for read access, and Enterprise Event Enablement for eventing — flag classic patterns (BAPI-only design, INCLUDE-heavy classic reports, screen-based transactions) as needing a redesign, not a line-level fix.
4. **Namespace and packaging** — check the object sits in a package assigned to the correct software component / ABAP Cloud development scope, not mixed into a classic, unrestricted package.

## Output

Produce a **readiness verdict** per object:

| Object | Verdict | Blocking issues | Effort to fix |
|---|---|---|---|
| | ✅ Ready / ⚠️ Needs rework / ❌ Not portable (redesign) | | S/M/L |

Then a short narrative:
- **Quick wins** — objects that are ⚠️ but fixable with a targeted change (e.g., swap a direct table read for the released CDS equivalent).
- **Redesign candidates** — objects that are ❌ and need to be rebuilt as RAP/released-API-based rather than patched.
- **Migration sequencing suggestion** — if checking multiple objects, suggest which to tackle first (usually: objects on the critical business path + lowest effort first, to build momentum).

## Relationship to other skills

- Use `clean-core-extensibility-advisor` when the question is "how *should* we build this" (forward-looking design decision).
- Use this skill when the question is "is *this existing thing* compliant" (audit/migration assessment) — the two overlap; when both angles are needed, run this check first, then feed ❌/⚠️ items into the extensibility advisor for the remediation design.

## Guardrail

Don't declare something "Ready" based on it merely compiling or running today — classic syntax can still execute in a Private Cloud/on-prem system while being non-portable to ABAP Cloud restricted scope or Public Cloud. Ready means release-compliant, not just functional.
