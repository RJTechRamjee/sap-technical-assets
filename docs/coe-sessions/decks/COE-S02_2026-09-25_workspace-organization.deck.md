# Organizing an ABAP Repo for GitHub Copilot

<!-- meta
session: 02
ppt_date_time: 2026-09-25 14:00 IST
presenter: Ramjee
subtitle: COE Session 02 · The .github folder, layer by layer — what goes where, and what fires when
-->

## Organizing an ABAP Repo for GitHub Copilot
[TIME: 0:30]
NOTES:
Open flat, no warm-up: "Session 1 ended with 'copy these files into your repo.' Nobody asked me the obvious follow-up question, which is: what *are* those files, and why that folder?"

Then: "Today is that question. By the end you'll be able to build the folder from an empty repo without looking anything up."

30 seconds. Move.

## Start With the Correction
[TIME: 2:30]
- Session 1 told you to install **eleven prompt files** — `/clean-abap-review`, `/rap-bo-scaffold`, the rest
- Re-checked against the docs this week, two things are true that weren't on that slide:
- **Prompt files have never been supported in Eclipse** — not in extension 0.14, not in any version back to 0.1
- **Prompt files are being retired** — deprecated for Agent Host, with automatic migration to agent skills turned on by default
- Even the frontmatter changed: the `mode:` key those files use is now `agent:`
NOTES:
Say this without flinching. The room will respect the correction far more than they'd respect a confident repeat of a stale slide.

The line to land: "I told you to invest in the one layer that doesn't run in the IDE you actually live in. That's on me — and it's the reason today is about the *whole* folder, not one file type."

Then immediately reframe so this doesn't become a downer: "The good news is the layer that *does* work in Eclipse got better while we weren't looking. Custom agents landed in the Eclipse extension in 0.13."

If someone asks "so was session 1 wasted?" — no. The instructions file is still the highest-value thing in the folder and it works everywhere. Only the prompt-file part shifted.

## What You'll Be Able to Do After This
[TIME: 1:00]
- Build the `.github/` folder from scratch in an empty ABAP repo — every file type, correct path, correct frontmatter
- Say which of the five layers fires **automatically**, which fires **on a glob match**, and which you have to **invoke by hand**
- Pick the right layer for a given rule, knowing which ones survive the trip into Eclipse/ADT
NOTES:
Read them straight, then set the expectation: "Point one I'm going to check. I want to see this folder in your repo, not in a follow-up mail."

This is a senior room — do not explain what Copilot is at any point today.

## Five Things You Can Put in `.github/`
[TIME: 3:00]
- **Rules** — `copilot-instructions.md`. One file, repo-wide. Fires on **every** request, no invocation
- **Scoped rules** — `instructions/*.instructions.md`. Fires when its **`applyTo` glob** matches the file you're working on
- **Agents** — `agents/*.agent.md`. A named persona with its own tool set. You **pick it** from the agent list
- **Skills** — `skills/<name>/SKILL.md`. A packaged capability the **model** decides to reach for
- **Prompts** — `prompts/*.prompt.md`. A `/slash-command` you **type**. The sunsetting one
NOTES:
This is the spine slide. Everything after it is one of these five in detail.

Make the invocation column the point, and say it as a sentence: "The difference between these five is not what they contain — it's who pulls the trigger. Nobody, a glob, you, or the model."

Don't rank them yet. The Eclipse ranking comes at the end, and it lands harder if they've seen all five on their own terms first.

