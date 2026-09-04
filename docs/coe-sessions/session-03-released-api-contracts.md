# COE Biweekly Knowledge-Sharing Session

| Field | Value |
|---|---|
| Session # | 03 |
| Topic | Reading a released-API contract in ADT — what "Released" actually means |
| Presenter | Ramjee |
| **`ppt_date_time`** | `2026-10-09 14:00 IST` `[CONFIRM — day/time slot not yet fixed]` |
| Duration | 45 min |
| Meeting link | `[CONFIRM]` |
| Deck file | `COE-S03_2026-10-09_released-api-contracts.pptx` |
| Recording link | (fill after delivery) |
| Audience | ABAP developer community (offshore) |
| Status | Planned |
| Related SAP note / doc links | SAP Business Accelerator Hub; SAP Help — ABAP Cloud / released objects for S/4HANA 2025 `[CONFIRM current links]` |
| Related repo assets | `reference/sap-project-standards.md` §4, §7 · `reference/adt-mcp-usage.md` · `skills/abap-cloud-readiness-checker/SKILL.md` · `skills/clean-core-extensibility-advisor/SKILL.md` |

## 1. Why This Topic, Now

We are on **Private Edition**, where classic ABAP still compiles. That is the trap:
the compiler will not stop a developer from consuming a non-released SAP object, so
the mistake reaches the transport, then the upgrade. Session 2 built a business
object; this session is about everything that object *consumes*. It is the cheapest
Clean Core control we have — a two-minute check in ADT before you write the `SELECT`.

**This also closes session 1's first governance rule.** AI assistants and agents
will suggest non-released objects — they generate what looks idiomatic, not what
our contract permits. This is the check that proves compliance regardless of who
or what wrote the line.

## 2. Learning Objectives

By the end, attendees should be able to:

1. **Determine the API state of any SAP object in ADT** and say plainly whether it
   may be used in ABAP Cloud code.
2. **Find the released successor** for a non-released object — or correctly
   conclude that none exists — using ADT and the Business Accelerator Hub.
3. **Record a Tier-4 exception properly** when no released alternative exists:
   justification, owner, ATC allowlist entry, remediation target.

## 3. Agenda (45 min)

| Time | Segment |
|---|---|
| 0–4 min | Why "it compiles" proves nothing in Private Edition |
| 4–16 min | What "Released" means, and where to look |
| 16–30 min | Live demo: three real objects from our code, checked end to end |
| 30–38 min | When there is no released alternative — the exception path |
| 38–43 min | Discussion: what's in our code today |
| 43–45 min | Cheat sheet, links, next session |

## 4. Core Content Outline

**A. The Private Edition trap (4 min)**
- Public Edition refuses to compile non-released usage. **Private Edition does not.**
- So compilation is not evidence of compliance. The only evidence is the object's
  release contract.
- What it costs when we get it wrong: the object can change or disappear on an
  upgrade, with no obligation on SAP to keep it stable — that's the whole point of
  a contract.

**B. What "Released" actually means (5 min)**
- A **release contract** is SAP's commitment about stability and permitted use.
  "The object exists" and "the object is released for my use" are different claims.
- API states you will see in ADT: **Released**, **Released with restrictions**,
  **Not released**, **Deprecated** (and a successor may be named).
- Release is **per use case** — an object can be released for one kind of
  consumption and not another. Read the restriction text, don't just look for green.
- Our rule (`reference/sap-project-standards.md` §4): new code uses released
  objects only, under language version *ABAP for Cloud Development*.

**C. Where to look — in order (5 min)**
1. **ADT** — open the object, check its properties / API state and any restriction.
2. **Released Objects** view in ADT / the released-objects app in the system.
3. **SAP Business Accelerator Hub** — for APIs and their contracts.
4. **ATC with the ABAP Cloud check variant** — catches what a human misses, at scale.
5. **ADT MCP** (when connected) — the same read, scriptable; see
   `reference/adt-mcp-usage.md`.

If an object can only be reached through SE11/SE80/SE37 with no released wrapper,
treat it as **not released** and move to the exception path.

**D. Finding the successor (2 min)**
- Deprecated objects usually name a successor — read it.
- For tables: look for the released CDS view that exposes the same data.
- For function modules: look for the released class, BAdI, or API.
- If you cannot find one after these steps, say so explicitly rather than assuming
  one exists — that conclusion is what unlocks the exception path.

