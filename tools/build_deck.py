#!/usr/bin/env python3
"""Build a .pptx (with speaker notes in the notes pane) from a deck markdown file.

Usage:
    python tools/build_deck.py docs/coe-sessions/decks/<deck>.deck.md
    python tools/build_deck.py <deck>.deck.md -o /some/path/out.pptx

Deck markdown format
--------------------
    # <deck title>

    <!-- meta
    session: 01
    ppt_date_time: 2026-09-11 14:00 IST
    presenter: Ramjee
    subtitle: optional subtitle for the title slide
    -->

    ## <slide 1 title>
    [TIME: 1:30]
    - bullet
    - bullet
      - sub-bullet (two-space indent)
    NOTES:
    Everything after NOTES: until the next '## ' becomes the speaker notes
    for that slide, verbatim.

The first '## ' slide becomes the title slide. Every later '## ' is a
title-and-content slide. Blank lines inside NOTES are preserved.

Install once:  pip install python-pptx
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

try:
    from pptx import Presentation
    from pptx.dml.color import RGBColor
    from pptx.util import Inches, Pt
except ImportError:  # pragma: no cover
    sys.exit("python-pptx is not installed. Run: pip install python-pptx")

INK = RGBColor(0x1A, 0x1A, 0x1A)
MUTED = RGBColor(0x5A, 0x5A, 0x5A)
ACCENT = RGBColor(0x0A, 0x6E, 0xD1)


def parse_deck(text: str) -> tuple[dict, list[dict]]:
    """Return (meta, slides) parsed from the deck markdown."""
    meta: dict[str, str] = {}
    if m := re.search(r"<!--\s*meta(.*?)-->", text, re.S):
        for line in m.group(1).strip().splitlines():
            if ":" in line:
                key, _, value = line.partition(":")
                meta[key.strip()] = value.strip()
        text = text[: m.start()] + text[m.end() :]

    if m := re.search(r"^#\s+(.+)$", text, re.M):
        meta.setdefault("title", m.group(1).strip())

    slides: list[dict] = []
    # Split on '## ' headings, keeping the heading text.
    chunks = re.split(r"^##\s+(.+)$", text, flags=re.M)[1:]
    for title, body in zip(chunks[0::2], chunks[1::2]):
        content, _, notes = body.partition("NOTES:")

        time = ""
        if m := re.search(r"^\[TIME:\s*(.+?)\]\s*$", content, re.M):
            time = m.group(1).strip()
            content = content[: m.start()] + content[m.end() :]

        bullets: list[tuple[int, str]] = []
        for raw in content.splitlines():
            if not raw.strip().startswith(("-", "*")):
                continue
            indent = len(raw) - len(raw.lstrip(" "))
            bullets.append((min(indent // 2, 4), raw.strip()[1:].strip()))

        slides.append(
            {
                "title": title.strip(),
                "bullets": bullets,
                "notes": notes.strip("\n").rstrip(),
                "time": time,
            }
        )
    return meta, slides


def _style_runs(frame, size: int, color=INK, bold=False) -> None:
    for para in frame.paragraphs:
        for run in para.runs:
            run.font.size = Pt(size)
            run.font.color.rgb = color
            if bold:
                run.font.bold = True
            if run.font.name is None:
                run.font.name = "Segoe UI"


INLINE = re.compile(r"(\*\*.+?\*\*|`[^`]+?`)")


def _add_rich_text(para, text: str) -> None:
    """Write text into a paragraph, honouring **bold** and `code` markers."""
    for token in INLINE.split(text):
        if not token:
            continue
        run = para.add_run()
        if token.startswith("**") and token.endswith("**"):
            run.text = token[2:-2]
            run.font.bold = True
        elif token.startswith("`") and token.endswith("`"):
            run.text = token[1:-1]
            run.font.name = "Consolas"
        else:
            run.text = token


def build(meta: dict, slides: list[dict], out: Path) -> None:
    prs = Presentation()
    prs.slide_width, prs.slide_height = Inches(13.333), Inches(7.5)

    for index, slide in enumerate(slides):
        if index == 0:
            layout = prs.slide_layouts[0]  # title
            s = prs.slides.add_slide(layout)
            s.shapes.title.text = slide["title"]
            _style_runs(s.shapes.title.text_frame, 40, INK, bold=True)
            subtitle_bits = [
                meta.get("subtitle", ""),
                meta.get("presenter", ""),
                meta.get("ppt_date_time", ""),
            ]
            if len(s.placeholders) > 1:
                sub = s.placeholders[1]
                sub.text = "\n".join(b for b in subtitle_bits if b)
                _style_runs(sub.text_frame, 18, MUTED)
        else:
            s = prs.slides.add_slide(prs.slide_layouts[1])  # title and content
            s.shapes.title.text = slide["title"]
            _style_runs(s.shapes.title.text_frame, 30, INK, bold=True)

            body = s.placeholders[1]
            body.width = Inches(11.8)
            frame = body.text_frame
            frame.word_wrap = True
            frame.clear()
            for i, (level, txt) in enumerate(slide["bullets"]):
                para = frame.paragraphs[0] if i == 0 else frame.add_paragraph()
                _add_rich_text(para, txt)
                para.level = level
                para.space_after = Pt(8)
            _style_runs(frame, 19, INK)

            if slide["time"]:
                box = s.shapes.add_textbox(
                    Inches(11.3), Inches(0.28), Inches(1.8), Inches(0.4)
                )
                box.text_frame.text = slide["time"]
                _style_runs(box.text_frame, 12, ACCENT, bold=True)

        if slide["notes"]:
            s.notes_slide.notes_text_frame.text = slide["notes"]

    out.parent.mkdir(parents=True, exist_ok=True)
    prs.save(out)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("deck", type=Path, help="path to the .deck.md file")
    ap.add_argument("-o", "--out", type=Path, help="output .pptx path")
    args = ap.parse_args()

    meta, slides = parse_deck(args.deck.read_text(encoding="utf-8"))
    if not slides:
        sys.exit(f"No '## ' slides found in {args.deck}")

    out = args.out or args.deck.with_suffix("").with_suffix(".pptx")
    build(meta, slides, out)
    noted = sum(1 for s in slides if s["notes"])
    print(f"Wrote {out}  —  {len(slides)} slides, {noted} with speaker notes")


if __name__ == "__main__":
    main()
