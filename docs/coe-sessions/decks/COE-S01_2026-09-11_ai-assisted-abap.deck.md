# AI-Assisted ABAP With the Tools We Already Have

<!-- meta
session: 01
ppt_date_time: 2026-09-11 14:00 IST
presenter: Ramjee
subtitle: COE Session 01 · Copilot, Claude Code, and the ABAP MCP Server
-->

## AI-Assisted ABAP With the Tools We Already Have
[TIME: 0:30]
NOTES:
Open by naming the elephant: "We don't have a Joule licence. This session is not about Joule."

Then the turn: "We already own everything I'm going to show you today. Nothing here needs a purchase order."

Keep this slide to 30 seconds. The energy is in slide 2.

## Why This Session, Now
[TIME: 1:30]
- No Joule for Developers licence on this project — SAP's ABAP AI assistant is not available to us
- But every one of you already has **GitHub Copilot** in VS Code and Eclipse
- We have an **ABAP MCP server** configured that almost nobody uses
- Our `sap-technical-assets` repo has **repo-wide Copilot instructions and 11 prompt files** — written, committed, and unused
- The gap is not licensing. We are running level 1 tooling that goes to level 3.
NOTES:
The message: the constraint people assume (no licence) is not the real constraint.

Ask the room by show of hands — "who has changed a single Copilot setting since it was installed?" Expect almost no hands. That's the session in one gesture.

Be honest that the repo assets are unused. Don't blame anyone; nobody announced them. That's what today fixes.

Do NOT get drawn into a "when do we get Joule" discussion here. Park it: "licensing is a separate conversation I'm having; today is about what we have."

## What You'll Be Able to Do After This
[TIME: 1:00]
- Install our Copilot instructions and prompt files in **your own project repo**, and run `/rap-bo-scaffold` and `/abap-unit-test` end to end
- Explain and demonstrate why an **MCP-connected agent** answers differently from plain chat — and say when that difference matters
- Apply the **two guardrails** to any generated line: the released-API check still applies, and generated code is reviewed like hand-written code
NOTES:
Read these out. Say: "I'll check the first one at the end — I want to see it running on your machine, not in a follow-up email."

Setting that expectation now is what makes the adoption slide land later.

## The Three Levels of AI Assistance
[TIME: 3:00]
DIAGRAM: ladder
- Level 1 — Ungrounded | Plain Copilot, no configuration. Generic ABAP from its training data.
- Level 2 — Instructed | + repo-wide instructions and prompt files. Knows **our** platform, standards, naming, Clean Core rules.
- Level 3 — Grounded | + MCP server. Reads the **actual** objects, field lists and API release states from our system.
CAPTION: The model does not get smarter between levels. We give it context.
NOTES:
This is the spine of the whole session. Spend the full three minutes; everything after this hangs off it.

Draw it as three steps on a stair if you can. Level 1 is where the team is today. Level 2 is one file copy. Level 3 is one connection.

The line to land, slowly: "The model does not get smarter between levels. We give it context." Say it, pause, then move on.

If someone asks how this compares to Joule — Joule is essentially level 2 and 3 delivered by SAP, tuned on SAP's own ABAP model. We're assembling the same shape from tools we own.

## Level 1 — What You Get Today
[TIME: 2:00]
- Copilot with no instructions is working from public ABAP on the internet
- That corpus is overwhelmingly **classic, on-premise ABAP** — so that is what it writes
- It does not know: our release, ABAP Cloud restrictions, what is released in *our* system, our naming, our packages
- It will invent SAP table, field and BAPI names that look completely plausible
- This is not a criticism of the tool. It is a description of an unconfigured tool.
NOTES:
Be careful not to trash Copilot here — half the room uses it daily and likes it. The framing is "unconfigured", not "bad".

The invented-names point is the one that scares people appropriately. Give a concrete example if you have one from a real review.

## Level 2 — One File Copy
[TIME: 2:00]
- `.github/copilot-instructions.md` — repo-wide context Copilot Chat picks up for **every** chat in that repo
- Tells it: S/4HANA Cloud Private Edition 2025 · ABAP Cloud language version · released APIs only · Clean ABAP · our naming · RAP defaults
- `.github/prompts/*.prompt.md` — reusable prompts you invoke with `/name` on a selection
- Same model. Same question. Very different answer.
NOTES:
Show the actual file on screen for a few seconds — people trust what they've seen.

