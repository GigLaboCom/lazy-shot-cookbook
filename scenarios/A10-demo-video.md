# A10 — the 45-second demo

**Output:** `assets/demo/lazy-shot-cookbook-demo.mp4`, 1920×1080, H.264, under 20 MB.
**Yields:** [A2](./A2-iteration-series.md) as a cut. Film this once and take both.

For the X thread, the product page, and the Show HN post. Silent, captioned, loopable.

## Rules

- **No voice-over.** It gets muted, and a video that needs sound to make sense is a video that makes no sense in a feed.
- **Captions large enough to read on a phone.** Roughly 1/18th of frame height.
- **The first three seconds must work as a silent autoplay thumbnail.** That means the disagreement between the agent saying "done" and the window plainly not being done has to be visible immediately, with no setup.

## Beats

| Time | Beat | On screen | Caption |
| --- | --- | --- | --- |
| 0–5 s | The problem | The agent's message claiming the layout is fixed, next to the broken pricing card. Hold long enough to read both | *Agents ship UI changes blind.* |
| 5–12 s | The setup | Settings → MCP toggle. Then one line typed: `claude mcp add --transport http lazy-shot http://localhost:5055/mcp`. Then `/mcp` listing the tools | *One command. 23 tools.* |
| 12–30 s | The loop | The [A2](./A2-iteration-series.md) session uncut: edit → repaint → capture → the agent reads the image and names what's still wrong → repeat → done | *Now it looks before it says done.* |
| 30–40 s | The library | The library showing `hero-before`, `hero-iter-1..3`, `hero-after` with keywords readable. Then `search_screenshots "hero"` recalling the set by name | *Every step, named and searchable.* |
| 40–45 s | The close | The cookbook README on screen: repo URL, and the one-time price | *Give your agent eyes.* |

## Staging for beat 1

Get the "done" claim and the broken card in the same frame from frame one. The easiest honest way: run the A2 prompt, let the agent make its first edit, and stop it mid-loop — you'll have a real message about a change alongside a card that is still visibly wrong. Don't script a fake claim; the real transcript reads differently and people can tell.

## Beat 2 details

Type the command at human speed. A pasted command that appears instantly reads as a mock-up. The `/mcp` output at the end is the proof — hold it for a full second so the tool count registers.

## Beat 4 details

This beat exists to sell the library, which the loop beat doesn't show. The keywords must be legible; zoom the Lazy Shot window rather than shrinking the type. The `search_screenshots` call at the end is the "days later, by name" argument compressed into two seconds.

## Two ways to build it

**Recorded.** Screen-record beats 1–5 in one take, then trim. Best for beat 3, where the point is that a real loop runs at a real pace.

**Assembled.** Beats 1, 2, 4 and 5 are all essentially stills with captions; only beat 3 needs motion. Shoot those four as captures, stitch them with the concat list, and splice the recorded beat 3 in between. This gives exact beat timings and lets you re-shoot one beat without re-filming the rest — see [the stitching notes](./README.md#stitching-frames-with-ffmpeg).

For beat 3 in the assembled route, the six A2 frames work directly: hold each 2.5–3 s to fill the eighteen seconds.

## Export

1920×1080, H.264, 30 fps, no audio track at all (not a silent one — strip it).

From a recording:

```bash
ffmpeg -i raw.mov -an -vf "scale=1920:-2" -c:v libx264 -crf 20 -preset slow \
  -pix_fmt yuv420p -movflags +faststart -y lazy-shot-cookbook-demo.mp4
```

From stills:

```bash
ffmpeg -f concat -safe 0 -i beats.txt -t 45 \
  -vf "fps=30,scale=1920:-2:flags=lanczos" \
  -c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p -movflags +faststart -an \
  -y lazy-shot-cookbook-demo.mp4
```

To join a recorded beat with assembled ones, render each part with the same codec and settings, then concat the results:

```bash
printf "file 'part1.mp4'\nfile 'part2.mp4'\nfile 'part3.mp4'\n" > parts.txt
ffmpeg -f concat -safe 0 -i parts.txt -c copy -movflags +faststart -y lazy-shot-cookbook-demo.mp4
```

`+faststart` matters — without it the video won't begin playing until it's fully downloaded, which on a feed means it doesn't play.

Cut beat 3 out for A2 rather than shooting it twice.

## Checklist

- [ ] Works muted, start to finish
- [ ] First three seconds legible as a still
- [ ] Captions readable at phone size
- [ ] No audio track
- [ ] `+faststart` applied
- [ ] Under 20 MB
- [ ] Nothing personal in shell prompt, browser chrome, or the library rows
