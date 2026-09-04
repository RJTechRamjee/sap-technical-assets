# COE Session — Deck Outline

> Slide-by-slide outline for a 45–60 min session. Fill after the
> `km-session-template.md` content is drafted. One row = one slide. Keep it to
> 12–16 slides; a demo replaces slides, it doesn't add them.
>
> The **Speaker notes** column is written to be pasted straight into the PowerPoint
> notes pane — write what you will actually say, not a description of the slide.

## Header

| Field | Value |
|---|---|
| Session # | |
| Topic | |
| Presenter | |
| **`ppt_date_time`** | `YYYY-MM-DD HH:MM` + timezone |
| Duration | 45 / 60 min |
| Deck file | `COE-S<nn>_<YYYY-MM-DD>_<topic-slug>.pptx` |
| Status | Outline / Deck built / Dry-run done / Delivered |

## Slides

| # | Slide title | Key visual / on-slide content | Speaker notes (→ PPT notes pane) | Time |
|---|---|---|---|---|
| 1 | Title | Topic, date, presenter | — | 0:30 |
| 2 | Why this, why now | The trigger: release feature / review finding / decision pending | Anchor it to our project, not SAP theory | 1:30 |
| 3 | What you'll be able to do after this | The 3 learning objectives, verbatim | Set the bar; tell them you'll check at the end | 1:00 |
| 4 | The concept in one picture | Single diagram of the whole idea | The mental model everything else hangs on — spend time here | 2:00 |
| 5–8 | Core walkthrough | One idea per slide, building on slide 4's diagram | Keep each slide to one takeaway | 12:00 |
| 9 | Demo setup | What system, what we'll build/show, what "done" looks like | Say the fallback if it breaks | 1:00 |
| 10 | DEMO | (live) — steps listed in `km-session-template.md` §5 | Narrate the *why* of each step, not the clicks | 12:00 |
| 11 | Before / after on our code | A real (anonymized) example from our repo or reviews | Make it concrete to this team | 2:00 |
| 12 | When NOT to use this | The boundaries / anti-patterns | Prevents cargo-culting | 1:30 |
| 13 | Cheat sheet | The screenshot-and-keep slide | Read it aloud once; tell them to screenshot it | 1:00 |
| 14 | How this applies to your current work item | 2 discussion prompts | Open the floor — name someone to start if it's quiet | 6:00 |
| 15 | Links + next session teaser | SAP notes/docs, repo paths, next topic + `ppt_date_time` | — | 1:00 |

## Demo dry-run checklist

- [ ] Ran the full demo end-to-end today, on the session system
- [ ] Recording / screenshots captured as fallback
- [ ] Sample data pre-loaded
- [ ] Editor font size up, notifications off
- [ ] Cheat sheet exported to PDF and linked in the log

## Notes

**Build notes** — where each slide's content came from, anything to reuse next time.

**Dry-run notes** — timing per section, what needs cutting.

## Post-session

- [ ] Row appended to `docs/coe-session-log.md` with `ppt_date_time`, deck file and materials link
- [ ] Backlog re-ranked; next topic confirmed with its `ppt_date_time`
- [ ] Delivery notes and feedback captured in `km-session-template.md` §9–§10
