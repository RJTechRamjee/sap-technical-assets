# COE Biweekly Knowledge-Sharing Session

| Field | Value |
|---|---|
| Session # | 02 |
| Topic | RAP managed Business Object end-to-end for classic ABAP developers |
| Presenter | Ramjee |
| **`ppt_date_time`** | `2026-09-25 14:00 IST` `[CONFIRM — day/time slot not yet fixed]` |
| Duration | 60 min |
| Meeting link | `[CONFIRM]` |
| Deck file | `COE-S02_2026-09-25_rap-managed-bo.pptx` |
| Recording link | (fill after delivery) |
| Audience | ABAP developer community (offshore) |
| Status | Planned |
| Related SAP note / doc links | SAP Help — ABAP RESTful Application Programming Model (RAP) development guide, S/4HANA 2025 `[CONFIRM current link]` |
| Related repo assets | `skills/abap-object-generator/SKILL.md` (Mode 1), `skills/technical-design-writer/SKILL.md` §6, `reference/sap-project-standards.md` §5–§6 |

## 1. Why This Topic, Now

The greenfield build is ramping and RAP is the default for every new transactional
object, but most of the team's ABAP background is classic. The recurring findings
in recent code reviews are all RAP-shaped: business logic in the wrong handler,
side effects outside the save sequence, and results not returned through
`MAPPED`/`REPORTED`/`FAILED`. Teaching the model once is cheaper than catching it
per pull request.

**Direct hook from session 1:** we saw Joule generate RAP validations and
determinations in-context. That is only useful to a developer who can judge
whether the generated logic sits in the right place. It will happily write you a
determination where the rule should have been a validation — and it will look
fine. This session is how you tell.

## 2. Learning Objectives

By the end, attendees should be able to:

1. **Name every object in a RAP business object set** and say what each one is for
   — interface CDS view, projection view, metadata extension, behavior definition,
   behavior implementation class, service definition, service binding.
2. **Place a given business rule correctly** as a determination, a validation, or
   an action, and state its trigger (`on modify` vs `on save`) — given three rules
   from a real functional spec.
3. **Return results correctly** via `MAPPED` / `REPORTED` / `FAILED`, and list
   three things you must never do inside the save sequence.

## 3. Agenda (60 min)

| Time | Segment |
|---|---|
| 0–5 min | Why RAP, why now — where it shows up in our build |
| 5–25 min | The object set and the behavior model |
| 25–40 min | Live demo: a managed BO from an FS rule table |
| 40–50 min | Before/after from our own review findings + when NOT to use RAP |
| 50–58 min | Discussion: map it to your current work item |
| 58–60 min | Cheat sheet, links, next session |

## 4. Core Content Outline

**A. The object set — what you actually create (5 min)**
- `ZI_<Entity>` interface CDS view — the data model, associations, no UI annotations
- `ZC_<Entity>` projection view — what the service exposes
- `ZC_<Entity>` metadata extension (`.ddlx`) — all `@UI` lives here, not inline
- `ZI_<Entity>` behavior definition (`.bdef`) — the behavior contract
- `ZBP_I_<Entity>` behavior implementation class — the code
- `ZUI_<Entity>` service definition + `ZUI_<Entity>_O4` service binding — the OData V4 exposure
- Naming and the abapGit file layout: `reference/sap-project-standards.md` §5–§6

**B. Managed vs unmanaged (4 min)**
- **Managed** — RAP owns persistence. Our default.
- **Unmanaged** — you own persistence; only when the data is already owned elsewhere.
- **Managed with unmanaged save** — the middle ground; name the reason if you use it.
- `strict ( 2 )` on every new BDEF; draft-enabled for UI services, draft-disabled
  for API-only services.

**C. Where a business rule goes (8 min) — the core of the session**

| The rule sounds like… | It's a… | Trigger |
|---|---|---|
| "Field X must be filled / must be valid before saving" | **validation** | `on save` |
| "When the user changes A, derive B" | **determination** | `on modify` |
| "Set the status / calculate totals before the record is written" | **determination** | `on save` |
| "The user presses a button and something happens" | **action** | — |
| "Only show/allow this when the record is in state S" | **feature control** (static or instance) | — |

Teach it as a decision, not a list: *does the user trigger it, or does the data?*

**D. The save sequence and its contract (3 min)**
- Phases: finalize → check-before-save → save → (adjust numbers, cleanup)
- You may: read entities, modify your own entities, fill `MAPPED`/`REPORTED`/`FAILED`
- You must not: `COMMIT WORK`, call something that commits, modify another BO
  directly, write to global/static state, raise unhandled exceptions