## The Folder, Whole
[TIME: 5:00]
DIAGRAM: tree
- zl2c-billing-ext/
  - .github/
    - copilot-instructions.md | always on
    - instructions/
      - abap-clean-core.instructions.md | applyTo **/*.clas.abap
      - cds-views.instructions.md | applyTo **/*.asddls
      - rap-behaviour.instructions.md | applyTo **/*.asbdef
    - agents/
      - fs-reviewer.agent.md | pick from the agent list
      - tdd-writer.agent.md
    - skills/
      - pricing-review/
        - SKILL.md | model reaches for it
    - prompts/
      - clean-abap-review.prompt.md | /clean-abap-review
  - .vscode/
    - mcp.json | commit this one
  - reference/
    - released-apis.md | linked, not pasted
  - src/
    - zcl_bill_output.clas.abap
    - zi_billingdocitem_ext.ddls.asddls
    - zr_billingdoc.bdef.asbdef
NOTES:
Five minutes. This is the slide people will photograph, so stay on it and let them.

Walk it top to bottom, once, slowly. Then make three points:

One — everything Copilot-related is in `.github/`, with exactly one exception: `mcp.json` lives in `.vscode/`. Yes, that's inconsistent. Yes, you just have to know it.

Two — point at the `applyTo` annotations and the `src/` filenames together: the globs match the ADT/abapGit extensions. `.clas.abap`, `.asddls`, `.asbdef`. That's why a CDS rule can be written once and never fire on a class.

Three — `reference/released-apis.md` is not a Copilot file at all. It's ours. The instruction files *link* to it rather than copying it, so there's one copy of the truth. Come back to this on the conventions slide.

If asked about `AGENTS.md`: yes, it's read, same priority tier as `copilot-instructions.md` — it does not override it. For us `copilot-instructions.md` wins on Eclipse support.

## Layer 1 — The One File That Always Fires
[TIME: 3:30]
DIAGRAM: snippet
- # ABAP Cloud — zl2c-billing-ext
- Platform: S/4HANA Cloud Private Edition, release 2025. | no frontmatter
- Language version: ABAP for Cloud Development. | no applyTo
- Released APIs only. Never propose a core modification. | no invocation
- Naming: Z* objects in package ZL2C_BILLING.
- Behind any "standard SAP handles this" claim, name the
- config object, transaction or released API. Otherwise say
- you don't know.
CAPTION: `.github/copilot-instructions.md` — root of the repo, every request, every time.
NOTES:
Three and a half minutes.

Start with placement, because this is the most common failure: it must be `.github/copilot-instructions.md` at the **root** of the workspace. Not in a subfolder, not in `.vscode/`. Wrong path means silent no-op — no error, no warning, it just never loads.

No frontmatter. It's plain Markdown. That surprises people who've seen the other four types.

Then the content point, which is the actual lesson: this file is on **every single request**, so every line you add costs you on every request forever. Keep it to things that are true repo-wide. Release, language version, naming, the released-API rule. Anything artefact-specific belongs in the next layer.

Read the last rule out loud — "otherwise say you don't know." That one line does more to stop invented BAPI names than anything else in the folder.

## Layer 2 — Rules That Fire on a Glob
[TIME: 3:30]
DIAGRAM: snippet
- ---
- name: 'CDS View Standards'
- description: 'Conventions for CDS view entities' | now used for matching too
- applyTo: '**/*.asddls' | the trigger
- ---
- - Use DEFINE VIEW ENTITY, never DEFINE VIEW.
- - No client field in the projection list.
- - @EndUserText.label on every exposed element.
- - Follow [released-apis.md](../../reference/released-apis.md).
CAPTION: `.github/instructions/cds-views.instructions.md` — searched recursively, so subfolders are fine.
NOTES:
Three and a half minutes. This is the layer that pays off most for ABAP specifically, and almost nobody uses it.

Why ABAP specifically: our artefacts have clean, distinct extensions. A class, a CDS view and a behaviour definition carry genuinely different rules, and this is the only layer that lets you say so without bloating the always-on file.

`applyTo` takes a glob, relative to the workspace root. Comma-separate inside one string for several — `'**/*.clas.abap,**/*.abap'`. Use `'**'` to apply to everything, which is rarely what you want here.

Flag the change on the `description` line: matching is no longer glob-only. The agent can also select an instructions file by **semantically matching your description to the task**. So `description` is no longer decorative — write it like it will be read, because it will be.