**E. The exception path (Tier 4) (6 min)**
- Tier order recap: 0 config · 1 key-user · 2 developer ABAP Cloud · 3 side-by-side
  · **4 classic exception**.
- Tier 4 is *allowed* in Private Edition and *not* a normal build option. It needs:
  **justification**, a named **owner**, an **ATC allowlist entry**, and a
  **remediation target release**. All four, dated, in the ADR.
- No exception record = the finding stays a blocker in code review.

## 5. Demo Plan

- **Environment:** `[CONFIRM — DEV system + ADT; ATC ABAP Cloud variant available]`
- **What we show:** three objects taken from our own codebase — one clean, one
  deprecated-with-successor, one genuinely not released.
- **Steps:**
  1. Object 1 (clean): open in ADT, show the API state, show the restriction text,
     conclude "safe to use" out loud
  2. Object 2 (a table someone selected from directly): show it is not released,
     find the released CDS view that replaces it, rewrite the `SELECT` live
  3. Object 3 (no released alternative): show the search that proves it, then open
     `templates/clean-core-adr-template.md` and fill the exception row properly
  4. Run ATC with the ABAP Cloud variant over a small package; read the findings
     as a class, not one by one
  5. Show the same check via the ADT MCP if it is connected, as the scriptable version
- **Fallback:** screenshots of each ADT properties screen and the ATC result list,
  captured during the dry run.
- **Prep required:** pick the three real objects a week ahead and confirm their
  states, so nothing surprises you live. Anonymise if the code is client-sensitive.

## 6. Discussion Questions

1. In the object you last built or changed — can you name every SAP object it
   consumes, and do you know the state of each?
2. Do we have any Tier-4 usage in our code today with no exception record? Who
   owns finding out?

## 7. Takeaways / Cheat Sheet

> **Is this SAP object legal to use? — the 60-second check**
>
> 1. Open it in **ADT** → check **API state**: Released · Released with
>    restrictions · Not released · Deprecated
> 2. **Read the restriction text.** Release is per use case, not a green light.
> 3. Not released or deprecated? → find the **successor**: released CDS view for a
>    table, released class/BAdI/API for a function module
> 4. No successor after a real search? → **Tier-4 exception**, and it needs all four:
>    justification · owner · ATC allowlist entry · remediation target release
> 5. **Run ATC with the ABAP Cloud variant** before handover — every time
>
> **"It compiles in Private Edition" is not evidence of anything.**

## 8. References

- SAP Business Accelerator Hub — API contracts `[CONFIRM link]`
- SAP Help — released objects / ABAP Cloud development for S/4HANA 2025 `[CONFIRM link]`
- `reference/sap-project-standards.md` §4 (language & API rules), §7 (how to verify)
- `templates/clean-core-adr-template.md` — where the exception is recorded
- `skills/abap-cloud-readiness-checker/SKILL.md` — the same check, run over many objects

## 9. Notes

**Prep notes** — the whole session rests on the three demo objects being real and
from our code; pick them a week ahead and verify their states so nothing surprises
you live. Object 3 is the important one — the team needs to see that "no released
alternative exists" is a legitimate, documented conclusion, not a failure.
Keep to 45 min; this is a discipline session, not a deep dive.

**Delivery notes** — (fill after the session)

## 10. Feedback / Follow-ups Logged After Session

| Item | Raised by | Action | Owner | Status |
|---|---|---|---|---|

## 11. Next Session

| Field | Value |
|---|---|
| Proposed topic | Building an AI scenario into ABAP: the ABAP AI SDK powered by ISLM |
| Proposed `ppt_date_time` | `2026-10-23 14:00 IST` `[CONFIRM]` |
| Why this next | Sessions 1–3 were about AI helping us *write* ABAP. This flips it: calling an LLM *from* ABAP via SAP AI Core, which is in standard delivery on our PCE 2025 and viable now that BTP + AI Core entitlement is available. Demo: a working AI scenario in a Lead-to-Cash context (comm scenario `SAP_COM_0A69`). Alternative if setup isn't ready: "Diagnosing a pricing issue before writing a spec — the Pricing Analysis ladder." |
