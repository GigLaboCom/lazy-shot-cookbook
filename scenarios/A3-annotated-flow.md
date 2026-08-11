# A3 — the annotated documentation flow

**Output:** `assets/recipes/01-self-documenting-ui/annotated-flow.png`, 1280 wide, three panels.

The claim: documentation screenshots are build artifacts. The proof is three panels showing one capture becoming a numbered marker layer becoming a docs page — with the numbers matching across all three.

## Stage

```bash
cd scenarios/app
npm run dev                  # http://localhost:5173/#/settings
./step.sh 3                  # clean card layout
```

The settings screen has four labelled rows: workspace name, default currency, weekly digest, retention. Four rows, four markers — a clean numbered pass.

## Panels

| # | Prompt to paste | Yields |
| --- | --- | --- |
| 1 | `capture_tracked_window title "<the window title>", keyword "settings-step-1". Report the file path.` | The raw capture |
| 2 | `add_markers on "settings-step-1", keyword "settings-step-1-markers", numbering the four controls in reading order: ① workspace name, ② default currency, ③ weekly digest, ④ retention. Give me the layer's path and the four coordinates — do not touch the original.` | The marker layer |
| 3 | `Write the docs snippet from your marker list: the image, then a numbered caption list where each number matches a marker. Then ocr_screenshot "settings-step-1" and confirm every control label you wrote actually appears in the OCR text.` | The rendered docs |

The OCR check in panel 3 doesn't appear in the final image, but keep it in the run — it's what stops a docs page from describing a button that was renamed.

### Panel 2 is a shot of the app, not an exported file

This is the one thing to get right in this scenario, and it's counter-intuitive.

`add_markers` returns a **marker layer**: the badge positions live in `metadata.markers` and the file's pixels are identical to the source. There is no export that changes this — Beautify bakes markup annotations and skips markers by design. If you compose panel 2 from the marker layer's file, panel 2 is a byte-for-byte copy of panel 1 and the asset says nothing.

So shoot the badges where they actually exist — **in the app**:

1. `open_screenshot` (or `edit_screenshot`) on `settings-step-1-markers`.
2. Toggle markers visible. The four badges appear over the image.
3. `capture_window` matching Lazy Shot's own window title, keyword `settings-step-1-markers-inapp`.
4. Crop to the canvas when composing, so panels 1 and 2 frame the same rectangle.

This is better than an export would have been. The panel now shows the product doing the thing, and the caption `settings-step-1-markers` sits on a real Lazy Shot window rather than an anonymous PNG. Dogfooding, not a workaround.

If your house style needs badges burned into a distributable file, that's the **Counter** markup tool (shortcut `N`) placed by hand — an annotation, and annotations do bake. Not needed for this asset.

## Expected docs output

The agent should produce something like:

```markdown
![Workspace settings](./settings-step-1.png)

1. **Workspace name** — the display name used across the app.
2. **Default currency** — applied to every new dashboard.
3. **Weekly digest** — a Monday summary email; off by default for new members.
4. **Retention** — how long raw events are kept before rollup.
```

## What each panel shows

**Panel 1** — the raw capture. Caption: `settings-step-1`.
**Panel 2** — the same image inside Lazy Shot with ①②③④ showing. Caption: `settings-step-1-markers`.
**Panel 3** — the rendered docs snippet, numbered captions visible.

Panels 1 and 2 side by side are the argument that annotation **forks** rather than mutates. Don't crop either caption; the two different keywords are what proves there are two files.

## Compose

Three panels left to right at uniform height, 1280 wide total, thin gutters. Panel 3 can be a touch narrower — it's the payoff, not the evidence.

## Embed

Recipe 01, replacing the `TODO(assets): A3` placeholder:

```markdown
![A settings screen captured, the same capture open in Lazy Shot with four numbered markers on its controls, and the generated docs snippet whose captions match those numbers](../../assets/recipes/01-self-documenting-ui/annotated-flow.png)
```

## Checklist

- [ ] Panel 2 is a capture of Lazy Shot with markers toggled on — the marker layer's own file shows nothing
- [ ] Marker numbers match the caption numbers across panels 2 and 3
- [ ] Both keywords legible — two files, visibly
- [ ] Markers centred on the controls, not floating between rows
- [ ] Panel 3 shows rendered Markdown, not raw source
