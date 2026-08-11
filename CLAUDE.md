# Screenshots: Heretic Lazy Shot

<!-- Drop this file (or just this section) into your project root.
     Requires Lazy Shot running with the MCP server enabled: Settings → MCP.
     Endpoint: http://localhost:5055/mcp (streamable-http).
     Vendor-neutral copy of the same rules: AGENTS.md
     Source: https://github.com/GigLaboCom/lazy-shot-cookbook -->

<!-- SHARED:BEGIN -->
This machine runs **Heretic Lazy Shot** with an MCP server. Use it whenever you need to see the screen, read text you can't select, or manage screenshots.

## Rules

1. **To see something, capture it.** `capture_window` with a fuzzy query is the default — query the **window title**, not the process name, whenever more than one window of that app could be open. `capture_region` for exact coordinates (call `list_displays` first on multi-monitor). `capture_tracked_window` matched by `title` for "the window I was just in". Use `capture_active_window` only when the user is clearly driving — see rule 7.
2. **Responses contain a `file_path`, never image data.** Read the image from that path with your file tools. Do not ask for base64.
3. **Name every capture immediately.** The capture tools take a `keyword` argument — use it, and skip the second call. Short, kebab-case, describing *content* rather than time: `login-bug`, `checkout-step-3`, `pricing-table`. Collisions auto-suffix; from then on use the keyword that was **returned**, not the one you asked for.
4. **Never annotate originals.** `add_markers` forks a copy by default; keep the original for diffing. Pass `edit_existing: true` only when the user explicitly asks to overwrite. Note what the copy actually is: a **marker layer**, with the same pixels as the source. Say so when you hand over the path — if the user needs a picture with the badges drawn on it, they have to export it from the app; you cannot flatten it.
5. **Find before you re-capture.** If a screenshot might already exist, `search_screenshots` by keyword first. It also takes `date_from` / `date_to`.
6. **Deleting is safe.** `delete_screenshot` is a soft delete; the record stays, filterable by `status: "deleted"`.
7. **`capture_active_window` is a trap in agent sessions.** The focused window is usually the terminal *you* are running in, not what the user sees. Prefer `capture_window` by process name, or `list_tracked_windows` first.
8. **Reading text: pick the right blade.** For plain text out of a dense screen (logs, error dialogs, contracts, anything confidential), call `ocr_screenshot` — Tesseract, on-device, deterministic, nothing leaves the machine. For structure, layout and meaning ("what does this error mean", "turn this form into YAML"), read the image yourself. Say which one you used.

## Conventions in this project

- Bug work uses before/after pairs: `<slug>-before`, `<slug>-after`.
- Documentation flows use step suffixes: `<flow>-step-1`, `<flow>-step-2`, …
- Reusable annotation layouts are marker presets — check `list_marker_presets` before placing markers by hand.

## When iterating on UI

- The screen is the source of truth. After every change that should be visible, `capture_window` by the app's process name, read the file, and compare against the goal **before** claiming success.
- Keyword the series: `<feature>-before` before the first edit, `<feature>-iter-N` per iteration, `<feature>-after` when the capture matches the goal. Output the before/after paths for the PR.
- You cannot click. To reach a state, prefer code — a dev flag, a scratch route, a forced state — and remove the scaffolding afterwards. Only when code can't reach it, give a numbered stage direction and wait for a "go" before capturing.

## When something fails

Report the error message verbatim. Common causes, in order: the app's licence is inactive or the free-tier daily MCP quota is used up (the error says so explicitly — stop and tell me rather than retrying), the MCP server is off or moved port (`get_app_status` returns the live one), the target window is minimised or on a locked screen, or the Window Activity Tracker is disabled (`list_tracked_windows` / `capture_tracked_window` need it). Every operation is logged, tagged `[MCP]`, in the newest file under `~/.heretic-lazy-shot/logs/`.
<!-- SHARED:END -->
