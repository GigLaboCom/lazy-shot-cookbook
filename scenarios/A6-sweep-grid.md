# A6 — the release sweep contact sheet

**Output:** ✅ **shot** — `assets/recipes/04-release-day-batch-capture/sweep-grid.png`, 1280 × 632, 136 KB.

One command, a set of named artifacts. The asset is about *volume and naming* — the individual tiles don't need to be readable, the keywords do.

## Prerequisite

The **Window Activity Tracker** must be on: Settings → Experimental. Without it `list_tracked_windows` returns nothing and the recipe has no input.

## The tracker only sees you switching apps

This is the thing to understand before staging anything, and it decides how the shoot goes.

On macOS the tracker listens to `NSWorkspaceDidActivateApplicationNotification`: it fires when you move between **applications**, and records whichever window of the newly active app is in front. Moving between two windows of the *same* app writes nothing.

So opening six browser windows does not give you six rows. It gives you one — the window that happened to be frontmost the last time you switched into the browser. Raising windows from a script doesn't help either; `set index of window N to 1` reorders Chrome without telling the OS anything.

What does work, and what this shoot used for every tile:

```applescript
-- raise the window you want, leave the app, come back
tell application "Google Chrome"
  activate
  repeat with w in windows
    if bounds of w is {40, 100, 740, 680} then set index of w to 1
  end repeat
end tell
delay 0.4
tell application "Finder" to activate
delay 1.2
tell application "Google Chrome" to activate
delay 1.4
```

Register the windows in a known order and the stack comes out in reverse of it. Which matters, because:

## Three windows, one title

The demo app is hash-routed, so `#/pricing`, `#/checkout` and `#/settings` all report `<title>Northwind Analytics</title>`. Three rows in the tracker, identical text, and `capture_window` cannot tell them apart — it has nothing but the title to match on.

`capture_tracked_window` can. It resolves the stack entry to an **OS window handle** and captures that handle; the title is only a fallback for when the handle is gone. So:

```text
capture_tracked_window stack_position 6, keyword "v1-pricing"
capture_tracked_window stack_position 5, keyword "v1-checkout"
capture_tracked_window stack_position 4, keyword "v1-settings"
```

Three different windows, one title, correct every time. Verify anyway — compose a quick strip of the captures and look at it before building the real sheet. Positions move whenever anything gets focused, and re-listing costs one call.

## What went in the grid

Six windows, all of them surfaces this project is responsible for:

| Keyword | Window |
| --- | --- |
| `v1-pricing` | demo app, pricing |
| `v1-checkout` | demo app, checkout — **every total renders as `€NaN`** |
| `v1-settings` | demo app, workspace settings |
| `v1-product-page` | the Lazy Shot product page |
| `v1-google` | a plain browser window |
| `v1-library` | Lazy Shot's own library |

The bad tile is real. `./step.sh checkout-broken` leaves `subtotal * '10%'` in the code, so the discount, the total and the button all read `€NaN` — a sweep run against that build finds it in one glance. That is the whole argument for the recipe: a perfect grid says "we took six screenshots"; a grid with one wrong tile says "we took six screenshots and found something".

**Six, not twelve.** This page used to ask for a 4 × 3 grid. At 1280 wide, twelve tiles are 298 px each and `€NaN` disappears; at six they are 401 px and it reads. The grid's job is not to be read — it is to make you *open* the one that looks wrong — but the tile that carries the finding still has to carry it.

## Curate before you shoot, not after

Everything in this grid ends up in a public repository, and window chrome carries more than the window does. Two things were cut from this shoot after looking at the captures at full size:

- A **Finder** tile showed the account name in the sidebar — a work email address and the machine's hostname — from a folder listing that had looked harmless.
- Every browser tile carried the **bookmarks bar**: a `Managed Bookmarks` folder, which says the profile belongs to a managed device, plus two bookmark titles.

What matters is **readable text** — addresses, folder and bookmark names, window titles, hostnames. A profile avatar showing one letter is not worth a re-shoot; a bookmark called after a client is.

The bookmarks bar turned out to be surprisingly hard to remove, so save yourself the detour:

- `Cmd+Shift+B` works, but only from your own hands. Sent through AppleScript's `System Events` it needs Accessibility permission and **fails silently** without it — and a silent failure means the second press, the one meant to put the bar back, toggles a setting you never changed.
- **Incognito does not help.** The bar is a global Chrome setting and incognito windows show it too. It does drop the profile avatar, which is the thing that didn't matter.
- **Guest mode does** hide it — and opens on Chrome's "Choose Your Search Engine" screen, which needs a click to get past. `--disable-search-engine-choice-screen` is ignored when an instance is already running.

So the tiles here are **cropped to the page**, below the whole toolbar. That is a plain crop, not a splice: nothing is stitched back together, and the sheet shows six screens rather than six window frames. If your bookmarks bar is already off, keep the chrome — it reads better.

The general rule stands: close anything with a client name, a private repo, an inbox, or a chat in it, and read every tile at full size before it goes into the sheet.

## The prompt

```text
Run a release sweep for v1:
1. list_tracked_windows.
2. Show me the list; let me strike anything irrelevant.
3. For each remaining window: capture_tracked_window with keyword
   "v1-<app-or-screen-slug>".
4. Output a checklist: keyword → file_path → [ ] looks right.
```

Step 2 matters on camera as much as off it: the human curating the list is the honest version of this workflow — and, given what the tracker records, the only version. An agent cannot conjure the window list into existence.

## Composing the sheet

Tiles are laid out 3 × 2 at a uniform 401 × 262 box with the keyword under each. Windows come in wildly different aspect ratios, so fit them into the box with letterboxing rather than cropping to fill:

```css
.tile { display: flex; align-items: center; justify-content: center; background: #eef1f5; }
.tile img { max-width: 100%; max-height: 100%; }
```

Cropping to *fill* the box is the thing to avoid: it takes a bite out of whichever edge doesn't fit, and at 400 px the proportions are most of how you recognise a tile. Cropping the toolbar away before the tile goes in the box is a different act and fine — every tile is then framed the same way.

## Embed

Recipe 04, replacing the `TODO(assets): A6` placeholder:

```markdown
![Six application windows captured in a single sweep and laid out as a contact sheet, each tile labelled with its version-prefixed keyword, one of them showing a currency total rendered as NaN](../../assets/recipes/04-release-day-batch-capture/sweep-grid.png)
```

## Checklist

- [x] Every tile captioned with its keyword; captions not cropped
- [x] Nothing confidential in any tile — checked at full size; one tile cut, the toolbars cropped
- [x] Uniform tile geometry, letterboxed rather than cropped
- [x] One tile is obviously wrong, and wrong for a real reason
- [x] Under 1 MB