**E. `MAPPED` / `REPORTED` / `FAILED` (3 min)**
- `MAPPED` — keys generated (e.g. late numbering) mapped back to the consumer
- `REPORTED` — messages the user should see, attached to the right entity/field
- `FAILED` — the instances that could not be processed
- The pattern: validations write to `FAILED` **and** `REPORTED`; a message with no
  `FAILED` entry lets a bad record through, and a `FAILED` with no message leaves
  the user staring at a blank error.

**F. Reading and writing — EML only (2 min)**
- `READ ENTITIES` / `MODIFY ENTITIES` inside behavior code
- Not `SELECT` on your own persistence, not direct DML

## 5. Demo Plan

- **Environment:** `[CONFIRM — DEV system + ADT]`
- **What we build:** a small managed, draft-enabled BO for a simplified billing
  request entity, driven by a three-rule table taken from a real TDD §6.
- **Steps:**
  1. Show the TDD §4 object inventory and §6 rule table — *the design comes first*
  2. Create the interface CDS view and projection view; move `@UI` into the metadata extension
  3. Generate the behavior definition; set `managed`, `strict ( 2 )`, `with draft`
  4. Generate the behavior pool with the ADT quick-fix — show what it stubs out
  5. Implement rule 1 as a **validation** — populate `FAILED` and `REPORTED` together
  6. Implement rule 2 as a **determination** `on modify`
  7. Implement rule 3 as an **action** with a result parameter
  8. Service definition + binding, publish, run the preview
  9. Deliberately break one rule — show what the user sees when `REPORTED` is filled
     but `FAILED` is not
- **Fallback if the live demo fails:** screen recording of steps 2–8 captured during
  the dry run, plus the finished source in the repo.

## 6. Discussion Questions

1. Take the work item you're on now — which of its rules are determinations,
   which are validations, and which are actions? Where are you unsure?
2. Where in our current codebase are we still wrapping a BAPI instead of building
   a managed BO, and is there a real reason?

## 7. Takeaways / Cheat Sheet

> **RAP managed BO — the one-slide version**
>
> **Object set:** `ZI_*` interface view → `ZC_*` projection → `ZC_*` metadata
> extension (all `@UI`) → `ZI_*` behavior definition → `ZBP_I_*` behavior pool →
> `ZUI_*` service definition → `ZUI_*_O4` service binding
>
> **Defaults:** `managed`, `strict ( 2 )`, draft for UI services, no draft for APIs
>
> **Where the rule goes:** user presses a button → **action** · data changes and
> something must be derived → **determination** (`on modify`) · must be true before
> save → **validation** (`on save`)
>
> **Always:** results via `MAPPED` / `REPORTED` / `FAILED` · a validation fills
> `FAILED` **and** `REPORTED` · read and write with EML (`READ`/`MODIFY ENTITIES`)
>
> **Never in the save sequence:** `COMMIT WORK` · modify another BO directly ·
> global or static state · unhandled exceptions · `SELECT` on your own persistence

## 8. References

- SAP Help — ABAP RESTful Application Programming Model, S/4HANA 2025 `[CONFIRM link]`
- `reference/sap-project-standards.md` §4 (language scope), §5 (naming), §6 (abapGit layout)
- `skills/abap-object-generator/SKILL.md` — Mode 1 generates this whole set
- `skills/abap-unit-test-writer/SKILL.md` — the test class for what we built (session 4 candidate)

## 9. Notes

**Prep notes** — content drawn from the repo's own standards and generator skill,
so the session doubles as an onboarding to those assets; call that out on slide 15.
Demo entity kept deliberately small: three rules, one child node at most. Do not
attempt draft *and* actions *and* a child node in one live demo.

**Delivery notes** — (fill after the session)

## 10. Feedback / Follow-ups Logged After Session

| Item | Raised by | Action | Owner | Status |
|---|---|---|---|---|

## 11. Next Session

| Field | Value |
|---|---|
| Proposed topic | Reading a released-API contract in ADT — what "Released" actually means |
| Proposed `ppt_date_time` | `2026-10-09 14:00 IST` `[CONFIRM]` |
| Why this next | You've just built a BO; session 3 makes sure everything it consumes is legal to consume. It also closes the loop on session 1's first governance rule — AI authorship is not compliance — by showing the check that proves it. |
