# COE Session — Deck Authoring

Decks are written as **`.deck.md`** files and built into a real `.pptx` with
**speaker notes in the notes pane** by `tools/build_deck.py`. Write the markdown;
never hand-edit the generated pptx (it gets overwritten on rebuild).

```
docs/coe-sessions/decks/COE-S<nn>_<YYYY-MM-DD>_<topic-slug>.deck.md   ← you write this
docs/coe-sessions/decks/COE-S<nn>_<YYYY-MM-DD>_<topic-slug>.pptx      ← generated
```

## Build

```bash
pip install python-pptx          # once
python tools/build_deck.py docs/coe-sessions/decks/<deck>.deck.md
```

Output is 16:9, one `.pptx` with every slide's speaker notes populated.

## Format

````markdown
# <Deck title>

<!-- meta
session: 01
ppt_date_time: 2026-09-11 14:00 IST
presenter: Ramjee
subtitle: COE Session 01 · <one line>
-->

## <Slide title>
[TIME: 2:00]
- bullet, may use **bold** and `code`
- another bullet
  - sub-bullet (indent by two spaces)
NOTES:
Everything after NOTES: until the next `## ` becomes the speaker notes,
verbatim, blank lines preserved. Write what you will actually say.
````

- The **first** `## ` slide becomes the title slide (meta fills the subtitle line).
- `[TIME: m:ss]` is optional; it prints small in the top-right corner as a
  pacing cue for the presenter.
- `**bold**` and `` `code` `` render as real bold and monospace runs.
- Every slide is drawn with explicit geometry on a blank layout, so nothing
  inherits from a theme placeholder or overlaps.

## Diagrams

A slide can render its items as a **native, editable PowerPoint diagram**
instead of bullets — shapes you can still nudge by hand afterwards. Items take
the form `Label | detail`.

````markdown
## The Three Levels of AI Assistance
[TIME: 3:00]
DIAGRAM: ladder
- Level 1 — Ungrounded | Plain Copilot. Generic ABAP from training data.
- Level 2 — Instructed | + our instructions and prompt files.
- Level 3 — Grounded | + MCP server. Reads the real system.
CAPTION: The model does not get smarter between levels. We give it context.
NOTES:
...
````

| `DIAGRAM:` | Shape | Use for |
|---|---|---|
| `ladder` | Ascending steps with arrows, deepening colour | Progression, maturity levels, "good → better → best" |
| `flow` | Left-to-right boxes with arrows | A process or sequence of steps |
| `compare` | Side-by-side columns (last one accented) | Before/after, with/without, wrong/right |
| `cycle` | Boxes in a row plus a "repeat" return arrow | A loop |

- For `compare`, split the detail into bullet lines with **semicolons**:
  `Bare Copilot | Direct SELECT; Invented field names; Classic style`
- `CAPTION:` prints one bold line centred under the diagram — use it for the
  sentence you want the room to remember.
- Boxes size themselves to their text and fill the slide; long detail text is
  the only thing that will make them ugly, so keep it short.

**Use a diagram wherever the content is a progression, a comparison, or a
process.** A developer audience disengages from a wall of bullets. Aim for at
least three diagram slides in a 15-slide deck.

## Writing rules

- **12–16 slides** for 45–60 minutes. A demo *replaces* slides, it doesn't add them.
- **One takeaway per slide.** If a slide needs two, it's two slides.
- **Speaker notes are what you say, not what the slide shows.** Include the lines
  you want to land verbatim, the questions to ask the room, and the demo fallback.
- Every demo slide's notes must carry a **FALLBACK** line — what you do when the
  live demo fails.
- Include one **"screenshot this"** cheat-sheet slide. It is usually the highest-
  value artifact from the whole session.
- Close on the next session's teaser, verbatim.

## Standard shape (adapt, don't follow blindly)

| # | Slide | Time |
|---|---|---|
| 1 | Title | 0:30 |
| 2 | Why this, why now | 1:30 |
| 3 | What you'll be able to do (the objectives) | 1:00 |
| 4 | The concept in one picture — the frame everything hangs on | 3:00 |
| 5–7 | Core walkthrough, one idea per slide | 6:00 |
| 8–10 | **DEMO** slides — setup, the demo itself, the guardrail | 25:00 |
| 11 | Where it fails / when not to use it | 8:00 |
| 12 | The rules that don't change | 2:00 |
| 13 | What to do on Monday | 3:00 |
| 14 | Cheat sheet — "screenshot this one" | 1:00 |
| 15 | Discussion + next session | 5:00 |

## Dry-run checklist

- [ ] Ran the full demo end-to-end today, on the session system
- [ ] Recording / screenshots captured as fallback for **every** demo slide
- [ ] Sample data pre-loaded; the demo object is one the audience recognises
- [ ] Editor font size up, notifications off
- [ ] Deck rebuilt after the last content edit
- [ ] Cheat-sheet slide exported to PDF and linked in the session log

## Post-session

- [ ] Session log row updated: status, recording link
- [ ] Backlog re-ranked; next topic confirmed with its `ppt_date_time`
- [ ] Delivery notes and feedback captured in the session plan §9–§10
