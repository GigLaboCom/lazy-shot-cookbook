# Recipe 03 — Navigating complex sites: eyes for your browser agent

**Problem:** browser agents get lost on real-world sites — dense SPAs, admin panels, checkout funnels, anything with dynamic layout. The DOM says one thing, the rendered page says another, and when the run fails you have no idea *where* it went wrong.

**Idea:** split the job. Your automation tool (Playwright MCP, a browser extension, any computer-use setup) is the **hands**. Lazy Shot is the **eyes and the flight recorder**: pixel-exact captures, keyword-named steps, a persistent visual log of every session.

Lazy Shot doesn't click — deliberately. It does the part browser tools do badly: a permanent, searchable, annotated visual record.

<!-- TODO(assets): A5 — assets/recipes/03-complex-site-navigation/session-replay.gif — spec in docs/ASSETS.md -->

## The navigation loop

```text
           ┌──────────── decide next action (agent) ◀───────────┐
           ▼                                                    │
  act via hands (Playwright / extension)                 read image from
           │                                                file_path
           ▼                                                    │
  capture_window "Chrome" (keyword "task-step-N") ──────────────┘
```

Every iteration leaves a named artifact. Nothing about the run is ephemeral.

## Copy-paste prompt

```text
You navigate websites with two tool sets:
- <your browser tool> for actions (click, type, scroll, navigate),
- Lazy Shot MCP for vision and logging.

Protocol for the task "<task-slug>":
1. After every action, capture_window with query "<browser name>" and
   keyword "<task-slug>-step-N" (increment N; use returned keywords).
2. Read the image from the returned file_path before deciding the next
   action. Trust the pixels over your assumptions about the DOM.
3. If the page differs from what you expected, add_markers on the capture
   flagging the elements that surprised you, and note the marker layer's
   path and the coordinates you used.
4. On finish or failure, output the full step list: keyword → file_path,
   so I can replay the session visually.
```

## Site maps as marker presets

For a site you automate repeatedly, build a **visual map once**: capture the canonical state of each tricky page, place numbered markers on the zones that matter (nav, filters, the button that only looks like a link), save one preset per page. Then:

```text
Before acting on <page>, search_screenshots "<site>-map-<page>", read the
image, and get_marker_preset "<site>-map-<page>" for the numbered zones.
The image shows you the page; the preset coordinates are your ground
truth for what is clickable and where. The badges are metadata — they
will not appear in the image, so read both.
```

The agent now starts every run with your knowledge of the site baked into pixels — cheaper and more robust than re-deriving it from the DOM each time.

## When the DOM lies, OCR arbitrates

Rendered text and DOM text diverge more often than people expect: canvas-rendered tables, virtualised lists, `::before` content, iframes you can't reach, a spinner that replaced the label you were waiting for. `ocr_screenshot` reads what a *user* would read.

```text
If your selector-based read disagrees with what the page appears to show,
ocr_screenshot the capture and treat the OCR text as authoritative for
"what the user sees". Report both when they differ — the mismatch is
usually the bug.
```

With `format: "metadata"` you also get a bounding box per word, which turns "find the Continue button" into arithmetic rather than a guess.

## Multi-monitor and precision work

- `list_displays` gives exact geometry — required before any `capture_region` math on multi-display setups.
- `capture_region` grabs just the viewport (skipping browser chrome) for cleaner reads.
- `capture_tracked_window` recovers "the window I was just in" when the browser lost focus mid-run.

## Post-mortems for free

A failed run stops being a mystery: `search_screenshots "<task-slug>"` returns every step in order. Scroll the sequence, find the exact frame where reality diverged from the plan, fix the prompt or the selector. This is the debugging experience browser logs never give you.

## Requirements & honesty

- This recipe needs a **local agent that can read files** (Claude Code, Claude Desktop, Cursor, self-hosted n8n) — that's the file-path-first contract. Remote SaaS runners can't reach local paths.
- If your browser tool already returns inline screenshots and you only need one-shot vision, use that. Lazy Shot earns its place when you need **persistence, naming, annotation and replay** across steps and sessions.

## Tools used

`capture_window` · `capture_region` · `capture_tracked_window` · `list_displays` · `assign_keyword` · `add_markers` · `ocr_screenshot` · `search_screenshots`
