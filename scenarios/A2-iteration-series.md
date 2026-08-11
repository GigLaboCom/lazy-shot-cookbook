# A2 — the iteration series

**Output:** `assets/recipes/00-see-what-you-shipped/iteration-series.gif`, 4 frames, ~6.9 s, 1280 wide, under 5 MB.
**Also yields:** the middle beat of [A10](./A10-demo-video.md).

The whole pitch: an agent changes UI code and *looks* at the result until it matches. Four frames, stitched — no screen recording, no timing luck, and every frame reshootable on its own.

There are exactly three defects, so there are exactly three fixes: after the third the card is done, which means the last iteration frame **is** the after frame. Don't shoot a fifth.

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
| 01 | `./step.sh 0` | `capture_tracked_window title "<the window title>", keyword "hero-before". Then read the image and list every layout defect you can see, one per line.` | `hero-before` | 1.6 s |
| 02 | `./step.sh 1` | `capture_tracked_window title "<the window title>", keyword "hero-iter-1". Read it. State in one line what is now correct and what is still wrong.` | `hero-iter-1` | 1.4 s |
| 03 | `./step.sh 2` | `capture_tracked_window title "<the window title>", keyword "hero-iter-2". Read it. Same one-line verdict.` | `hero-iter-2` | 1.4 s |
| 04 | `./step.sh 3` | `capture_tracked_window title "<the window title>", keyword "hero-after". Confirm it matches the goal: heading inside the card and wrapping, period on the amount's baseline, button full width.` | `hero-after` | 2.5 s |

**Match the window by title, never by process name or stack position.** `capture_window "Google Chrome"` matches *a* Chrome window, and with several open that is a coin flip — during this shoot it grabbed a personal inbox. `capture_tracked_window` with `stack_position: 1` is no better: position 1 is whatever was focused last, and running `./step.sh` between frames hands focus to the terminal. Title is the only selector that holds still.

Get the exact title from `list_tracked_windows` before frame 01.

**Duplicate titles in that list are usually not a problem.** `list_tracked_windows` returns *activity history*, not live windows — a window you closed hours ago still has a row. Title matching (`capture.rs`) does a `.find()` over the stack in most-recent-first order, so it resolves to the freshest entry, which is the live one. Check `last_seen` before you go closing windows: during this shoot the list showed two "Northwind Analytics" rows three hours apart, while Chrome actually had one such window open.

It only genuinely bites when **two live windows** share a title. Then there is no way to disambiguate, and you do have to close one.

Optionally compose a fifth frame in the Compositor: `hero-before` and `hero-after` side by side, the pair that ends up in a PR. Composed, not captured.

## What each frame should show

| Frame | Heading | Price | Button |
| --- | --- | --- | --- |
| 01 | Spills past both card edges | `/ month` stranded below | Narrow stub, hanging off the left |
| 02 | **Inside the card, wrapped** | `/ month` still stranded | Still a stub |
| 03 | Inside the card | **`€29 / month` on one baseline** | Still a stub |
| 04 | Inside the card | On one baseline | **Full width, list aligned left** |

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

Burn the keyword into each frame — bottom-left, small, monospace, on a dark strip. Half of this asset's job is making the naming convention visible; without the captions it's just a layout changing.

You could do this by hand in the Compositor with the text tool, one pass per frame. Don't — it's four manual passes that have to land on the same pixel, and the crop has to happen first anyway. Do it in the same ffmpeg step as the crop, below.

## Stitch

Export the four frames from the library at identical dimensions and name them `01.png` … `04.png`. Then crop, scale and caption each one:

```bash
FONT=/System/Library/Fonts/Menlo.ttc      # any monospace TTF/TTC
i=0
for kw in hero-before hero-iter-1 hero-iter-2 hero-after; do
  i=$((i+1)); n=$(printf "%02d" $i)
  ffmpeg -y -i $n.png -vf \
"crop=700:440:610:124,\
scale=1280:-2:flags=lanczos,\
drawtext=fontfile=$FONT:text='$kw':fontcolor=white:fontsize=26\
:x=28:y=h-28-th:box=1:boxcolor=0x0b1220@0.88:boxborderw=14" \
    c$n.png
done
```

The `crop` values are the ones used for the shipped asset: they trim the browser chrome and the dead space under the card. Recompute them for your own window size — take them from one frame, then apply the same rectangle to all of them. The dead space that's left under the card is deliberate; it's where the caption sits.

Then stitch. Note the crop and scale are already done, so this filter chain only does timing and the palette:

```text
# cframes.txt
file 'c01.png'
duration 1.6
file 'c02.png'
duration 1.4
file 'c03.png'
duration 1.4
file 'c04.png'
duration 2.5
file 'c04.png'
```

```bash
ffmpeg -f concat -safe 0 -i cframes.txt -t 6.9 \
  -vf "fps=12,split[s0][s1];\
[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 -y iteration-series.gif
```

Two quirks worth knowing, both handled above: the concat demuxer ignores the **last** entry's duration, which is why `c04.png` is listed twice; and that repeat would otherwise double the closing hold, which is why `-t` trims the total to the sum of the durations. Verified on ffmpeg 8.0 — the shipped asset lands at 6.91 s, 1280×804, 266 KB.

Over 5 MB? Drop `fps` to 10 before touching the width. Legible captions matter more than smooth motion in a four-frame loop.

## Variant — let the agent do it

For A10 you want the loop happening live rather than assembled. Same stage, but instead of `./step.sh N`, paste this once and let it run:

```text
The pricing card at http://localhost:5173/#/pricing is broken. Chrome runs it
with hot reload. Call list_tracked_windows first and use the window TITLE to
target it — never the process name, and never stack_position.

Goal: heading inside the card and wrapping, the billing period on the same
baseline as the amount, the button full width at the bottom.

1. Before your first edit: capture_tracked_window title "<title>",
   keyword "hero-before".
2. Fix ONE defect at a time in scenarios/app/src/overrides.css. After each
   edit: capture_tracked_window title "<title>", keyword "hero-iter-N", read
   the image, and state what is fixed and what is not.
3. Never capture_active_window, and never stack_position: 1 — both resolve to
   this terminal as soon as you run a shell command.
4. When the last capture matches the goal, keyword it "hero-after" and print
   the before/after file paths.
```

If it fixes everything in one pass, stop and re-run — the convergence is the asset. If it claims done without reading an image, that take is unusable.

## Embed

README (replacing the `TODO(assets): A2` placeholder) and the top of recipe 00:

```markdown
![The same pricing card captured after each code change, the layout converging on the intended design as the agent fixes one defect at a time](./assets/recipes/00-see-what-you-shipped/iteration-series.gif)
```

## Checklist

- [ ] Window geometry identical in all four frames
- [ ] Each frame visibly differs from the previous one
- [ ] Keywords burned in and legible at 1280 wide
- [ ] Nothing personal in the browser chrome
- [ ] Under 5 MB
- [ ] `./step.sh reset` afterwards
