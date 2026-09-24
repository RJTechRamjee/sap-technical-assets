---
name: 'RAP Behaviour Definitions'
description: 'Save-sequence and behaviour contract rules for RAP business objects'
applyTo: '**/*.asbdef,**/zbp_*.clas.abap'
---

# RAP behaviour definition standards

- Prefer **managed** with unmanaged save only where a legacy API genuinely
  requires it. State the reason in a comment if you go unmanaged.
- `strict ( 2 )` on every new behaviour definition. Do not downgrade it to make
  an activation error go away — fix the cause.
- Draft handling on anything a user edits interactively.

## The save sequence is a contract

- `validation` — read only. Never modify data in a validation. Report via
  `FAILED` and `REPORTED`.
- `determination` — may modify **its own** entity's fields. Declare the trigger
  fields honestly; an over-broad `on modify` trigger costs you on every save.
- `save` / `save_modified` — last resort for side effects that cannot be
  expressed as a determination.
- Never call `COMMIT WORK` inside a RAP handler. The framework owns the LUW.

## MAPPED / FAILED / REPORTED

- Fill `MAPPED` for every created key. A create that does not map its key will
  fail confusingly downstream.
- `FAILED` marks the instance as failed; `REPORTED` carries the message. Setting
  one without the other produces a silent failure or a message nobody sees.
- Messages come from a message class, not hardcoded strings.

## Naming

`ZR_*` base BO view, `ZC_*` projection, `ZBP_*` behaviour pool.
