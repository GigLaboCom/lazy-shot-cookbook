# MCP tool reference

Every tool Heretic Lazy Shot exposes over MCP, with its real parameters. Verified against **app version 0.0.8**.

Surface: **23 tools · 4 resources · 2 prompts**. Nothing here is aspirational — if a capability isn't listed, it doesn't exist, and a recipe that needs it belongs in an issue rather than a PR.

Every tool call is gated by the app licence, and on the free tier it also draws down a daily quota. Read [that section](./SETUP.md#licence-and-the-free-tier-quota) before designing a loop that calls tools in bulk.

**Conventions used throughout**

- Any parameter named `id` or `screenshot_id` accepts **either** the integer ID **or** the keyword. Keywords are the ergonomic choice.
- Every capture tool accepts a `keyword` and labels the shot in the same call — there is no reason to capture and then call `assign_keyword` separately.
- Keyword collisions are resolved by the server with a numeric suffix. **The returned keyword is the truth**, not the requested one.
- Responses reference images by `file_path`. No tool ever returns image bytes. → [why](../principles/FILE-PATHS-NOT-BASE64.md)

**Jump to** — [Capture](#capture-7) · [Manage](#manage-8) · [Markers & compositor](#markers--compositor-5) · [OCR](#ocr-3) · [Resources](#resources-4) · [Prompts](#prompts-2) · [Errors](#errors)

## Capture (7)

Captures are headless and silent: no overlay, no editor, and the main window is not brought forward (the app only refreshes its library list in the background). There is currently no on-screen indicator that a capture happened — the audit trail is the log. A successful capture returns `{ id, file_path, width, height, keyword? }`.

### `capture_region`

Capture a rectangular region of a display.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `x`, `y` | integer | yes | Top-left corner |
| `width`, `height` | integer | yes | Size in pixels |
| `display` | integer \| string | no | Display index (0-based, default `0`), system ID, or name |
| `keyword` | string | yes | Label assigned in the same call |

Coordinates are display-relative. On a multi-monitor rig, call `list_displays` first — guessing is how you end up with a screenshot of the wrong monitor's wallpaper.

### `capture_window`

Capture a window by title or process name (fuzzy match). **The default capture tool for agents.**

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `query` | string | yes | Window title or process name |
| `keyword` | string | yes | Label assigned in the same call |

Survives the window moving; does not survive it being resized (see [recipe 06](../recipes/06-visual-regression-watch/) on stability).

**The query matches process names too, and that is a trap when several windows of the same app are open.** Query `"Google Chrome"` and you get *a* Chrome window — quite possibly the one with your email in it, not the one you meant. Prefer the **window title**, which is far more specific. If the titles collide as well (a hash-routed app keeps one `<title>` across routes), fall back to `list_tracked_windows` and confirm what you're aiming at before you shoot.

### `capture_display`

Capture an entire monitor.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `display` | integer \| string | no | Index (default `0`), system ID, or name |
| `keyword` | string | yes | Label assigned in the same call |

### `capture_active_window`

Capture the currently focused window.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `keyword` | string | yes | Label assigned in the same call |

> **Warning, straight from the tool's own description:** when this is called by an agent, the active window is very likely the terminal or IDE running the agent — not the window the user is looking at. Prefer `capture_window` with a specific query, or `list_tracked_windows` first. This is the single most common mistake in agent screenshot workflows.

### `capture_tracked_window`

Capture a window from the Activity Tracker stack — "the window I was just in".

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `stack_position` | integer | no | 1-indexed; 1 = most recent |
| `title` | string | no | Match by title within the stack |
| `keyword` | string | yes | Label assigned in the same call |

Give either `stack_position` or `title`. Requires the **windowTracker** feature flag (Settings → Experimental). Windows that have closed since they were tracked will error — skip and report, don't retry.

> **`stack_position: 1` is the same trap as `capture_active_window`, wearing a different hat.** Position 1 means "most recently focused", and in an agent session that is very often the terminal the agent is running in — every shell command it runs can put the focus back there. Match by `title` instead: it is the only selector in this tool set that does not move when focus does.

### `list_displays`

No parameters. Returns every connected display with its geometry. Prerequisite for `capture_region` math.

### `list_tracked_windows`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `limit` | integer | no | Max entries, default `10` |

Recently active windows, most recent first. Requires the **windowTracker** feature flag.

Each entry carries `title`, `process_name`, `stack_position` and `last_seen` (epoch ms).

**It is an activity log, not a live window list.** It errs in both directions, and each one bites differently.

*Too many rows:* windows that have since been closed keep theirs, so the same title can appear more than once — typically one live window plus one or more ghosts. Read `last_seen` before concluding you have a title collision. `capture_tracked_window` matched by `title` does a first-match scan down the same most-recent-first order, so it lands on the freshest entry and the ghosts never win. A real collision is two entries with the same title *and* comparable `last_seen`; that one you have to resolve by closing a window.

*Too few rows:* the log is written on focus events, so **a window that has never been focused since it was created is not in it at all** — a terminal you opened in the background, a window on another Space. It is still a real window, and `capture_window` will find it, because that tool matches against the OS window list rather than this history. If `capture_tracked_window` says "no window matching X" and you can see the window, that is the difference talking; switch tools rather than clicking around to make it appear.

**Tabs are invisible here.** The tracker works at window granularity, so a second tab in the same terminal or browser window produces no row — it only changes the existing row's `title` while it is the frontmost tab. Anything you want to capture by name has to be its own window.

## Manage (8)

### `list_screenshots`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `type` | enum | no | `region` \| `window` \| `display` \| `beautify` \| `markers` |
| `status` | enum | no | `active` (default) \| `deleted` |
| `limit` | integer | no | Default `20` |
| `offset` | integer | no | Default `0` |
| `sort_by` | enum | no | `created_at` (default) \| `updated_at` \| `keyword` |
| `sort_order` | enum | no | `desc` (default) \| `asc` |

### `search_screenshots`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `query` | string | **yes** | Matches filename, keyword, and metadata |
| `date_from` | string | no | ISO 8601; created after |
| `date_to` | string | no | ISO 8601; created before |
| `type` | enum | no | Same values as `list_screenshots` |
| `limit` | integer | no | Default `20` |

`query` is mandatory — to browse without a search term, use `list_screenshots`. The date filters are what make incident replay possible ([recipe 08](../recipes/08-dashboard-watch/)).

### `get_screenshot`

| Parameter | Type | Required |
| --- | --- | --- |
| `id` | string | yes |

Full metadata for one screenshot: paths, dimensions, type, timestamps, keyword.

### `open_screenshot`

| Parameter | Type | Required |
| --- | --- | --- |
| `id` | string | yes |

Opens the file in the **system** image viewer (Preview, Photos, …). It does *not* bring the Lazy Shot window forward — that's `show_window`.

### `assign_keyword`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | string | yes | ID or current keyword |
| `keyword` | string | yes | New label |

Auto-suffixes on collision. Mostly redundant now that capture tools take a `keyword` — use it for renaming and for labelling markers output after the fact.

### `delete_screenshot`

| Parameter | Type | Required |
| --- | --- | --- |
| `id` | string | yes |

**Soft** delete: the record is marked deleted and the preview file removed. Re-findable with `list_screenshots` + `status: "deleted"`.

### `get_app_status`

No parameters. Returns version, platform, arch, locale, storage bytes, screenshot count, the **live MCP port**, feature flags, and the settings blob. The first call to make when something behaves unexpectedly.

### `show_window`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `visible` | boolean | no | `true` (default) shows and focuses, `false` hides |

Use it to hand control back to the human — "I've captured it, here's the app, do the redaction". Note that showing the window changes which window is active, which matters if the next step captures anything.

## Markers & compositor (5)

Markers are a **metadata layer**, not baked pixels: they can be moved, relabelled and reapplied without touching the raster underneath — and they are never drawn into an exported file. Read [`add_markers`](#add_markers) before designing a workflow that ends in a published image.

### `add_markers`

Create an annotated screenshot from a source screenshot.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `screenshot_id` | string | yes | Source ID or keyword |
| `keyword` | string | yes | Keyword for the new markers screenshot |
| `markers` | array | no* | Objects: `x`, `y` (required), `label`, `color` (hex), `size` (16–64, default 32) |
| `preset_name` | string | no* | Apply a saved preset instead of explicit coordinates |
| `edit_existing` | boolean | no | `true` updates the source in place. Default `false` — a copy is created |

\* Give either `markers` or `preset_name`.

Default behaviour forks a copy, so the pristine original stays available for diffing.

**What you get back is a marker *layer*, not an annotated picture.** The new entry has `type: "markers"`, its `metadata.markers` array holds the positions, and its `file_path` points at a file whose pixels are still identical to the source.

**Markers are never rasterised — including on export.** This is the part that surprises people, so it's worth being exact. Beautify's export bakes the *markup* tool stack onto the image; the bake function skips markers by design, and there is no other code path that draws them into a file. So a marker layer's file has the source's pixels today, after an export, and forever.

What markers are for, then:

- **Machine-readable structure.** Coordinates, labels, colours and order, stored as JSON on the entry — an agent writes them and an agent reads them back. Numbering a repro is a *data* operation.
- **Review inside the app.** Open the entry in Beautify and toggle markers on: the badges appear over the image, draggable and relabelable. That's where a human sees them.
- **Reuse.** Because nothing is baked, the same layout survives a re-shoot of the underlying screen, and can be saved as a preset.

**To publish an image with visible numbered badges, use the Counter tool** (markup toolbar, shortcut `N`) in the app. It drops an auto-incrementing numbered badge, it's an annotation, and annotations *are* baked on export. It's placed by hand — no MCP tool writes annotations.

The honest division of labour is therefore: the agent decides *where* the numbers belong and puts markers there; if the image is going to be published, a person opens it, reads the markers, and lays counters on the same spots. If the image is only going to be read by an agent, or looked at in the app, the markers are already the finished artifact.

Third option, often the best one for documentation: don't flatten at all — **capture the app** with markers toggled on. `capture_window` on Lazy Shot's own window gives you a real picture of badges over the image, no manual step.

### `list_marker_presets`

No parameters. All saved marker layouts.

### `get_marker_preset`

| Parameter | Type | Required |
| --- | --- | --- |
| `name` | string | yes |

One preset with its full marker data.

### `search_marker_presets`

| Parameter | Type | Required |
| --- | --- | --- |
| `query` | string | yes |

Find presets by name.

> Presets can be listed, read and applied over MCP, but **not authored** over MCP — you create a preset in the app by placing markers and saving the set. Deliberate: the checklist is a human decision ([recipe 07](../recipes/07-design-qa-passes/)).

### `edit_screenshot`

Open the Beautify compositor on a capture.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | string | yes | ID or keyword |
| `edit_existing` | boolean | no | `true` saves back over the original. Default `false` — a beautified copy |

**What "the compositor" is**, since this document leans on the word. It's the **Beautify** window in the app. The capture goes onto a canvas where you set a background, padding, corner radius and shadow, pick an aspect preset (`auto`, `original`, `4:3`, `9:16`, `x-post` or a custom size), crop, and export to PNG, JPEG or WebP. The same window carries the markup toolbar — arrow, line, rectangle, circle, text, pencil, highlighter, blur, spoiler, counter, eraser — and the markers layer with its visibility toggle. Annotations are baked into the export; markers are not.

This one opens UI. It is a hand-off to the human, not a headless render step: the agent stages the image, you finish it.

## OCR (3)

Tesseract, running locally. ~125 languages. Nothing is uploaded anywhere, by anyone — the honest counterpart to agent vision, where pixels do go to your model provider.

### `ocr_screenshot`

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | string | yes | ID or keyword |
| `lang` | string | no | Tesseract code(s): `eng`, `rus`, `deu`, `jpn`, `chi_sim`, … Combine with `+` (`eng+rus`). Defaults to the user's configured language |
| `variant` | enum | no | `fast` (default, ~4 MB/lang) \| `best` (~25 MB/lang, 5–10× slower, better on noisy or low-DPI text) |
| `format` | enum | no | `text` (default) \| `metadata` \| `text_and_metadata` |

`format: "metadata"` returns each recognised word with a bounding box (`x`, `y`, `width`, `height`, in source-image pixels) and a confidence score of 0–100. Two things fall out of that, and both are used in [recipe 05](../recipes/05-copy-the-uncopyable/):

- **Filter the noise.** Drop everything under ~60 confidence instead of trusting a garbled transcript.
- **Boxes are marker coordinates.** A word's box centre feeds straight into `add_markers` — the agent can point at a phrase it found, without eyeballing pixel positions.

Missing language packs auto-download on first use (~4 MB, one time).

### `ocr_image_path`

Same, for an arbitrary image file on disk.

| Parameter | Type | Required | Notes |
| --- | --- | --- | --- |
| `path` | string | yes | Absolute path |
| `lang`, `variant`, `format` | — | no | As above |
| `region` | object | no | `{ x, y, width, height }` — restrict OCR to a sub-area |

**Path restriction:** the path must resolve inside the screenshots directory or the app data directory. This is a security boundary, not a bug — an MCP server that would OCR any file on the disk is a file-exfiltration primitive. For gallery items, use `ocr_screenshot`.

`region` is the cheap way to OCR one column of a table without re-capturing.

### `list_ocr_languages`

No parameters. Returns installed language packs plus the common codes available for download. Call it before guessing a `lang`.

## Resources (4)

| URI | Contents |
| --- | --- |
| `screenshots://recent` | The most recent captures |
| `screenshots://{id}/metadata` | Metadata for one screenshot (URI template) |
| `config://settings` | Current app settings |
| `config://displays` | Connected display geometry |

The server declares `subscribe: false` and `listChanged: false` for resources, so these are read on demand — there are no push updates, and a client that wants fresh data re-reads the URI. Reading a resource doesn't count against the free-tier tool quota.

## Prompts (2)

Built-in workflow prompts, invocable from any client that supports MCP prompts (in Claude Code: `/mcp`).

| Name | What it walks through |
| --- | --- |
| `document-ui-flow` | Identify windows → capture each step → keyword each → add numbered markers → review. Basis of [recipe 01](../recipes/01-self-documenting-ui/) |
| `batch-capture` | List displays → list tracked windows → capture each target → keyword each → verify. Basis of [recipe 04](../recipes/04-release-day-batch-capture/) |

The recipes in this cookbook go further than the built-ins — the prompts are the guided version, the recipes are the opinionated one.

## Errors

Errors come back as structured MCP errors, not prose, so an agent can branch on them. Practical mapping:

| Symptom | Usual cause | Fix |
| --- | --- | --- |
| "Free-tier daily MCP limit reached (N calls/day)" | Every `tools/call` counts; the free tier allows 10 a day | Activate the app, or wait a day — [details](./SETUP.md#licence-and-the-free-tier-quota) |
| "License is not active. Activate the app before invoking MCP actions." | Revoked key, or a hard-blocked licence state | Settings → License |
| Connection refused | MCP server disabled, or the port moved | Settings → MCP; `get_app_status` reports the live port |
| Window not found | Minimised, closed, or the fuzzy query matched nothing | `list_tracked_windows`, then retry with a better query |
| Tracked-window tools error out | `windowTracker` feature flag off | Settings → Experimental |
| Blank or wrong-monitor region | Display index guessed | `list_displays` first |
| OCR path rejected | Path outside the allowed directories | Use `ocr_screenshot`, or move the file into the screenshots directory |

Every operation, successful or not, is logged to the app's rotating session log in `~/.heretic-lazy-shot/logs/` (one file per app run). The format is greppable:

```text
[MCP] TOOL_CALL tool=capture_window params={"query":"Chrome","keyword":"pricing-page"}
[MCP] TOOL_OK   tool=capture_window duration_ms=412 summary=...
[MCP] TOOL_FAIL tool=capture_window error=... duration_ms=88
```

When reporting a bug, that excerpt is the evidence.
