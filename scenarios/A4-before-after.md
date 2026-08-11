# A4 — the before/after pair

**Output:** `assets/recipes/02-visual-bug-fixing/before-after.png`, 2 panels, 1280 wide, under 1 MB.

The bug with numbered repro markers beside the same screen fixed. The argument: the annotated copy and the pristine original are *different files*, and both survive.

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
| 1 | `./step.sh checkout-broken` | `capture_window query "Google Chrome", keyword "checkout-before". Then ocr_screenshot it and quote the broken values verbatim. Then add_markers numbered in repro order: ① the discount line, ② the total line, ③ the pay button. Give me the annotated copy's file path.` | `checkout-before` → `checkout-before-markers` |
| 2 | `./step.sh checkout-fixed` | `capture_window query "Google Chrome", keyword "checkout-after". Confirm the three values now read €348.00, -€34.80 and €313.20, and print both file paths with a one-line PR summary.` | `checkout-after` |

Use the **annotated copy** for panel 1, not the original. `add_markers` forks, and showing the fork is half of recipe 02's argument.

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
![A checkout screen showing a NaN total with three numbered repro markers, beside the same screen after the fix showing €313.20](../../assets/recipes/02-visual-bug-fixing/before-after.png)
```

## Checklist

- [ ] Shot at `./step.sh 3` — the only difference between panels is the numbers
- [ ] Markers on the *copy*, original untouched
- [ ] Both panels the same crop and scale
- [ ] `NaN` legible at final size — it carries the left panel
- [ ] `./step.sh reset` afterwards
