# Asset production kit

Everything needed to shoot the cookbook's ten assets: a deliberately broken demo app, and one scenario file per asset with the exact steps, prompts, code and expected output.

The spec — filenames, sizes, embed snippets — is in [docs/ASSETS.md](../docs/ASSETS.md). This directory is the *how*.

## The demo app

`app/` is a three-screen web app whose defects are load-bearing. Do not fix them in the repository: fixing them on camera is the asset.

```bash
cd scenarios/app
npm install
npm run dev          # http://localhost:5173
```

### Moving between states

`step.sh` puts the app into the exact state a frame needs. Vite's hot reload applies it instantly, so a capture taken right after the command lands on the new state — which is what makes frames deterministic enough to stitch.

```bash
./step.sh 0                 # pricing: all three defects
./step.sh 1                 # pricing: heading fixed
./step.sh 2                 # pricing: + price baseline fixed
./step.sh 3                 # pricing: all fixed — the "after" state
./step.sh checkout-broken   # checkout totals render as NaN
./step.sh checkout-fixed    # checkout totals render correctly
./step.sh reset             # back to the shipped state
./step.sh status            # what state am I in
```

The CSS fixes live in `src/steps/fix-1..3.css` and are concatenated into `src/overrides.css`; the checkout fix is a single line swapped in `src/main.js`. Nothing is edited by hand.

### The screens

| Screen | URL | What's wrong with it | Used by |
| --- | --- | --- | --- |
| Pricing | `#/pricing` | Three layout defects: the heading overflows the card, the billing period drops to its own line, the button is a narrow stub hugging the left edge | A2, A10 |
| Checkout | `#/checkout` | A percentage string is multiplied instead of parsed, so the discount and total render as `-€NaN` / `€NaN` | A4 |
| Settings | `#/settings` | Nothing — it's the subject for documentation markers | A3 |
| Error dialog | Checkout → *Pay* | A modal with `user-select: none` and monospace identifiers. Unselectable by design: it's the reason recipe 05 exists | A7 |

Verified against Vite 7.3.6 / Node 22.

## Shooting order

**A2 → A10 → A7 → A8 → A9 → A4 → A1 → A3 → A6 → A5.**

A2 is a cut out of A10, so record that session once and take both. A7's dialog appears in the same app you already have open for A4.

## The scenarios

| File | Asset | Needs the app? | Shot |
| --- | --- | --- | --- |
| [A1-og-image.md](./A1-og-image.md) | Social preview | No | ✅ |
| [A2-iteration-series.md](./A2-iteration-series.md) | The converging loop | Yes — pricing | ✅ |
| [A3-annotated-flow.md](./A3-annotated-flow.md) | Docs with markers | Yes — settings | ✅ |
| [A4-before-after.md](./A4-before-after.md) | Bug evidence pair | Yes — checkout | ✅ |
| [A5-session-replay.md](./A5-session-replay.md) | Navigation flight recorder | No — a real site | ✅ |
| [A6-sweep-grid.md](./A6-sweep-grid.md) | Batch capture contact sheet | No — your open windows | ✅ |
| [A7-ocr-to-markers.md](./A7-ocr-to-markers.md) | OCR boxes → markers | Yes — error dialog | ✅ |
| [A8-A9-setup-shots.md](./A8-A9-setup-shots.md) | Setup screenshots | No — Lazy Shot itself | ✅ |
| [A10-demo-video.md](./A10-demo-video.md) | 45-second demo | Yes — pricing | ⬜ |

## Before you start

- **Lazy Shot running, MCP enabled**, licence active. Several scenarios spend more than ten tool calls.
- **Light theme**, both in Lazy Shot and the OS. Notifications off (macOS: Focus).
- **Browser window pinned** at a fixed size and never moved or resized mid-scenario. This is the single most common way a shoot gets ruined.
- **A clean screenshot library**, or at least a mental note of where the run starts — several scenarios end with a filtered library view in frame.
- Reset the app between takes with `./step.sh reset`.

## Stitching frames with ffmpeg

Every animated asset is built from stills rather than a screen recording: each frame is reshootable on its own, and the timing is exact instead of lucky.

Export the frames at **identical dimensions**, name them `01.png … NN.png`, and write a concat list with the hold time for each:

```text
# frames.txt
file '01.png'
duration 1.6
file '02.png'
duration 1.4
file '03.png'
duration 2.5
file '03.png'
```

**GIF:**

```bash
ffmpeg -f concat -safe 0 -i frames.txt -t 5.5 \
  -vf "fps=12,scale=1280:-2:flags=lanczos,split[s0][s1];\
[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 -y out.gif
```

**MP4 from the same stills:**

```bash
ffmpeg -f concat -safe 0 -i frames.txt -t 5.5 \
  -vf "fps=30,scale=1920:-2:flags=lanczos" \
  -c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart -an \
  -y out.mp4
```

Two quirks, both handled above:

- **The concat demuxer ignores the last entry's `duration`.** Hence the final file being listed twice.
- **That repeat then doubles the closing hold.** Hence `-t`, set to the sum of the durations. Without it your 5.5-second loop runs 8 seconds and ends on a long dead frame.

Both commands verified on ffmpeg 8.0. Check the result with:

```bash
ffprobe -v error -show_entries format=duration -of csv=p=0 out.gif
```

It should land within one frame of your `-t` value.

Size: if a GIF exceeds 5 MB, lower `fps` before lowering the width — legible keyword captions matter more than smooth motion in a six-frame loop.

## Resetting after a take

```bash
cd scenarios/app && ./step.sh reset
```

If anything was edited by hand:

```bash
git checkout scenarios/app/src
```

Captures you don't want are soft-deleted, not destroyed:

```text
search_screenshots "hero-iter" then delete_screenshot each result
```
