# Recipe 01 — Self-documenting UI flows

**Problem:** every release quietly breaks your docs. The screenshots show last month's UI, the numbered arrows point at buttons that moved, and nobody re-captures 40 images by hand.

**Idea:** treat documentation screenshots as *build artifacts*. The agent captures them, numbers them, names them — and regenerates the whole set on demand.

<!-- TODO(assets): A3 — assets/recipes/01-self-documenting-ui/annotated-flow.png — spec in docs/ASSETS.md -->

## The loop

```text
capture the window  →  keyword it  →  numbered markers (on a copy) = the outline
        ↑                                                                  │
        │                              ship the capture + matching captions │
        └──────────────  after the next release: repeat by keyword list  ──┘
```

Lazy Shot ships this as a built-in MCP workflow prompt: **`document-ui-flow`**. Invoke it directly from any client that supports MCP prompts (`/mcp` in Claude Code), or paste the sharper version below.

## Copy-paste prompt

```text
Document the "<flow name>" flow of <app name> using Lazy Shot.

For each step of the flow:
1. Tell me what state to put the app in, then wait for my "go".
2. capture_window with query "<app name>" and keyword "<flow-slug>-step-N".
3. add_markers with numbered markers on each UI element I should mention,
   in reading order. Remember: this forks a copy, and the badges are
   metadata — reference the ORIGINAL capture's file_path for the docs
   image, and use the marker list as your outline.

When all steps are done, output a Markdown snippet for our docs: one image
per step with a caption list in marker order, each caption naming the
control by its on-screen label.
```

## Marker presets: consistency for free

If your docs re-annotate the same layout repeatedly (onboarding tour, settings page, review checklist), place the markers once **in the app**, save them as a named preset, and let the agent reapply it forever:

```text
Before placing markers manually, call list_marker_presets.
If a preset named "<flow-slug>" exists, add_markers using that preset
instead of explicit coordinates.
```

Markers are a metadata layer, not pixels: relabel, move and reuse them across versions without touching the raster.

## What the markers are actually doing here

Worth being precise, because it decides what your docs page looks like. Markers are **never** rendered into an image file — not by `add_markers`, and not by an export from Beautify either, which bakes markup annotations and skips markers by design. They are visible in the app, and they are readable as JSON.

So in a documentation pass, markers are the **outline**, not the illustration: a stable, ordered, named map of which controls this step is about, which survives a re-capture after the UI moves. The image you ship is the clean capture. Captions name the control by its label — `**Workspace name** — the display name used across the app` — which is better docs than "①" anyway, and it's the form `ocr_screenshot` can verify against the screen.

If your house style genuinely needs badges burned into the picture, that's the **Counter** markup tool (shortcut `N`), placed by hand and baked on export. Know what you're signing up for: it's a manual pass per screen per release, and it's the one part of this recipe that doesn't regenerate itself.

## Regeneration after a release

This is the payoff. Keep a flat list of documented flows in your repo (`docs/flows.txt`), then:

```text
Read docs/flows.txt. For each flow slug:
1. search_screenshots for "<slug>-step-" to find the current set and count.
2. Walk me through re-capturing each step (same keywords — collisions
   auto-suffix, so use the *new* returned keywords).
3. Reapply the "<slug>" marker preset to each new capture.
4. Print an old→new file path mapping so I can swap the images in the docs.
```

Your screenshots are now versioned data with stable names, not files rotting in `~/Desktop`.

## Captions that match the screen

Docs drift in two directions: the picture goes stale, and so does the text under it. `ocr_screenshot` closes the second gap — after re-capturing a step, have the agent OCR the new capture and diff the visible labels against the caption in your docs. Renamed a button from "Sync now" to "Update"? The doc sentence still says "Sync now", and the agent can now see that without you re-reading every page.

```text
For each regenerated step: ocr_screenshot the new capture, then flag any
sentence in the docs page that quotes UI text which no longer appears in
the OCR output.
```

## Tools used

`capture_window` · `assign_keyword` · `add_markers` · `list_marker_presets` · `search_screenshots` · `ocr_screenshot`

## Gotchas

- Capture via MCP is **headless and silent** — no overlay, no editor, no notification. If you expected something to pop up, that's the point; check the library instead.
- `add_markers` doesn't mutate: budget for two files per step (original + marker layer). The layer's pixels match the original — the badges are metadata, so ship the original and keep the layer as the outline. ([Details](../../docs/TOOLS.md#add_markers).)
- An agent cannot *see* markers it placed. Reading the marker layer's image shows an unmarked screenshot; to recall the positions it calls `get_screenshot` and reads `metadata.markers`.
- Keyword collisions auto-suffix (`login-step-1`, `login-step-1-2`, …). Always use the keyword *returned*, not the one you asked for.
- Preset marker coordinates are absolute — they assume the window is the same size it was when the preset was built. Pin the window size for documentation passes.
