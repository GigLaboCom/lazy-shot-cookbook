# A7 — OCR boxes become marker coordinates

**Output:** `assets/recipes/05-copy-the-uncopyable/ocr-to-markers.png` — ✅ **shot**, 1280 × 781, 183 KB.

**Layout changed during the shoot.** Three panels in a row put the dialog at ~420 px wide, and the identifiers — the entire subject — stopped being readable. The shipped asset is 2 + 1: the two captures side by side on top, the OCR table full width underneath. Same three panels, same argument, legible.

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
| 4 | *(no prompt — you do this)* `edit_screenshot` the marker layer, switch the layer to **Markers**, set zoom to **185%**, then `capture_window` matching **`Beautify Screenshot`**, keyword `ocr-markers-inapp`. | Panel 3's actual pixels |

Three details in row 4 that cost time to find:

- **The compositor window is titled `Beautify Screenshot`**, not "Heretic Lazy Shot". That is a separate window from the main one, with its own tracker entry. Targeting the app's name gets you the library window.
- **Switching the layer to Markers is what makes badges appear** — `markersVisible` starts `false` and the layer switcher sets it (`setMarkersVisible(layer === 'markers')`). There is no separate toggle to hunt for on the markers layer.
- **Zoom to 185%.** At the default fit-to-window zoom the dialog text is too small to read in the final panel, and the `auto` beautify preset renders a canvas slightly smaller than the source (inset and scale), so image coordinates and canvas coordinates stop being the same number — which matters if you are checking placement by measurement rather than by eye.

Panel 2 is a screenshot of the agent's output, not of the app. Keep the coordinates visible in it if they fit — that's the evidence that panel 3 wasn't eyeballed.

### Panel 3 comes from the app, and that is not a compromise

The marker layer's file has the source's pixels. It always will: markers live in `metadata.markers` and are never rasterised, including on export — Beautify's bake step draws the markup tool stack and skips markers by design. Compose panel 3 from that file and you get a blank panel.

So panel 3 is row 4 above: Lazy Shot's own window, the capture on the canvas, markers toggled on, badges sitting on the identifiers. Crop to the canvas so panels 1 and 3 frame the same rectangle and the reader can compare them.

Take a beat on why this is the *right* asset rather than a fallback. The claim being made is that a coordinate came from an OCR box instead of from a guess. A flattened PNG would show badges on words and prove nothing about their provenance — badges on words is what any annotation tool does by hand. A screenshot of the live app, next to the OCR output that produced the numbers, shows the coordinates and their source in the same frame. The provenance *is* the asset.

