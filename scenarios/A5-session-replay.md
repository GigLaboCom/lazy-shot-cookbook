# A5 — the flight recorder

**Output:** ✅ **shot** — `assets/recipes/03-complex-site-navigation/session-replay.gif`, 1280 × 650, 9.3 s, 483 KB.

The claim: every step of an agent's navigation session survives as a named artifact. The asset must show the library *filling up*, not the browser doing things.

## Subject

A real multi-step flow on a site you control or one that tolerates automation. This shoot used **`books.toscrape.com`** — a sandbox built for scraping practice, so there is no login, no paywall and no cookie wall to keep out of frame, and no question of whether the traffic is welcome.

Five steps:

| # | Action | Keyword |
| --- | --- | --- |
| 1 | Open the catalogue | `books-step-1` |
| 2 | Filter to Travel — 11 results | `books-step-2` |
| 3 | Open *It's Only the Himalayas* — In stock (19 available) | `books-step-3` |
| 4 | Back to the listing, scrolled to that book's **Add to basket** | `books-step-4` |
| 5 | Click it | `books-step-5` |

## The failure has to be real

Step 5 is where the asset earns its place, and a staged failure would be worth nothing. This one is in the site:

```html
<form>
  <button type="submit" class="btn btn-primary btn-block"
          data-loading-text="Adding...">Add to basket</button>
</form>
```

A `<form>` with no `action`. Submitting it issues a GET to the page it is already on. So a coding agent reading the DOM sees a submit button that advertises its own loading state — `data-loading-text="Adding..."` — on an item that says **In stock (19 available)**, and concludes the item went into a basket.

What actually happens: the page reloads, the scroll position resets, `location.href` gains a bare `?`, and that is the entire effect. There is no basket page on the site and no link to one. Nothing on screen says so.

That is the recipe's thesis in one click — the DOM promised, the render didn't, and the only thing that noticed was the capture.

## Stage

Two windows, both visible, neither moved for the duration:

- **The browser**, fixed size, on its own — not a window that also holds your mail. Everything above the viewport gets cropped away here anyway, and it should: pinned tabs, the bookmarks bar and Chrome's own "started debugging this browser" infobar are all in frame otherwise.
- **Lazy Shot**, library list in view, sorted newest first, so each new row appears at the top as it lands. This half is the actual subject.

`capture_display` would put your entire monitor in a public repository. Don't. Capture the two windows separately and compose each frame as a pair — the compositing is one `ffmpeg` crop each, and the privacy problem disappears instead of being cropped around.

## Delete each recording frame as you take it

The thing that ruins this asset on the first attempt: **a capture of the library becomes a row in the library.** Shoot the browser, then shoot the library, and by frame 2 the list reads

```text
replay-frame-1
books-step-1
```

and by frame 5 half the visible rows are the recording of the recording. The list stops showing "five named steps" and starts showing noise.

Fix: `delete_screenshot` the `replay-frame-N` capture immediately after taking it. The delete is soft — the row leaves the Active filter, the PNG stays on disk, and your next frame sees only the steps. Take the file path from the capture response before you delete; you are going to `ffmpeg` it, not re-open it.

The same trap applies in reverse to what is *already* in the library. Leaving the previous session's rows in frame is fine and arguably better — watching them get pushed down one by one is the fill-up made visible.

## Frames

| # | Prompt to paste | Then | Hold |
| --- | --- | --- | --- |
| 1 | `capture_window query "<site title>", keyword "books-step-1"` | `capture_window query "Heretic Lazy Shot", keyword "replay-frame-1"`, then delete it | 1.8 s |
| 2 | Action 2, then the same pair with `-2` | ″ | 1.5 s |
| 3 | Action 3, then the same pair with `-3` | ″ | 1.5 s |
| 4 | Action 4, then the same pair with `-4` | ″ | 1.5 s |
| 5 | **Click**, then the same pair with `-5` | ″ | 3.0 s |

Query the browser by **window title**, not `"Google Chrome"` — the page title is what makes it specific, and on this site every page carries `Books to Scrape`.

Standing instruction for the session:

```text
You navigate with <your browser tool> for actions and Lazy Shot for vision.
After every action, capture per the frame table. Read each capture before
deciding the next action. Five steps. If a step lands somewhere unexpected,
capture it anyway and say so — do not retry silently.
```

## Compose

Each frame is two crops on a white card, 1280 × 650, captioned:

```bash
# Browser: the viewport only, no window chrome.
ffmpeg -y -i step-N.png   -vf "crop=1152:796:24:194" bN.png
# Library: thumbnail + ID + KEYWORD, header plus five rows, cut on a row edge.
ffmpeg -y -i frame-N.png  -vf "crop=790:1172:856:270" lN.png
```

Recompute both for your window sizes; the numbers above are for a 1200 × 1000 browser window on a 1× display and Lazy Shot at 1862 points wide on a 2× display. Two rules survive the arithmetic: crop the library **on a row boundary** so the last row isn't sliced, and keep each panel's crop aspect equal to the aspect you scale it into, or the page stretches.

The panels want unequal widths. The library is the subject and its keywords have to stay at roughly native size, so it gets whatever width that costs — 388 px here — and the browser takes the rest. Browser text ends up around 0.7× native, which is enough to see *which* page you're on, and that is all the left half has to say.

Frames are then stitched with the concat demuxer, as in [A2](./A2-iteration-series.md#stitch):

```bash
ffmpeg -f concat -safe 0 -i frames.txt -t 9.3 \
  -vf "fps=12,scale=1280:-2:flags=lanczos,split[s0][s1];\
[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 -y session-replay.gif
```

`-t` is the sum of the durations; the last frame is listed twice because the concat demuxer ignores the final entry's duration. See [the stitching notes](./README.md#stitching-frames-with-ffmpeg).

## What changed from the original plan

- **Six frames became five.** The sixth was to be the library filtered to the step keyword, which needs typing into the app's KEYWORD box — there is no MCP call for it, and the held final frame already shows all five steps in order at the top of the list.
- **`capture_display` was dropped entirely** in favour of composing window pairs. See above.
- **The URL bar is not in frame.** It is the one place the `?` from step 5 shows up, and keeping it would mean keeping the tab strip and bookmarks bar too. The caption carries it instead, which is the honest trade: the browser half of frame 5 looks exactly like frame 2, and that *is* the finding.

## If it's too big

Over 5 MB: drop `fps` to 10 before touching the width. Legible keywords matter more than smooth motion. This one came in at 483 KB, so there was nothing to trade.

## Embed

Recipe 03, replacing the `TODO(assets): A5` placeholder:

```markdown
![Five steps through a bookshop site, each one landing in the Lazy Shot library as a named row, so the whole session is on disk before anyone asks what went wrong](../../assets/recipes/03-complex-site-navigation/session-replay.gif)
```

## Checklist

- [x] Library half is in frame the whole time
- [x] Keywords readable at final size
- [x] The failed step is captured, not skipped
- [x] No login screens, personal accounts, or cookie banners in frame
- [x] Final held frame shows all five steps, in order
- [x] No `replay-frame-N` rows visible in any frame
