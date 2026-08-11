# A6 — the release sweep contact sheet

**Output:** `assets/recipes/04-release-day-batch-capture/sweep-grid.png`, 1280 wide, under 1 MB.

One command, a dozen named artifacts. The asset is about *volume and naming* — the individual tiles don't need to be readable, the keywords do.

## Prerequisite

The **Window Activity Tracker** must be on: Settings → Experimental. Without it `list_tracked_windows` returns nothing and the recipe has no input.

Then use your machine normally for a few minutes — open the windows you'd actually sweep on release day. Ten to twelve is the right number for a 4×3 grid.

Curate before shooting: everything in this grid ends up in a public repository. Close anything with a client name, a private repo, an inbox, or a chat in it.

## The prompt

```text
Run a release sweep for v1.4:
1. list_tracked_windows.
2. Show me the list; let me strike anything irrelevant.
3. For each remaining window: capture_tracked_window with keyword
   "v1-4-<app-or-screen-slug>".
4. Output a checklist: keyword → file_path → [ ] looks right.
```

Step 2 matters on camera as much as off it: the human curating the list is the honest version of this workflow.

## Composing the sheet

The tiles come out of one agent run, so there is one prompt, not one per tile. Caption each tile with its returned keyword before laying them out:

```text
For every capture from the sweep, print keyword → file_path as a plain list
so I can caption them in order.
```

Arrange the captures as a 4×3 contact sheet in the Compositor. Uniform tile size, small gutters, each tile captioned with its keyword (`v1-4-settings`, `v1-4-editor`, …).

Tiles will have wildly different aspect ratios. Fit them to a uniform tile with letterboxing rather than cropping to fill — a cropped tile loses the window's identity, which is the one thing each tile needs to keep.

## Optional, and worth it

Include one tile that is obviously *wrong* — a window that shouldn't have been in the release, or one showing a stale version string. A perfect grid says "we took twelve screenshots". A grid with one bad tile says "we took twelve screenshots and found something", which is why anyone would run the sweep.

## Embed

Recipe 04, replacing the `TODO(assets): A6` placeholder:

```markdown
![A twelve-tile contact sheet of application windows captured in a single release sweep, each tile labelled with its version-prefixed keyword](../../assets/recipes/04-release-day-batch-capture/sweep-grid.png)
```

## Checklist

- [ ] Every tile captioned with its keyword; captions not cropped
- [ ] Nothing confidential in any tile — check each one at full size before composing
- [ ] Uniform tile geometry
- [ ] Under 1 MB (WebP if not)