Emphasise that this is per-repo. It goes in *their* project repo, not just ours. That's the action item.

The prompt files are the underrated half — they encode a whole method, not just context. We'll see one in the demo.

## Level 3 — Grounding via the ABAP MCP Server
[TIME: 2:00]
- MCP = an open protocol for connecting an AI agent to real tools and data
- Our ABAP MCP server exposes the system: read object source, DDIC and CDS metadata, where-used, **API release state**, syntax check, ATC, ABAP Unit
- The agent stops guessing about our system and starts reading it
- Our rule: **reads are free, writes need explicit human confirmation** — no object creation, activation or transport without a yes
NOTES:
Don't go deep on the protocol. What matters is the behavioural difference: guessing versus reading.

State the safety rule clearly and early, because the next thing someone will worry about is an agent loose in the system. Reads free, writes gated. It's written up in reference/adt-mcp-usage.md.

## DEMO 1 — Same Ask, Two Results
[TIME: 10:00]
DIAGRAM: compare
- Bare Copilot | Direct `SELECT` on standard tables; Invented field names, stated confidently; Classic, pre-7.4 ABAP style; No layering, no metadata extension; No idea what our release allows
- + Instructions & `/cds-view-scaffold` | `ZI_` / `ZC_` layering; Released CDS as the data source; `@UI` moved to a metadata extension; Our naming and package conventions; `[CONFIRM in ADT]` where it doesn't know
CAPTION: Same model. Same question. We gave it our standards.
NOTES:
DEMO — 10 minutes.

Run the bare version first and read the output aloud, slowly. Point at the direct table access. Point at any invented field name. Let the room see it before you fix it.

Then the level 2 run. Put the two side by side on screen if you can.

The moment that matters is [CONFIRM in ADT] — where an unconfigured model invents, a configured one admits it doesn't know. Say that explicitly; it's the difference between a tool you can review and one you can't.

Closing line: "Same model. Same question. We gave it our standards."

FALLBACK: play the pre-recorded run. Model behaviour varies and the bare version is not reliably bad — that's exactly why we recorded it in the dry run.

## DEMO 2 — Grounding: Guessing vs Reading
[TIME: 10:00]
DIAGRAM: compare
- Without MCP | A plausible field list — that nobody can verify; "Yes, that's released" — on what basis?; Confident tone, no source; You cannot tell right from wrong by reading it
- With MCP connected | The real field list, read from the system; The actual API release state; Visible tool calls — you see it reach in; Multi-step: read object → syntax check → report
CAPTION: Level 2 stops it inventing our standards. Level 3 stops it inventing our system.
NOTES:
DEMO — 10 minutes. This is the centrepiece of the session.

Use a custom object the room recognises, so they can verify the field list themselves rather than taking it on trust. That verification is the whole point.

On the multi-step task, make the tool calls visible on screen. People need to see it reaching into the system, not producing text.

Closing line: "Level 2 stops it inventing our standards. Level 3 stops it inventing our system."

FALLBACK: recordings plus screenshots of the tool calls. Check the MCP connection an hour before the session — this demo does not degrade gracefully.

## DEMO 3 — The Guardrail
[TIME: 5:00]
- Ask for something that would consume a **non-released** object
- Look at the result — it looks fine. It compiles. Private Edition will accept it.
- Run `/clean-abap-review` on it → flagged 🔴
- **The tooling helps. The contract does not move.**
NOTES:
DEMO — 5 minutes. Short and pointed.

The important beat: the generated code looks fine. Nobody reading it casually would object. That's why the check exists and why review doesn't get easier just because a machine wrote it.

This is the hook into session 3, which is entirely about that check. Say so.

Closing line: "The tooling helps. The contract does not move."

