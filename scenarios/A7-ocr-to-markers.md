# A7 — OCR boxes become marker coordinates

**Output:** `assets/recipes/05-copy-the-uncopyable/ocr-to-markers.png`, 1280 wide, three panels.

The most technically interesting asset in the set. Nothing else on the market does this: local OCR returns a bounding box per word, and those boxes are fed straight into `add_markers`, so the agent can *point at a word it read* without ever guessing a coordinate.

## The subject

`#/checkout` → **Pay** opens a modal carrying three identifiers in monospace:

```text
PaymentIntent pi_3QxT8mKz2Lp0Wn41 was rejected by the processor.
Reason: card_declined (insufficient_funds)
Request ID: req_8fJq2LmNv4Xc — retry after 30s
```

The dialog sets `user-select: none`, so the text genuinely cannot be selected — which is the entire premise of recipe 05, not a staging trick. Don't "fix" that rule.

Those identifiers are chosen to be OCR-hostile in the useful way: mixed case, digits next to letters, `0`/`O` and `1`/`l` collisions. Some words will come back below full confidence, and that is the asset — a tool that reports doubt instead of inventing a character.

## Stage

```bash
cd scenarios/app
npm run dev                  # http://localhost:5173/#/checkout
./step.sh 3                  # clean card layout, so the dialog is the only subject
```

Click **Pay** to open the dialog. Chrome pinned.

## Panels

| # | Prompt to paste | Yields |
| --- | --- | --- |
| 1 | `capture_tracked_window title "<the window title>", keyword "grab-payment-error". Report the file path.` | The capture |
| 2 | `ocr_screenshot "grab-payment-error" with format "metadata". Print the full transcript, then a table of word → confidence for the three identifiers. Flag anything under 60 as unclear instead of guessing it.` | The transcript, screenshotted from the terminal |
| 3 | `Using the bounding boxes you just got: take the centre of the PaymentIntent id, the decline reason and the request id, and add_markers on "grab-payment-error" numbering them ①②③ in reading order. Tell me which coordinates you used and which OCR box each came from.` | The marker layer |
| 4 | *(no prompt — you do this)* `open_screenshot` the marker layer, toggle markers visible, then `capture_window` matching Lazy Shot's own window title, keyword `ocr-markers-inapp`. | Panel 3's actual pixels |

Panel 2 is a screenshot of the agent's output, not of the app. Keep the coordinates visible in it if they fit — that's the evidence that panel 3 wasn't eyeballed.

### Panel 3 comes from the app, and that is not a compromise

The marker layer's file has the source's pixels. It always will: markers live in `metadata.markers` and are never rasterised, including on export — Beautify's bake step draws the markup tool stack and skips markers by design. Compose panel 3 from that file and you get a blank panel.

So panel 3 is row 4 above: Lazy Shot's own window, the capture on the canvas, markers toggled on, badges sitting on the identifiers. Crop to the canvas so panels 1 and 3 frame the same rectangle and the reader can compare them.

Take a beat on why this is the *right* asset rather than a fallback. The claim being made is that a coordinate came from an OCR box instead of from a guess. A flattened PNG would show badges on words and prove nothing about their provenance — badges on words is what any annotation tool does by hand. A screenshot of the live app, next to the OCR output that produced the numbers, shows the coordinates and their source in the same frame. The provenance *is* the asset.

(If you ever do need badges in a distributable file, that's the **Counter** markup tool, shortcut `N`, placed by hand — an annotation, and annotations bake. It has nothing to do with OCR and no place in this asset.)

## What each panel shows

**Panel 1 — the capture.** The error dialog as shot. Caption: `grab-payment-error`.

**Panel 2 — the OCR output.** A screenshot of the tool result: the transcript, with at least one word visibly carrying a low confidence score. If everything comes back at 95+, shrink the browser window a little and re-shoot — the honest version of this asset needs one uncertain word in it.

**Panel 3 — the marker layer, live in Lazy Shot.** The same capture with ①②③ landing exactly on the three identifiers, shot from the app. Caption: `grab-payment-error-markers`.

## The detail that makes it

Draw a hairline from a word in panel 2 to its marker in panel 3. That single line says *the marker position was derived from the OCR box* — which is the whole idea, and the thing a reader will otherwise skim past.

## Embed

Recipe 05, replacing the `TODO(assets): A7` placeholder:

```markdown
![An unselectable payment error dialog, its OCR transcript with a low-confidence word flagged, and the same capture with three markers positioned from the OCR bounding boxes](../../assets/recipes/05-copy-the-uncopyable/ocr-to-markers.png)
```

## Checklist

- [ ] Panel 3 is a capture of Lazy Shot with markers toggled on — the marker layer's own file shows no badges at all
- [ ] Markers sit *on* the words, not near them — that precision is the claim
- [ ] At least one low-confidence word visible in panel 2
- [ ] The identifiers are readable at final size
- [ ] The hairline connecting panels 2 and 3 is present
- [ ] These identifiers are fictional; if you shot a real error instead, redact with Spoiler
