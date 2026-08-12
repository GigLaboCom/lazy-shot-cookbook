# A10 — the 45-second demo

**Output:** ✅ **shot** — `assets/demo/lazy-shot-cookbook-demo.mp4`, 1920 × 1080, H.264, 45.000 s, 2.4 MB, no audio track at all.
**Also ships:** `lazy-shot-cookbook-demo-card.mp4`, the same video with a different opening beat — see [Two cuts](#two-cuts).
**Yields:** [A2](./A2-iteration-series.md) as a cut. Film this once and take both.

For the X thread, the product page, and the Show HN post. Silent, captioned, loopable.

## Rules

- **No voice-over.** It gets muted, and a video that needs sound to make sense makes no sense in a feed.
- **Captions at 58 px**, roughly 1/18th of frame height. That is the size that survives a phone.
- **The first four seconds must work as a silent autoplay thumbnail.**

## Beats

Each beat is a 1920 × 960 panel with the caption burned into a 120 px band underneath, so a recorded segment and a still drop into the same slot.

| Time | Beat | On screen | Caption |
| --- | --- | --- | --- |
| 0–4 s | The problem | The blind take: the agent reports the card fixed, and its own closing line says the edit also lands on two screens it never opened | *Agents ship UI changes blind.* |
| 4–14 s | The setup | MCP toggle · the `claude mcp add` line · `/mcp` scrolled live through all 23 tool names | *One command. 23 tools.* |
| 14–32 s | The loop | The A2 session, four cuts out of one take | *Now it looks before it says done.* |
| 32–40 s | The library | The four `hero-*` rows, then `search_screenshots` returning them by name | *Every step, named and searchable.* |
| 40–45 s | The close | Repo URL, product URL, the one-time price | *Give your agent eyes.* |

Beat 1 is cut from the recorder's own styled export rather than the raw capture — zoomed past the window title bars, which buys about 15% larger text in the one beat that is a paragraph of it. Its framing therefore differs slightly from beats 2 and 3. Check the export for a drawn mouse cursor before using it; the first one had an I-beam sitting in the middle of the paragraph.

## Beat 1, and why it is not what this page used to ask for

This page specified: *the agent's message claiming the layout is fixed, next to the broken card, the disagreement visible from frame one.*

**That beat was not shot, because it could not be shot honestly.** Four takes:

- Told to capture, the agent captured, read the image, and reported precisely what was still wrong. Twice. That is the product working, not the problem.
- Told **not** to capture, it found the repo's own `src/steps/fix-1..3.css`, ran `./step.sh 3`, and was right — then volunteered that it had not seen the rendered card.
- Told not to capture, against a copy of the app with the step files and the defect comments removed, it wrote plausible CSS from scratch and was broadly right again.

The premise assumed an agent that guesses badly. A capable one does not. What it cannot do is tell you what the change *looks* like — and in the fourth take it said so itself, in the frame that ships:

> Note this file affects all three routes — the `.card` padding and `.cta` width changes also apply to the checkout and settings screens. No screenshots taken, as asked.

That is beat 1: a real claim, a real blind spot, stated by the agent. Staging the original beat would have meant writing the agent's line for it, which [A2](./A2-iteration-series.md#variant--let-the-agent-do-it) forbids and which reads as staged anyway.

**If you re-shoot this:** strip the answers out of the app first. A blind take against an app that ships its own fixes tests nothing. Remove `src/steps/`, `step.sh`, and the `DEFECT N` comments in `base.css` from the copy you serve.

## Two cuts

The two files differ only in beat 1:

| File | Beat 1 |
| --- | --- |
| `lazy-shot-cookbook-demo.mp4` | The blind agent's claim, live |
| `lazy-shot-cookbook-demo-card.mp4` | The broken card alone — no agent, no claim |

The card cut reads faster as a thumbnail; the live cut carries the argument. Pick per placement rather than picking one forever.

## Staging

Two windows, side by side, neither moved once the take starts: Chrome on the left at 960 × 1012 points, the terminal on the right at 1064 × 1012, flush against it. The rectangle to record is **2024 × 1012 points**, exactly 2:1, which maps onto the 1920 × 960 content area with no letterboxing — after recording, only `scale=1920:-2` is needed.

Three privacy traps this shoot walked into, in the order they bite:

1. **The shell prompt.** Claude Code redraws it at the bottom of the window, which is where the eye goes. Run the demo in a shell with no rc file — `PS1='demo $ ' zsh -f` — in a scratch project, and set the window title too.
2. **The symlink.** Pointing the scratch project at the app through a symlink keeps absolute paths out of edits, but `ls -la` prints the link target in full. Copy the app instead of linking it.
3. **The agent's own report.** The first take ended with `- Before: /Users/…`, because the prompt asked for the before/after paths. Ask for keywords instead:

   ```text
   Never print an absolute file path — mine start with my home directory and
   this session is being recorded. Refer to captures by keyword only.
   ```

None of these is caught by a permission rule. The agent was entitled to read every one of those files; what reached the frame is what it *printed*.

## Cutting

Cut first, speed up second. The loop take ran 119 s for an 18 s slot; speeding the whole thing up 6.6× turns it into a blur. Four cuts at different speeds keep the verdicts readable:

| Cut | From the take | Speed | Length |
| --- | --- | --- | --- |
| 1 | 42–60 s | 6× | 3.0 s |
| 2 | 60–68 s | 2× | 4.0 s |
| 3 | 68–105 s | 9.25× | 4.0 s |
| 4 | 105–117 s | 1.71× | 7.0 s |

Fast where the machine is only typing; near real time on the two moments the viewer has to read.

## Export

1920 × 1080, H.264, 30 fps, **no audio track at all** — not a silent one, stripped.

Encode each beat to its own mp4 and concatenate with `-c copy`:

```bash
ffmpeg -y -loop 1 -framerate 30 -i frames/01-problem.png -t 4.0 \
  -c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p -an seg/01.mp4
ffmpeg -f concat -safe 0 -i beats.txt -c copy -movflags +faststart -y out.mp4
```

**Not the concat demuxer over stills**, which is what the GIF assets use. Its per-entry `duration` does not survive an H.264 encode: a 45 s beat sheet came out 35 s, silently, with no warning from ffmpeg. Per-beat encoding makes every hold exactly what you asked for, and a recorded segment then drops into a slot without touching anything else.

Check with frames, not seconds:

```bash
ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=nb_read_frames -of csv=p=0 out.mp4
```

1350 at 30 fps. `+faststart` matters — without it the video will not start playing until fully downloaded, which in a feed means it does not play.

## Checklist

- [x] Works muted, start to finish
- [x] First four seconds legible as a still
- [x] Captions readable at phone size — 58 px
- [x] No audio track — `nb_streams=1`
- [x] `+faststart` applied
- [x] Under 20 MB — 2.4 MB and 2.1 MB
- [x] Nothing personal in shell prompt, browser chrome, or the library rows — every take OCR'd at one frame per second