## Where It Gets ABAP Wrong
[TIME: 8:00]
- **Invents SAP names that look right** — table, field, BAPI. Survives review by anyone who doesn't know the object.
- **Defaults to classic ABAP** — `SELECT` straight off `VBAK`, pre-7.4 syntax, dynpro-era thinking
- **No idea what's released in our system** — and Private Edition will happily compile the mistake
- **Confidently wrong on RAP save-sequence rules** — side effects in the wrong handler, `REPORTED` without `FAILED`
- **Writes tests that assert the implementation, not the rule** — they pass, and prove nothing
- **Knows nothing of our naming, packages or transports** unless we tell it
NOTES:
Eight minutes, and worth every one. This is where you earn developer trust — a session that only sells the tooling gets discounted.

Invite examples: "who has had it invent a field name?" Let two or three people tell their story. Their examples are more persuasive than mine.

Then close the loop: every single failure on this slide is an argument FOR level 2 and level 3, not against the tooling. The unconfigured tool fails this way. The configured, grounded one fails less.

The RAP bullet is a deliberate hook into session 2 — flag it.

## The Two Rules That Don't Change
[TIME: 2:00]
- **1. AI authorship is not compliance.** A generated `SELECT` on a non-released table is still a Clean Core violation. The released-API rules apply to every line regardless of who wrote it.
- **2. Generated code is reviewed exactly like hand-written code.** Same checklist, same severities — and **the author owns it**. "Copilot wrote it" is not a defence in review.
NOTES:
Slow down here. These two sentences are what I most want them to remember in six months.

Rule 2 matters culturally more than technically. The moment someone treats generated code as someone else's problem, quality falls off a cliff. Ownership does not transfer to the tool.

Say plainly: I will not accept "Copilot wrote it" in a review, and neither should you when you're reviewing each other.

## What to Do on Monday
[TIME: 3:00]
DIAGRAM: flow
- 1. Copy | `.github/copilot-instructions.md` into **your** project repo
- 2. Copy | `.github/prompts/*.prompt.md` into the same repo
- 3. Select | Highlight the code or spec text first — that's `${selection}`
- 4. Run | `/rap-bo-scaffold` · `/abap-unit-test` · `/clean-abap-review`
- 5. Connect | The ABAP MCP server, when system truth matters
CAPTION: Steps 1 and 2 take two minutes and are the biggest single win.
NOTES:
Three minutes, and make it concrete. Have the repo URL on screen.

If the meeting format allows, do the file copy live with them right now — two minutes of everyone doing it beats a week of it being homework. Adoption drops off a cliff the moment this becomes a to-do.

Name one person to try /abap-unit-test on a real class this week and report back at session 2. A named commitment beats a general encouragement.

## Cheat Sheet — Screenshot This One
[TIME: 1:00]
- **L1 Ungrounded** — plain Copilot. Invents SAP names, writes classic ABAP.
- **L2 Instructed** — copy `copilot-instructions.md` + `prompts/` into your repo. One file copy. Biggest single win.
- **L3 Grounded** — connect the ABAP MCP server. Real objects, real field lists, real API states.
- **Prompts:** `/rap-bo-scaffold` `/cds-view-scaffold` `/abap-unit-test` `/odata-service-expose` `/clean-abap-review` `/abap-cloud-readiness`
- **Rule 1:** AI authorship ≠ compliance. · **Rule 2:** Generated code is reviewed like hand-written. The author owns it.
NOTES:
Say "screenshot this one" out loud and then stop talking for five seconds so they actually do it.

This slide is the artefact that outlives the session. Export it to PDF and put the link in the session log.

## Discussion + Next Session
[TIME: 5:00]
- Where did Copilot last give you something **confidently wrong** in ABAP — and what would have caught it: the instructions, the MCP connection, or review?
- If an agent can read objects, run syntax checks and touch transport requests — what should it **never** do without a human approving it first?
- **Next: Session 02, 25 Sept — RAP managed Business Object end-to-end**
- *It will write you a determination where the rule should have been a validation. Session 2 is how you tell.*
NOTES:
Five minutes of discussion. If the room is quiet, name someone whose work you know touches this.

Question 2 is the one to protect time for — it's the start of our agent governance policy, and the answers should go into the follow-ups table in the session plan. This is genuinely undecided on the project; their input shapes it.

Close on the session 2 teaser verbatim: "It will write you a determination where the rule should have been a validation. Session 2 is how you tell."

Then: thank them, remind them of the file copy, end on time.