(If you ever do need badges in a distributable file, that's the **Counter** markup tool, shortcut `N`, placed by hand — an annotation, and annotations bake. It has nothing to do with OCR and no place in this asset.)

## What each panel shows

**Panel 1 — the capture.** The error dialog as shot. Caption: `grab-payment-error`.

**Panel 2 — the OCR output.** A screenshot of the tool result: the transcript, with at least one word visibly carrying a low confidence score. If everything comes back at 95+, shrink the browser window a little and re-shoot — the honest version of this asset needs one uncertain word in it.

The real run produced a better result than this scenario originally hoped for, and it's worth reproducing rather than improving on:

| Identifier | Tesseract read | Confidence |
| --- | --- | --- |
| `pi_3QxT8mKz2Lp0Wn41` | `pi_30xT@nkz2Lpovin4` | **6.9** |
| `card_declined (insufficient_funds)` | correct | 91.7 / 87.9 |
| `req_8fJq2LmNv4Xc` | correct | 48.1 |

The first is mangled — `Q`→`0`, `8m`→`@n`, `0Wn41`→`ovin4` — and reported at 6.9% rather than asserted. The third is read **correctly** and still only claims 48%. That pair is the argument: a tool that is wrong and says so, beside a tool that is right and stays modest. Put both in the panel if they fit; the 6.9% alone is worth the asset.

**Panel 3 — the marker layer, live in Lazy Shot.** The same capture with ①②③ landing exactly on the three identifiers, shot from the app. Caption: `grab-payment-error-markers`.

## Checking placement, if you check it at all

Badge coordinates are the badge **centre**, in source-image pixels — so a word's box centre (`x + width/2`, `y + height/2`) goes in unmodified. Don't compensate for anything.

If you do want to verify the badges landed where you asked rather than trusting your eye, verify against a **1:1 canvas**. On the `auto` preset the compositor composes onto a canvas a little smaller than the source, so a badge measured in the screenshot of the compositor sits at `origin + position × imageScale × zoom`, and comparing that to raw image coordinates will show a drift that is not really there. Ask for `original`, or zoom until the header reads the source's own dimensions, and then image pixels and canvas pixels are the same number.

Keep badges modest — `size: 24` here. A badge is drawn centred on the token, so it covers part of it; panel 1 and panel 2 are what carry legibility of the identifiers, and panel 3 only has to show that the numbers landed.

## Compose

Panel 2 is typeset, not screenshotted from a terminal: [`a7/ocr-panel.html`](./a7/ocr-panel.html), rendered by the shared script. Every value in it is verbatim from the real call.

```bash
./scripts/render-html.sh scenarios/a7/ocr-panel.html /tmp/a7/p2.png 1280 366
```

A terminal screenshot would have been more literally "the agent's output", but it also puts whatever else is in your scrollback into a public repository, and it goes illegible below about 900 px. Typesetting real numbers is the honest trade; inventing one is not, so re-run the call rather than editing the HTML if the subject changes.

The two captures are cropped to the same rectangle of the same underlying image — 514 × 282 from the source at 1:1, and the corresponding 1001 × 549 from the compositor capture at 195%, both scaled to 592 × 325. Then captions, a 40 px gutter, and the OCR panel stacked underneath:

```bash
ffmpeg -i "$SRC" -vf "crop=514:282:703:734,scale=592:325:flags=lanczos" p1.png
ffmpeg -i "$CMP" -vf "crop=1001:549:332:490,scale=592:325:flags=lanczos" p3.png
# caption each, pad to a 40 px gutter, hstack, then vstack the OCR panel
```

Recompute all four crop rectangles for your own window size. The two must frame the same region of the same image, or the reader reads a difference that isn't there.

## The detail that makes it

A reader has to see that *the marker position was derived from the OCR box* — the whole idea, and the thing they will otherwise skim past.

This page originally called for a hairline drawn from a word in panel 2 to its marker in panel 3. The shipped asset does not have one. Once the layout became 2 + 1, a line from the table up into the top-right panel had to cross the full width of the image, and it read as a stray rule rather than as a pointer.

What shipped instead is three cross-references that need no geometry: the ①②③ badges repeat as the table's row markers, a `MARKER X, Y` column sits beside each `BOUNDING BOX`, and one line under the table states that every marker coordinate is the centre of the box on its left. If you re-shoot at three panels in a row, the hairline becomes worth drawing again.

## Embed

Recipe 05, replacing the `TODO(assets): A7` placeholder:

```markdown
![An unselectable payment error dialog, its OCR transcript with a low-confidence word flagged, and the same capture with three markers positioned from the OCR bounding boxes](../../assets/recipes/05-copy-the-uncopyable/ocr-to-markers.png)
```

## Checklist

- [x] Panel 3 is a capture of Lazy Shot with markers toggled on — captioned `grab-payment-error-markers · in Lazy Shot`
- [x] Markers sit *on* the words, not near them — that precision is the claim
- [x] At least one low-confidence word visible in panel 2 — `6.9` on the PaymentIntent id, in red
- [x] The identifiers are readable at final size
- [x] These identifiers are fictional; if you shot a real error instead, redact with Spoiler
- [ ] ~~The hairline connecting panels 2 and 3~~ — **not drawn.** The correspondence is carried instead by the ①②③ badges repeating as the table's row markers, a `MARKER X, Y` column beside each `BOUNDING BOX`, and the line under the table: *every marker coordinate is the centre of the box on its left.* Three cross-references rather than one line, and they survive the reader skimming.
