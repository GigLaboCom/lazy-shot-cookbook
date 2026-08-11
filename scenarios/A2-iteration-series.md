# A2 — the iteration series

**Output:** `assets/recipes/00-see-what-you-shipped/iteration-series.gif`, 6 frames, ~9.7 s, 1280 wide, under 5 MB.
**Also yields:** the middle beat of [A10](./A10-demo-video.md).

The whole pitch: an agent changes UI code and *looks* at the result until it matches. Six frames, stitched — no screen recording, no timing luck, and every frame reshootable on its own.

## Stage

```bash
cd scenarios/app
npm install          # first time only
npm run dev          # http://localhost:5173/#/pricing
./step.sh reset      # all three defects present
```

Chrome on `#/pricing`, **pinned**: fixed size, never moved or resized until the last frame is captured. Every frame must share the same geometry or the GIF jitters. Zoom 100%, bookmarks hidden, clean profile.

Keep Lazy Shot's window off-screen or behind — the subject is the browser.

## Frames

Run these in order. Each row: set the state, paste the prompt, get one capture.

| # | State | Prompt to paste | Keyword | Hold |
| --- | --- | --- | --- | --- |
| 01 | `./step.sh 0` | `capture_window query "Google Chrome", keyword "hero-before". Then read the image and list every layout defect you can see, one per line.` | `hero-before` | 1.6 s |
| 02 | `./step.sh 1` | `capture_window query "Google Chrome", keyword "hero-iter-1". Read it. State in one line what is now correct and what is still wrong.` | `hero-iter-1` | 1.4 s |
| 03 | `./step.sh 2` | `capture_window query "Google Chrome", keyword "hero-iter-2". Read it. Same one-line verdict.` | `hero-iter-2` | 1.4 s |
| 04 | `./step.sh 3` | `capture_window query "Google Chrome", keyword "hero-iter-3". Read it. Same one-line verdict.` | `hero-iter-3` | 1.4 s |
| 05 | *(unchanged)* | `capture_window query "Google Chrome", keyword "hero-after". Confirm it matches the goal: heading inside the card and wrapping, period on the amount's baseline, button full width.` | `hero-after` | 1.4 s |
| 06 | *(unchanged)* | Compositor: take `hero-before` and `hero-after` side by side, export as the closing frame | `hero-pair` | 2.5 s |

Frame 06 is the payoff — the before/after pair that ends up in a PR. It's composed, not captured.

Never `capture_active_window`: it would shoot the terminal.

## What each frame should show

| Frame | Heading | Price | Button |
| --- | --- | --- | --- |
| 01 | Spills past both card edges | `/ month` stranded below | Narrow stub, hanging off the left |
| 02 | **Inside the card, wrapped** | `/ month` still stranded | Still a stub |
| 03 | Inside the card | **`€29 / month` on one baseline** | Still a stub |
| 04–05 | Inside the card | On one baseline | **Full width, list aligned left** |

If a frame doesn't differ from the one before it, the step didn't apply — check `./step.sh status` and that Vite is running.

## The code behind each step

Applied by `./step.sh N`, which concatenates `src/steps/fix-1..N.css` into `src/overrides.css`. The fixes themselves:

**Step 1 — the card and its heading**

```css
.card { width: 320px; padding: 24px; }
.card h2 { font-size: 20px; line-height: 1.3; white-space: normal; margin: 0 0 12px; }
```

**Step 2 — the price baseline**

```css
.price { display: flex; align-items: baseline; gap: 6px; margin: 0 0 16px; }
.price .amount { display: inline; font-size: 40px; font-weight: 600; }
.price .period { display: inline; color: var(--muted); font-size: 14px; }
```

**Step 3 — the list and the button**

```css
.features { padding-left: 0; }
.cta { width: 100%; margin-top: 20px; }
```

If you'd rather have the agent write these itself rather than applying them from files, use the [live-loop variant](#variant--let-the-agent-do-it) below.

## Captions

Burn the keyword into each frame before stitching — bottom-left, small, monospace, on a translucent strip. Half of this asset's job is making the naming convention visible; without the captions it's just a layout changing.

The Compositor does this in one pass per frame.

## Stitch

Export the six frames from the library at identical dimensions, name them `01.png` … `06.png`, then:

```text
# frames.txt
file '01.png'
duration 1.6
file '02.png'
duration 1.4
file '03.png'
duration 1.4
file '04.png'
duration 1.4
file '05.png'
duration 1.4
file '06.png'
duration 2.5
file '06.png'
```

```bash
ffmpeg -f concat -safe 0 -i frames.txt -t 9.7 \
  -vf "fps=12,scale=1280:-2:flags=lanczos,split[s0][s1];\
[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 -y iteration-series.gif
```

Two quirks worth knowing, both handled above: the concat demuxer ignores the **last** entry's duration, which is why `06.png` is listed twice; and that repeat would otherwise double the closing hold, which is why `-t` trims the total to the sum of the durations. Verified on ffmpeg 8.0 — output lands at 9.66 s.

Over 5 MB? Drop `fps` to 10 before touching the width. Legible captions matter more than smooth motion in a six-frame loop.

## Variant — let the agent do it

For A10 you want the loop happening live rather than assembled. Same stage, but instead of `./step.sh N`, paste this once and let it run:

```text
The pricing card at http://localhost:5173/#/pricing is broken. Chrome runs it
with hot reload; the process is "Google Chrome".

Goal: heading inside the card and wrapping, the billing period on the same
baseline as the amount, the button full width at the bottom.

1. Before your first edit: capture_window query "Google Chrome",
   keyword "hero-before".
2. Fix ONE defect at a time in scenarios/app/src/overrides.css. After each
   edit: capture_window query "Google Chrome", keyword "hero-iter-N", read
   the image, and state what is fixed and what is not.
3. Never capture_active_window — that is this terminal.
4. When the last capture matches the goal, keyword it "hero-after" and print
   the before/after file paths.
```

If it fixes everything in one pass, stop and re-run — the convergence is the asset. If it claims done without reading an image, that take is unusable.

## Embed

README (replacing the `TODO(assets): A2` placeholder) and the top of recipe 00:

```markdown
![Six screenshots of the same pricing card, each captured by the agent after a code change, the layout converging on the intended design](./assets/recipes/00-see-what-you-shipped/iteration-series.gif)
```

## Checklist

- [ ] Window geometry identical in all six frames
- [ ] Each frame visibly differs from the previous one
- [ ] Keywords burned in and legible at 1280 wide
- [ ] Nothing personal in the browser chrome
- [ ] Under 5 MB
- [ ] `./step.sh reset` afterwards
