# Recipe 06 — Visual regression watch

> **Status: proposed.** The workflow below is complete and internally consistent, but hasn't been through a full validation pass yet. Kick the tires and [tell us what breaks](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml).

**Problem:** web frontends get Percy and Chromatic and still ship visual bugs. Desktop apps and internal tools get *nothing* — no visual testing at all, because standing up pixel-diff CI infrastructure for a Tauri, Electron or Qt app is nobody's idea of a sprint well spent.

**Idea:** a two-tier diff with zero infrastructure. Tier 1 is a pixel gate the agent runs in its own shell (ImageMagick). Tier 2 is agent vision explaining *what* changed in human terms. Lazy Shot provides stable, named, versioned captures on both sides.

## The loop

```text
baseline: capture_window (keyword "<screen>-v1") ──▶ record in baselines.txt
                                                             │
   change ships ──▶ capture_window (keyword "<screen>-v2")   │
                                     │                       │
              tier 1: magick compare (pixel gate) ◀──────────┘
                                     │
              tier 2: agent reads both file paths, explains the diff
                                     │
              add_markers on the candidate flagging changed zones
                                     │
     accept → v2 becomes the baseline   |   reject → recipe 02: "-before" already exists
```

## Copy-paste prompt (Claude Code)

```text
Visual check for "<screen>" of <app>:
1. Read baselines.txt for the current baseline keyword; search_screenshots
   for it and note the file_path.
2. capture_window with query "<app>" and keyword "<screen>-v<N+1>"
   (use the returned keyword).
3. Tier 1 — run in shell:
   magick compare -metric AE <baseline_path> <candidate_path> /tmp/diff.png
   If the metric is 0, report "no change" and stop.
4. Tier 2 — read both images. Describe every difference in plain language:
   moved or resized elements, changed labels, truncation, colour shifts,
   spacing. Ignore rendering noise (font antialiasing, cursor).
5. add_markers on the candidate numbering each real difference; give me
   the marker layer's file_path, the coordinate of each numbered
   difference, and your verdict: intended or regression?
6. If I say "accept": update baselines.txt to the new keyword.
   If I say "regression": this capture is already the "-before" evidence —
   continue per recipe 02.
```

## Catching text regressions without vision at all

Vision is the expensive tier. For a large class of regressions — truncated labels, an untranslated string, a currency symbol that vanished, a locale that fell back to English — the text alone is enough:

```text
Between steps 3 and 4: ocr_screenshot both the baseline and the candidate,
diff the two transcripts, and report added/removed/changed strings before
you look at either image.
```

A text diff costs nothing, runs on-device, and pins down the exact string that changed. Save vision for the differences that are actually visual.

## Making captures comparable

Stability is the whole game. In descending order of robustness:

- **`capture_window` by process name** — survives window *position* changes, breaks on window *size* changes. Pin the app to a fixed size for checks.
- **`capture_region` with coordinates from `list_displays`** — pixel-stable framing, breaks if the window moves. Best on a dedicated test machine or VM where nothing moves.
- Same display every time (DPI and scale differences between monitors will fail tier 1 forever), same theme, same locale.
- Crop live clocks and timestamps out of the region, or accept that tier 1 always fires and lean on tier 2's judgment.

## What each tier honestly catches

- **Tier 1 (ImageMagick)** is exact and dumb: any changed pixel trips it, antialiasing noise included. Its only job is to let "nothing changed" runs exit in a second without spending vision tokens.
- **Tier 2 (agent vision)** is semantic and approximate: excellent at "the Save button moved below the fold", "this label truncates in German", "dark mode leaks white here"; unreliable for 1-pixel shifts and exact measurements. If you need certified pixel-perfection, you need Percy. This recipe is for the 95% of apps that currently have nothing.

## Tools used

`capture_window` · `capture_region` · `list_displays` · `assign_keyword` · `search_screenshots` · `get_screenshot` · `ocr_screenshot` · `add_markers` — plus `magick compare` in the agent's shell (install ImageMagick).

## Gotchas

- There is no rename tool, so baselines are versioned keywords (`-v1`, `-v2`, …) with the *current* one tracked in a plain `baselines.txt` in your repo. Boring and reliable.
- Keyword collisions auto-suffix; always write the *returned* keyword into `baselines.txt`.
- Soft delete means every rejected candidate stays in the library — that's your regression history, for free.
- `magick compare` exits non-zero when images differ; if your agent's shell wrapper treats that as a failure, capture the metric explicitly rather than trusting the exit code.