Last line is the pattern to copy: a relative Markdown link out to our own reference doc. Don't paste the released-API list into five instruction files and then maintain five copies.

## Layer 3 — Agents: The One That Works in Eclipse
[TIME: 3:30]
DIAGRAM: snippet
- ---
- description: Review a functional spec like an architect. | shown in the picker
- name: FS Reviewer
- argument-hint: 'path to the FS'
- tools: ['search/codebase', 'web/fetch'] | its own tool set
- ---
- # FS review instructions
- Challenge every requirement against standard SAP first.
- Name the config object, transaction or released API —
- a claim you can't name a mechanism for is not a claim.
- Do not propose a build until fit-to-standard has failed.
CAPTION: `.github/agents/fs-reviewer.agent.md` — supported in the Eclipse extension since 0.13.0.
NOTES:
Three and a half minutes. Spend them — for this room this is the highest-value layer after the instructions file, because it's the only rich one that survives into Eclipse.

Name the rename explicitly: these were called **custom chat modes** until VS Code 1.106. Folder was `.github/chatmodes/`, extension was `.chatmode.md`. If you already have those files, they still work and are treated as custom agents automatically — the editor offers a quick fix to migrate. New ones: `.github/agents/*.agent.md`.

Worth saying out loud: that rename is exactly why this session exists. A deck written from memory six months ago would be teaching you a folder name that has moved.

The mental model: an instructions file changes *how* Copilot answers. An agent changes *who* is answering — persona plus a restricted tool set. Restricting tools is a feature, not a limitation: an FS reviewer that can't edit files can't quietly rewrite your spec.

Optional frontmatter worth knowing exists: `model` (accepts a prioritised array), `handoffs` to pass work to another agent, `user-invocable` and `disable-model-invocation` to control who can call it.

## Layer 4 — Skills
[TIME: 3:00]
- `.github/skills/<skill-name>/SKILL.md` — one **folder** per skill, not one file
- The folder is the point: bundle the method with the scripts, checklists and reference files it needs
- Invocation is neither automatic nor typed — the **model decides** to reach for it, based on what the skill says it's for
- This is where prompt files are being migrated to; the migration is on by default
- `[CONFIRM — check the current SKILL.md frontmatter fields against the docs before you author your first one]`
NOTES:
Three minutes, and be honest about the state of this one.

The shape is confirmed: a folder per skill, `SKILL.md` inside, siblings alongside it. That folder-not-file structure is the real difference from every other layer — a skill can carry a checklist file and a script and reference the same way our repo's reference docs work.

Say the `[CONFIRM]` line rather than skipping past it: "I'm not going to put frontmatter fields on a slide that I haven't checked this week. Check them when you write one." That is the habit this session is selling, so model it rather than describing it.

Practical guidance for Monday: skills are not supported in Eclipse yet. Don't start here.

## Layer 5 — Prompt Files, and Why They're Last
[TIME: 2:30]
DIAGRAM: snippet
- ---
- agent: 'agent' | was `mode:` until recently
- description: 'Review ABAP against Clean ABAP + ABAP Cloud.'
- argument-hint: 'class name (optional)'
- ---
- Review the selection using the checklist in
- [clean-abap.md](../../reference/clean-abap.md).
- ${selection}
CAPTION: `clean-abap-review.prompt.md` → `/clean-abap-review`. Filename is the command.
NOTES:
Two and a half minutes — deliberately the shortest of the five, and say why.

The mechanic is genuinely elegant, so show it: filename becomes the slash command, no registration step. `clean-abap-review.prompt.md` gives you `/clean-abap-review`. Arguments come straight off the chat line.

Then the caveats, plainly: `mode:` became `agent:`. `${selection}` still works but the full variables table has been pulled from the docs, so don't build anything clever on `${file}` or `${workspaceFolder}` — use `${input:name:placeholder}` if you need to ask for something.

