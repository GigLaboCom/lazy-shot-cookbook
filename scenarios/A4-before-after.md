# A4 — the before/after pair

**Output:** `assets/recipes/02-visual-bug-fixing/before-after.png`, 2 panels, 1280 wide, under 1 MB.

The broken screen beside the same screen fixed. The argument: a fix without an *after* shot is a claim, and here both halves of the evidence are named files in the same library.

## Stage

```bash
cd scenarios/app
npm run dev                  # http://localhost:5173/#/checkout
./step.sh 3                  # clean card layout — see note
./step.sh checkout-broken
```

**`./step.sh 3` first, and don't skip it.** The card's layout defects belong to A2. If you shoot this at step 0 the panel carries two unrelated bugs and the reader can't tell which one the markers are about. Fix the layout, leave the arithmetic broken.

Chrome pinned — both panels are the same crop, so any size change between them shows.

## The bug

```js
const subtotal = 348.0;
const discount = '10%';
const reduction = subtotal * discount;   // NaN — a string, never parsed
const total = subtotal - reduction;      // NaN
```

On screen: `-€NaN`, `€NaN`, and a button reading **Pay €NaN**.

## Panels

| # | State | Prompt to paste | Keyword |
| --- | --- | --- | --- |
| 1 | `./step.sh checkout-broken` | `capture_tracked_window title "<the window title>", keyword "checkout-before". Then ocr_screenshot it and quote the broken values verbatim.` | `checkout-before` |
| 2 | `./step.sh checkout-fixed` | `capture_tracked_window title "<the window title>", keyword "checkout-after". Confirm the three values now read €348.00, -€34.80 and €313.20, and print both file paths with a one-line PR summary.` | `checkout-after` |

Target the window by **title**. The process name matches any window of that app, which during this shoot meant capturing a personal inbox instead of the demo.

### On the markers

Recipe 02 places numbered repro markers, and you can do that here — `add_markers` on `checkout-before`, badges on the discount line, the total and the pay button. But know what you get: a **marker layer**, whose file still has the source's pixels, and which stays that way. Markers are never rasterised, in any export.

The shipped asset skips them, and that's the right call. `-€NaN` does not need an arrow pointing at it. Markers earn their place in [A7](./A7-ocr-to-markers.md), where their positions come from OCR boxes and the precision *is* the message.

## Expected output after the fix

```js
const reduction = subtotal * (Number.parseFloat(discount) / 100);   // 34.8
```

| Line | Before | After |
| --- | --- | --- |
| Professional, annual | `€348.00` | `€348.00` |
| Launch discount | `-€NaN` | `-€34.80` |
| Total due today | `€NaN` | `€313.20` |
| Button | `Pay €NaN` | `Pay €313.20` |

Verified: these are the exact values the app renders.

## Compose

Both panels into the Compositor side by side, visible gutter, uniform tile size, 1280 wide total. Caption strips underneath reading `checkout-before` and `checkout-after` — two keywords, visibly two files.

## Embed

Recipe 02, replacing the `TODO(assets): A4` placeholder:

```markdown
![A checkout screen showing a NaN discount and a NaN total, beside the same screen after the fix showing minus 34.80 and a total of 313.20](../../assets/recipes/02-visual-bug-fixing/before-after.png)
```

## Checklist

- [x] Shot at `./step.sh 3` — the only difference between panels is the numbers
- [x] Both panels the same crop and scale — one `CROP` variable feeds both, so they cannot drift
- [x] `NaN` legible at final size — it carries the left panel
- [x] `./step.sh reset` afterwards — the app is committed at step 0
