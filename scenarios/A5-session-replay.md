# A5 — the flight recorder

**Output:** `assets/recipes/03-complex-site-navigation/session-replay.gif`, ~10 s, 1280 wide, under 5 MB.

The claim: every step of an agent's navigation session survives as a named artifact. The asset must show the library *filling up*, not the browser doing things.

## Subject

A real multi-step flow on a site you control or one that tolerates automation — your own staging environment, a public docs site with a search-and-filter path, or a demo shop. Five steps is enough.

Avoid anything with a login, a paywall, or a cookie wall in frame.

## Stage

```text
┌──────────────────────────┬───────────────────────────┐
│  Chrome — the site       │  Lazy Shot — library list │
│  (left, PINNED)          │  (right, visible always)  │
└──────────────────────────┴───────────────────────────┘
```

Lazy Shot's window on the right, library list in view, sorted newest first, so each new row appears at the top as it lands. This half is the actual subject — frame it accordingly.

You need a browser automation tool for the hands: Playwright MCP, a browser extension, whatever you run. Lazy Shot is only the eyes.

## Frames

Six frames, each a capture of the whole stage — browser on the left, library on the right — so the accumulating rows are visible in every one.

**`capture_display` puts your entire monitor in a public repository.** Before the first frame: close everything else, clear the menu bar, and check the desktop background. If that's not practical, capture the two windows separately and compose each frame as a pair in the Compositor.

| # | Do this first | Prompt to paste | Keyword | Hold |
| --- | --- | --- | --- | --- |
| 01 | Agent performs action 1 | `capture_window query "Google Chrome", keyword "checkout-step-1". Then capture_display 0, keyword "replay-frame-1".` | `checkout-step-1` | 1.6 s |
| 02 | Action 2 | `capture_window query "Google Chrome", keyword "checkout-step-2". Then capture_display 0, keyword "replay-frame-2".` | `checkout-step-2` | 1.4 s |
| 03 | Action 3 | `capture_window query "Google Chrome", keyword "checkout-step-3". Then capture_display 0, keyword "replay-frame-3".` | `checkout-step-3` | 1.4 s |
| 04 | Action 4 | `capture_window query "Google Chrome", keyword "checkout-step-4". Then capture_display 0, keyword "replay-frame-4".` | `checkout-step-4` | 1.4 s |
| 05 | Action 5 — **let this one land somewhere unexpected** | `capture_window query "Google Chrome", keyword "checkout-step-5". Capture it anyway and say what went wrong. Then capture_display 0, keyword "replay-frame-5".` | `checkout-step-5` | 1.8 s |
| 06 | Filter the library to `checkout-step` | `search_screenshots "checkout-step" and print keyword to file_path in order.` then `capture_display 0, keyword "replay-frame-6"` | — | 2.5 s |

The `replay-frame-N` captures are the GIF; the `checkout-step-N` ones are what the recipe is actually about, and they're what shows up as new rows on the right.

Step 5 going wrong is deliberate. A sequence where everything works shows an automation demo; one where something breaks and the evidence is *already on disk* shows what the recipe is for.

## Running it

You need a browser automation tool for the hands — Playwright MCP, an extension, whatever you run. Lazy Shot is only the eyes. Standing instruction for the session:

```text
You navigate with <your browser tool> for actions and Lazy Shot for vision.
After every action, capture per the frame table. Read each capture before
deciding the next action. Five steps. If a step lands somewhere unexpected,
capture it anyway and say so — do not retry silently.
```

## Stitch

Export `replay-frame-1..6` at identical dimensions as `01.png` … `06.png`:

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
duration 1.8
file '06.png'
duration 2.5
file '06.png'
```

```bash
ffmpeg -f concat -safe 0 -i frames.txt -t 10.1 \
  -vf "fps=12,scale=1280:-2:flags=lanczos,split[s0][s1];\
[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 -y session-replay.gif
```

`-t` is the sum of the durations; the last frame is listed twice because the concat demuxer ignores the final entry's duration. See [the stitching notes](./README.md#stitching-frames-with-ffmpeg).

## If it's too big

Over 5 MB: drop `fps` to 10 before touching the width. Legible keywords matter more than smooth motion.

## Embed

Recipe 03, replacing the `TODO(assets): A5` placeholder:

```markdown
![Five browser steps captured in sequence, each appearing as a named row in the Lazy Shot library, forming a replayable log of one navigation session](../../assets/recipes/03-complex-site-navigation/session-replay.gif)
```

## Checklist

- [ ] Library half is in frame the whole time
- [ ] Keywords readable at final size
- [ ] The failed step is captured, not skipped
- [ ] No login screens, personal accounts, or cookie banners in frame
- [ ] Final held frame shows the filtered set, in order