And the reason it's last: deprecated for Agent Host, auto-migrating to skills, and never supported in Eclipse at any version. For a room that lives in ADT, this is close to a non-feature.

Don't delete the eleven we already have — they work in VS Code today. Just don't write your twelfth.

## How the Layers Compose on One Request
[TIME: 3:00]
DIAGRAM: flow
- 1. Always on | `copilot-instructions.md` loads. Every request. No exceptions.
- 2. Glob match | Any `instructions/` file whose `applyTo` matches the open file.
- 3. What you picked | An agent, a skill the model reached for, or a `/prompt` you typed.
- 4. Your context | The selection, the files you attached, the question itself.
CAPTION: Four layers on one request. You only typed one of them.
NOTES:
Three minutes. This is the slide that makes the folder make sense as a system rather than five unrelated file types.

Walk it left to right once, then land the caption: "You only typed one of them."

The diagnostic value is the real payoff — when an answer comes back wrong, this flow tells you where to look. Wrong platform assumptions, wrong release? Layer 1. Right for classes, wrong for CDS? Layer 2, check the glob. Right rules but the wrong job entirely? Layer 3, wrong agent selected.

If someone asks about conflicts between layers: all of them get provided to the model, and no ordering is guaranteed between multiple instruction files. So don't build rules that depend on one contradicting another — make them non-overlapping.

## DEMO — Build the Folder from Nothing
[TIME: 8:00]
- Empty ABAP repo, no `.github/` at all — baseline answer to an ABAP Cloud question
- Add `copilot-instructions.md`, ask again — same model, same question
- Add `cds-views.instructions.md` with `applyTo: '**/*.asddls'`, open a CDS view, ask again
- Add an agent, select it, ask a third time
NOTES:
DEMO — 8 minutes. This is the centrepiece. Everything before it was a diagram of this.

Build it live, in order, one file at a time. The point is cumulative: each file visibly changes the answer to a question that never changes.

Pick the ABAP question in advance and keep it fixed all the way through. Something with an obvious ECC-vs-Cloud trap in it so the baseline answer is visibly wrong — that contrast is what sells layer 1 in ten seconds.

On the CDS step, do this deliberately: ask with a class open, then with the CDS view open, same question. Same repo, different file, different rules fire. That's `applyTo` demonstrated rather than described.

Narrate the paths as you type them. People need to see `.github/instructions/` typed out to believe it isn't `.vscode/`.

FALLBACK: screen recording of all four steps from the dry run, plus the four answers side by side as a static slide if even the recording fails.

## What Actually Fires in Eclipse
[TIME: 4:00]
DIAGRAM: compare
- VS Code only — not in Eclipse | Prompt files — never supported, any version; Agent skills — not supported; Copilot code review, checkpoints — not supported
- Works in Eclipse today | `copilot-instructions.md` — chat **and** agent mode (Preview); Custom agents — supported since extension 0.13.0; Chat, agent mode, MCP — full support; `instructions/` and `AGENTS.md` — **agent mode only, not plain chat**
CAPTION: Verified 2026-09-16 against GitHub's feature matrix, Eclipse extension 0.14.0. Preview rows change.
NOTES:
Four minutes. For this room this is the most consequential slide in the deck.

The line that matters most is buried in the left column, so pull it out and say it twice: **scoped instruction files work in Eclipse agent mode, but not in plain Copilot Chat.** So if you ask a quick question in the chat panel in ADT, your `applyTo` rules did not load. Only `copilot-instructions.md` did.

The practical consequence, and this is the takeaway: **put the load-bearing rules in `copilot-instructions.md`.** Use scoped files for refinement, not for anything you can't afford to lose.

Then the discipline point, which is the whole reason this slide has a date on it: "Custom agents were ✗ in Eclipse at 0.12 and ✓ at 0.13. That flipped between two extension releases. Whatever you remember about this table is probably already wrong — check your own installed extension version."

