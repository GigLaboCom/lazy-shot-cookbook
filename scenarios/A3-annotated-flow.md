# A3 — the annotated documentation flow

**Output:** ✅ **shot** — `assets/recipes/01-self-documenting-ui/annotated-flow.png`, 1280 × 473, 100 KB.

The claim: documentation screenshots are build artifacts. The proof is three panels showing one capture becoming a numbered marker layer becoming a docs page — with the numbers matching across all three.

Composed by [`a3/annotated-flow.html`](./a3/annotated-flow.html); re-render with

```bash
scripts/render-html.sh scenarios/a3/annotated-flow.html \
  assets/recipes/01-self-documenting-ui/annotated-flow.png 1280 473
```

## Stage

```bash
cd scenarios/app
npm run dev                  # http://localhost:5173/#/settings
./step.sh 3                  # clean card layout
```

The settings screen has four labelled rows: workspace name, default currency, weekly digest, retention. Four rows, four markers — a clean numbered pass.

Give the page its own browser window rather than a tab in your everyday one. Panels 1 and 2 are crops of the card, so the tab strip never reaches the asset — but the capture on disk keeps it, and that file is what you hand to `add_markers`, `ocr_screenshot` and anything else downstream.

## Panels

| # | Prompt to paste | Yields |
| --- | --- | --- |
| 1 | `capture_region on the settings card, keyword "settings-step-1". Report the file path.` | The raw capture |
| 2 | `add_markers on "settings-step-1", keyword "settings-step-1-markers", numbering the four controls in reading order: ① workspace name, ② default currency, ③ weekly digest, ④ retention. Give me the layer's path and the four coordinates — do not touch the original.` | The marker layer |
| 3 | `Write the docs snippet from your marker list: the image, then a numbered caption list where each number matches a marker. Then ocr_screenshot "settings-step-1" and confirm every control label you wrote actually appears in the OCR text.` | The rendered docs |

The OCR check in panel 3 doesn't appear in the final image, but keep it in the run — it's what stops a docs page from describing a button that was renamed. On this shoot it passed: one `ocr_screenshot` call, mean confidence 91, and all four of *Workspace name*, *Default currency*, *Weekly digest* and *Retention* came back verbatim.

### `capture_region` counts in physical pixels

`list_displays` reports this laptop's built-in screen as 2056 × 1329 with `scale_factor: 2.0`. Those are **logical points**. `capture_region` does not use them: its `x`, `y`, `width` and `height` are **physical pixels**, and the PNG comes back at exactly the size you asked for.

Two ways this bites, both of which cost frames here:

- Pass the numbers you read off a window (`window.screenX`, a CSS layout, a Figma frame) and you capture the top-left **quarter** of what you meant, at half the resolution you could have had.
- Anything you compute against the `list_displays` width looks out of bounds and isn't. `x: 3800` on a display reported as 2056 wide is legal, and returns the right-hand edge of that same screen — 2056 × 2 = 4112 is the real limit.

So: work out the rectangle in points, then double every number. The reward is a native-resolution crop with no upscaling anywhere in the pipeline, which is why panels 1 and 2 stay sharp at 1280.

### Where the badges go

`add_markers` places a badge **centred** on the coordinate you give it. That makes "put it on the control" a worse instruction than it sounds: the demo's weekly-digest control is a 28 px checkbox, and a badge centred on it hides the thing it points at.

What worked: a column in the empty band between the labels and the controls — same `x` for all four, each `y` the vertical centre of its row, taken from the `ocr_screenshot` word boxes rather than estimated. Nothing is covered, the numbering reads top to bottom, and every badge is unambiguously on one row.

Size them for the *final* asset, not for the screenshot. At 56 px on an 820 px-wide capture the badges survive the ~0.48 downscale into a three-panel composition; at the 32 px default they arrive as unreadable dots.

### Panel 2 is a shot of the app, not an exported file

This is the one thing to get right in this scenario, and it's counter-intuitive.

`add_markers` returns a **marker layer**: the badge positions live in `metadata.markers` and the file's pixels are identical to the source. There is no export that changes this — Beautify bakes markup annotations and skips markers by design. If you compose panel 2 from the marker layer's file, panel 2 is a byte-for-byte copy of panel 1 and the asset says nothing. (The library's own thumbnail for the marker layer shows no badges either. That is the same fact, and a useful sanity check that you're looking at the right file.)

So shoot the badges where they actually exist — **in the app**:

1. `show_window` first. A hidden main window captures as a flat empty frame, and the compositor doesn't reliably surface from behind it.
2. `edit_screenshot` on `settings-step-1-markers`. This opens the Beautify compositor on a **new copy** with its own ID — the marker metadata comes along, so the Markers layer works on the copy.
3. Switch the layer to **Markers** (the `Edit | Markers` pill at the bottom of the canvas). This is a click; there is no MCP call and no keyboard shortcut for it. The four badges appear over the image.
4. `capture_window` query **`"Beautify Screenshot"`** — *not* the app name. The compositor is a separate window with its own title; `capture_window "Heretic Lazy Shot"` matches the library window and you get a screenshot of a table of rows.
5. Crop to the canvas when composing, so panels 1 and 2 frame the same rectangle.

This is better than an export would have been. The panel now shows the product doing the thing, and the layer switcher is visible in the frame. Dogfooding, not a workaround.

If your house style needs badges burned into a distributable file, that's the **Counter** markup tool (shortcut `N`) placed by hand — an annotation, and annotations do bake. Not needed for this asset.

## Expected docs output

The agent should produce something like:

```markdown
![Workspace settings](./settings-step-1.png)

1. **Workspace name** — the display name used across the app.
2. **Default currency** — applied to every new dashboard.
3. **Weekly digest** — a Monday summary email.
4. **Retention** — how long raw events are kept.
```

Panel 3 is that Markdown, typeset. It is rendered from the same HTML as the rest of the composition rather than screenshotted out of a previewer, so it stays sharp and anyone can regenerate the asset from the repo alone.

## What each panel shows

**Panel 1** — the raw capture. Caption: `settings-step-1`.
**Panel 2** — the same image inside Lazy Shot with ①②③④ showing. Caption: `settings-step-1-markers`.
**Panel 3** — the rendered docs page, numbered captions visible.

Panels 1 and 2 side by side are the argument that annotation **forks** rather than mutates. Both captions have to be legible; the two different filenames are what prove there are two files.

**Put the captions in the composition, not in the frame.** The compositor's chrome labels the open image by ID (`#819  820 x 828`), never by keyword, so cropping "the caption" out of the app is not an option — there isn't one to crop. The keyword is yours to typeset underneath.

## Compose

Three panels left to right at uniform height, 1280 wide total, thin gutters, keyword captions under each. Panels 1 and 2 are cropped to the same rectangle in their own coordinate spaces — panel 2's is the panel 1 rectangle multiplied by the compositor's zoom (127% on this shoot) and offset to the canvas origin, which keeps the two cards the same size on the page.

## Embed

Recipe 01, replacing the `TODO(assets): A3` placeholder:

```markdown
![A settings screen captured, the same capture open in Lazy Shot with four numbered markers on its controls, and the generated docs page whose captions match those numbers](../../assets/recipes/01-self-documenting-ui/annotated-flow.png)
```

## Checklist

- [x] Panel 2 is a capture of Lazy Shot with markers toggled on — the marker layer's own file shows nothing
- [x] Marker numbers match the caption numbers across panels 2 and 3
- [x] Both keywords legible — two files, visibly
- [x] Markers on their rows and covering nothing — see [where the badges go](#where-the-badges-go)
- [x] Panel 3 shows rendered Markdown, not raw source
