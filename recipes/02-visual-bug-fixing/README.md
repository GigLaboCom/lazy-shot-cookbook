# Recipe 02 — The visual bug-fixing loop

**Problem:** "can't reproduce" is where tickets go to die. Prose descriptions of visual bugs lose exactly the information that matters, and the screenshot that *would* have settled it is called `Screenshot 2026-08-11 at 14.32.07.png` on somebody's desktop.

**Idea:** make the screenshot library the case file, and make the agent maintain it.

<!-- TODO(assets): A4 — assets/recipes/02-visual-bug-fixing/before-after.png — spec in docs/ASSETS.md -->

## Six principles

1. **Evidence before opinion.** Before anyone theorises, capture the actual broken state — `capture_window` on the app the moment it happens.
2. **Before/after pairs, always.** Convention: `<bug-slug>-before` and `<bug-slug>-after`. A fix without an *after* shot is a claim, not a fix.
3. **Number the repro, don't narrate it.** `add_markers` places numbered badges on the exact elements — "click ① then ② and watch ③" beats three paragraphs.
4. **Fork, don't mutate.** Annotation lands on a copy. The pristine original stays diffable against the *after* shot.
5. **Redact before it leaves the machine.** Tokens, emails, customer data — hit them with **Blur** or **Spoiler** in the app before the image touches Jira, GitHub or Linear. (Light blur on text can be reversed; Spoiler's heavy pixelation can't. This is a human step in the overlay — the agent should *remind* you, not skip it.)
6. **The library is institutional memory.** When the bug reopens in three months, `search_screenshots "<bug-slug>"` resurrects the whole visual history in seconds. Soft delete means nothing is ever lost.

## Copy-paste prompt (Claude Code)

Add to your `CLAUDE.md`:

```text
When I say "grab the bug <slug>":
1. capture_window on the affected app with keyword "<slug>-before"
   (use the returned keyword from here on).
2. Ask me which elements are involved; add_markers numbering them in
   repro order.
3. ocr_screenshot the capture and quote any error text verbatim — do not
   retype it from the image by eye.
4. Remind me to blur any sensitive data in the app before sharing.
5. Output an issue-ready block: title suggestion, numbered repro steps
   matching the markers, verbatim error text, and the annotated copy's
   file path.

When I say "close the bug <slug>":
1. capture_window, keyword "<slug>-after".
2. search_screenshots "<slug>" and list the full evidence set.
3. Output a PR-comment block: before/after file paths + one-line summary.
```

## The loop, end to end

```text
reproduce ──▶ capture ──▶ keyword "<slug>-before" ──▶ markers on the repro
                                                            │
     attach to issue  ◀──  annotated copy's file_path  ◀────┘

fix the code ──▶ capture ──▶ keyword "<slug>-after" ──▶ search "<slug>" ──▶ before/after in the PR
```

The agent that *fixes* the bug uses the same tools: capture the failing state, read the image from `file_path`, patch the code, capture again, present you the pair. Eyes on both ends of the loop.

## Why OCR belongs in a bug report

An agent transcribing a stack trace from pixels by eye will, sooner or later, silently invent a line number. `ocr_screenshot` doesn't: it returns what Tesseract actually read, on-device, and with `format: "metadata"` it returns a confidence score per word — so "I read this at 43% confidence" is available instead of a confident hallucination. For error text that someone will paste into a search box, that difference is the whole point.

## Tools used

`capture_window` · `capture_tracked_window` · `assign_keyword` · `add_markers` · `ocr_screenshot` · `search_screenshots` · `get_screenshot`

## Gotchas

- Blur and Spoiler are **in-app annotation tools**, not MCP tools — redaction stays a deliberate human act, by design. The agent can remind, stage the image with `show_window`, and stop there.
- Markers are metadata until export; the annotated *copy* is what you attach to the tracker.
- Keywords describe content, not time. The on-disk filename pattern already handles chronology.
- If the bug is in a window you've since left, `capture_tracked_window` is more reliable than asking the user to re-navigate — provided the Activity Tracker is on.