## Conventions That Keep This Maintainable
[TIME: 2:30]
- **One file, one concern.** A CDS rule that also covers classes will fire on the wrong artefact and slowly get ignored
- **Keep layer 1 short.** It rides along on every request — length there is a permanent tax, not a one-off
- **Write `description` like it matters** — it's used for semantic matching now, not just hover text
- **Link, don't paste.** Relative Markdown links from instruction and prompt files into `reference/` — one copy of the truth
- **Match globs to ADT extensions** — `.clas.abap`, `.asddls`, `.asbdef` — not to folder names you invented
NOTES:
Two and a half minutes. These are the things that decide whether the folder still works in six months or quietly rots.

The "link, don't paste" one is worth dwelling on for this audience. Our released-API rules and platform standards change. If they're pasted into five instruction files, four of them are wrong within a quarter and nobody notices. One reference file, linked from everywhere, changes in one place.

If there's a question about how big `copilot-instructions.md` should be — no official number, but the honest answer is: if you can't read it aloud in under a minute, it's doing too much and layer 2 wants some of it.

## Do This Monday
[TIME: 2:30]
- **1.** Create `.github/copilot-instructions.md` in your project repo — platform, release, language version, naming, the released-API rule
- **2.** Add two or three `instructions/*.instructions.md` with `applyTo` globs per artefact type
- **3.** Add one `agents/*.agent.md` for a job you do repeatedly — this is the only rich layer that runs in Eclipse
- **4.** Skills and prompts only if your team actually works in VS Code — and check the docs before you author either
- **Starter repo:** `examples/zl2c-billing-ext/` — every file from the tree slide, working. Copy it, swap in your `src/`
NOTES:
Two and a half minutes, and the order is the message: it's ranked by what survives into the IDE you actually use, not by what's newest.

Steps 1 to 3 are genuinely a lunch break's work. Say that — the barrier here is not effort, it's that nobody has told anyone what the files are, which is what today fixed.

Point at the starter repo line and say it plainly: "The folder from slide 5 is real and you can have it. It is the same repo I demo from. Clone it, delete my `src/`, put yours in, edit the rules." Share the link in the chat while you're saying it, not afterwards.

Commit to the follow-up out loud: "I'll ask in two weeks who has a `.github/` folder. Bring your tree to the next session."

## Cheat Sheet — Screenshot This One
[TIME: 1:00]
- `copilot-instructions.md` — **always on** · Eclipse ✅ chat + agent · keep it short
- `instructions/*.instructions.md` — **`applyTo` glob** · Eclipse 🟡 agent mode only
- `agents/*.agent.md` — **you pick it** · Eclipse ✅ since 0.13.0 · was `chatmodes/*.chatmode.md`
- `skills/<name>/SKILL.md` — **model picks it** · Eclipse 🔴 · a folder, not a file
- `prompts/*.prompt.md` — **you type `/name`** · Eclipse 🔴 never · deprecated, migrating to skills
- `.vscode/mcp.json` — the one file that isn't in `.github/` · commit it
NOTES:
Say "screenshot this one", then stop talking for five seconds and let the phones come up.

Export this slide to PDF after the session and link it in the session log.

## Discussion + Next Session
[TIME: 5:00]
- Which rule do you currently repeat in chat every single day? That's your layer 1 line — what is it?
- Which of your recurring jobs deserves an agent, given agents are the rich layer that works in ADT?
- **Next: RAP managed Business Object end-to-end** — the original session-2 promise, restored
NOTES:
Five minutes. Question one is designed to produce actual content — collect the answers, they seed a shared starter `copilot-instructions.md` for the team.

Close verbatim: "Session 1 was which tools we have. Today was where the files live and what pulls the trigger on each one. Next time we stop configuring and build — a full RAP managed business object, end to end."

Thank them, remind them about the screenshot, end on time.
