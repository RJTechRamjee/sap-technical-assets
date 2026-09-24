---
name: 'ABAP Clean Core'
description: 'Clean ABAP and ABAP Cloud rules for classes and interfaces'
applyTo: '**/*.clas.abap,**/*.intf.abap'
---

# ABAP class standards

## ABAP Cloud compliance — these are blockers, not preferences

- No access to non-released SAP objects. No `SELECT` straight from an SAP
  application table — go through a released interface view.
- No obsolete statements: no `MOVE`, no `HEADER LINE`, no `OCCURS`, no
  `CALL FUNCTION` to a non-released function module.
- No `SY-SUBRC` checks after statements that cannot set it. Handle exceptions
  with `TRY ... CATCH`, typed exception classes only.

## Clean ABAP

- One method, one job. If it needs a comment to explain what it does, split it.
- Method names are verb phrases (`calculate_discount`), not nouns.
- Prefer `VALUE #( )`, `REDUCE`, `CORRESPONDING` and inline `DATA(...)` over
  declare-then-fill.
- No magic literals. Use constants, and name them for meaning not value.
- Public interface first: keep attributes private, expose behaviour.

## Testing

- New logic ships with ABAP Unit tests. Test doubles over system dependencies.
- A test that only asserts "no exception raised" is not a test.

## When unsure

Mark `[CONFIRM in ADT]` rather than inventing a table, field or API name. See
[`released-apis.md`](../../reference/released-apis.md).
