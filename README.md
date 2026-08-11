<p align="center">
  <img src="./assets/brand/lazy-shot-icon-128.png" alt="Heretic Lazy Shot" width="96" height="96">
</p>

<h1 align="center">Lazy Shot Cookbook</h1>

<p align="center"><b>Give your agent eyes.</b></p>

<p align="center">
Recipes, prompts and drop-in configs for driving
<a href="https://giglabo.com/heretic/applications/heretic-lazy-shot">Heretic Lazy Shot</a>
— a desktop screenshot app with a built-in <b>23-tool MCP server</b> —
from Claude Code, Claude Desktop, Cursor, VS Code, n8n, or any MCP client.
</p>

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-supported-black">
  <img alt="Windows" src="https://img.shields.io/badge/Windows-supported-blue">
  <img alt="MCP" src="https://img.shields.io/badge/MCP-23%20tools%20%C2%B7%204%20resources%20%C2%B7%202%20prompts-orange">
  <img alt="License" src="https://img.shields.io/badge/one--time%20license-no%20subscription-green">
  <img alt="Cookbook license" src="https://img.shields.io/badge/cookbook-MIT-lightgrey">
</p>

---

Lazy Shot is a full screenshot app for humans — capture, annotate, blur, beautify, OCR, and manage a searchable library. This repo is about the other half: **the same app is a headless screenshot service for agents.** Your agent captures windows, names screenshots with memorable keywords, places numbered markers, runs on-device OCR, and searches the whole library — while you keep working.

**Why agents need this**

- **Eyes.** Agents work blind. A capture tool returns a `file_path`; a local agent reads the image and finally sees what you see.
- **Memory.** Every capture gets a short keyword (`login-bug`, `rabbit`, `checkout-step-3`) instead of a UUID or a timestamp. Recall it days later with `search_screenshots`.
- **An audit trail.** Every step of an agent session can be captured, keyworded and replayed visually. When the agent goes off the rails, you scroll the evidence instead of guessing.

**Contents** — [Setup](#30-second-setup) · [Recipes](#recipes) · [The 23 tools](#the-23-tools) · [Design principles](#design-principles) · [What it is *not*](#what-lazy-shot-is-not) · [Contributing](#contributing)

## 30-second setup

1. Open Lazy Shot → **Settings → MCP** → enable the MCP server.
2. Default endpoint: `http://localhost:5055/mcp`, transport **streamable-http**. If 5055 is busy the server walks up to the next ten ports — the live one is shown in the UI and returned by `get_app_status`.
3. Connect your client:

   **Claude Code**

   ```bash
   claude mcp add --transport http heretic-lazy-shot http://localhost:5055/mcp
   ```

   **Claude Desktop** — `claude_desktop_config.json` ([full example](./examples/claude-desktop/claude_desktop_config.json)):

   ```json
   {
     "mcpServers": {
       "heretic-lazy-shot": { "url": "http://localhost:5055/mcp" }
     }
   }
   ```

   **Cursor / VS Code / any MCP client** — streamable-http, URL `http://localhost:5055/mcp`. Ready-made files live in [`examples/`](./examples/).

4. Drop [`CLAUDE.md`](./CLAUDE.md) (or the vendor-neutral [`AGENTS.md`](./AGENTS.md)) into your project so the agent knows the house rules. Done.

One thing to know before you build on it: **the MCP server is licence-gated.** An active licence or a running trial gets unlimited tool calls; the free tier gets 10 a day, and then an explicit "daily MCP limit reached" error. Enough to try a recipe, not enough to run the iteration loop in recipe 00. → [details](./docs/SETUP.md#licence-and-the-free-tier-quota)

Stuck? → [docs/SETUP.md](./docs/SETUP.md) has the per-client details and the troubleshooting table.

## Recipes

| # | Recipe | What it shows | Core tools |
| --- | -------- | --------------- | ------------ |
| 00 | [The see-what-you-shipped loop](./recipes/00-see-what-you-shipped/) | The flagship: the agent edits UI code, captures the window, and **looks before claiming done** — plus the three-rung protocol for directed capture | `capture_window`, `assign_keyword` |
| 01 | [Self-documenting UI flows](./recipes/01-self-documenting-ui/) | Docs screenshots that regenerate themselves after every release | `capture_window`, `add_markers`, marker presets |
| 02 | [The visual bug-fixing loop](./recipes/02-visual-bug-fixing/) | Before/after evidence pairs, numbered repro steps, redaction discipline | `capture_window`, `add_markers`, `search_screenshots` |
| 03 | [Navigating complex sites](./recipes/03-complex-site-navigation/) | Lazy Shot as the *eyes* of a browser agent — plus a flight recorder for the whole session | `capture_window`, `capture_region`, `list_displays` |
| 04 | [Release-day batch capture](./recipes/04-release-day-batch-capture/) | Sweep every window and every monitor in one agent run | `list_tracked_windows`, `capture_tracked_window`, `capture_display` |
| 05 | [Copy the uncopyable](./recipes/05-copy-the-uncopyable/) | On-device OCR + agent vision on text you can't select: error dialogs, RDP, screen shares, BI tables | `ocr_screenshot`, `capture_region`, `add_markers` |

<!-- TODO(assets): A2 — assets/recipes/00-see-what-you-shipped/iteration-series.gif goes here as the hero. Spec: docs/ASSETS.md -->

### Proposed — the roadmap in the open

Fully drafted, shipping after validation and assets. Kick the tires and [tell us what breaks](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml).

| # | Recipe | What it shows | Core tools |
| --- | -------- | --------------- | ------------ |
| 06 | [Visual regression watch](./recipes/06-visual-regression-watch/) | Two-tier UI diffing with zero infra: an ImageMagick pixel gate plus an agent-vision explanation | `capture_window`, versioned keywords, `add_markers` |
| 07 | [Design QA passes](./recipes/07-design-qa-passes/) | Marker presets as review checklists — the same numbered pass on every screen, reports that write themselves | `add_markers` (presets), `list_marker_presets` |
| 08 | [Dashboard watch](./recipes/08-dashboard-watch/) | Judgment-based alerting: capture the dashboard on a schedule, compare against a baseline, alert with evidence attached | `capture_window`, `search_screenshots`, `delete_screenshot` |

## The 23 tools

Full parameter reference: [docs/TOOLS.md](./docs/TOOLS.md).

**Capture (7)** — headless screenshots: no overlay, no editor, and the app window does not come forward.

| Tool | What it does |
| ------ | -------------- |
| `capture_region` | Pixel-exact rectangle on any display |
| `capture_window` | Fuzzy-match a window by title or process name |
| `capture_display` | A whole monitor by index, system ID, or name |
| `capture_active_window` | Whatever is focused right now — [read the warning](./docs/TOOLS.md#capture_active_window) |
| `capture_tracked_window` | Grab a window from the recent-focus stack — "the window I was just in" |
| `list_displays` | Monitor geometry for multi-display math |
| `list_tracked_windows` | The LRU stack of recently focused windows |

**Manage (8)** — the library.

| Tool | What it does |
| ------ | -------------- |
| `list_screenshots` | Browse with filters and sorting |
| `search_screenshots` | Search filename, keyword and metadata; date-range filters |
| `get_screenshot` | Full metadata for one screenshot |
| `open_screenshot` | Open the file in the system image viewer |
| `assign_keyword` | Give a capture a short memorable word; collisions auto-suffix |
| `delete_screenshot` | Soft delete — nothing is ever wiped |
| `get_app_status` | Version, platform, storage, live MCP port, feature flags, settings |
| `show_window` | Show or hide the Lazy Shot window itself |

**Markers & compositor (5)** — annotate without destroying.

| Tool | What it does |
| ------ | -------------- |
| `add_markers` | Place numbered/labeled markers — on a **copy** by default |
| `list_marker_presets` | Saved marker layouts |
| `get_marker_preset` | One preset with its full marker data |
| `search_marker_presets` | Find presets by name |
| `edit_screenshot` | Open the Beautify compositor on a capture |

**OCR (3)** — Tesseract, ~125 languages, **fully on-device**.

| Tool | What it does |
| ------ | -------------- |
| `ocr_screenshot` | Text from a library item; optional per-word boxes + confidence |
| `ocr_image_path` | Same for an image file on disk, with an optional sub-region |
| `list_ocr_languages` | Installed language packs and what can be auto-downloaded |

Plus 4 MCP resources (`screenshots://recent`, `screenshots://{id}/metadata`, `config://settings`, `config://displays`) and 2 built-in workflow prompts (`document-ui-flow`, `batch-capture`).

## Design principles

1. **File paths, never base64.** Tool responses return `file_path`, not image blobs. Your context window stays for thinking; the agent reads pixels only when it actually needs them. → [the full argument](./principles/FILE-PATHS-NOT-BASE64.md)
2. **Memorable keywords, not UUIDs.** The agent invents a short word per screenshot. You recall "rabbit", not `f2b88789-…`.
3. **Markers fork, never mutate.** Annotation via MCP creates a copy by default; the original stays pristine.
4. **Capture is headless — and always directed.** No overlay to click through, so agents capture while you keep typing. Nothing is ambient either: there is no watching mode, no "capture on change" — every shot is one explicit tool call, and every call is logged. The flip side is that a capture is *silent*, so the log is what you audit. → [recipe 00](./recipes/00-see-what-you-shipped/)
5. **Reading can stay on the machine.** OCR is local Tesseract. Capture is always local; *vision by a cloud model* is not — pick the blade per screen. → [recipe 05](./recipes/05-copy-the-uncopyable/)
6. **Everything is logged.** Every MCP operation is written to the app's rotating session log in `~/.heretic-lazy-shot/logs/`, tagged `[MCP]` — `TOOL_CALL` with parameters, then `TOOL_OK` with a duration or `TOOL_FAIL` with the error. `grep '\[MCP\]'` the newest file and you have the whole session.

## What Lazy Shot is *not*

Honesty section, because you'd find out anyway:

- **It doesn't click.** Lazy Shot is eyes, not hands. For navigation, pair it with Playwright MCP, a browser extension, or any computer-use tool — see [recipe 03](./recipes/03-complex-site-navigation/).
- **No scrolling capture**, no video or GIF recording. If that's your core need, CleanShot X (Mac) and Snagit are genuinely good at it.
- **It never watches the screen.** There is no "observe until something changes" mode. Someone — you or the agent — decides each shot. That is a design position, not a gap.
- **File-path-first means local-first.** The server binds to `127.0.0.1` and returns paths on *this* machine. Built for local agents (Claude Code, Claude Desktop, Cursor, self-hosted n8n), not remote SaaS runners.

## Get Lazy Shot

macOS + Windows · local-first, no telemetry, offline license activation (Ed25519 + PASETO) · **one-time €14.99 (single device) / €29.99 (3 devices) — lifetime, no subscription** · free trial, no credit card.

**→ [giglabo.com/heretic/applications/heretic-lazy-shot](https://giglabo.com/heretic/applications/heretic-lazy-shot)**

## Contributing

Got a workflow we didn't think of? [Open a recipe proposal](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml) or send a PR — see [CONTRIBUTING.md](./CONTRIBUTING.md). The best community recipes get credited in the recipe header and linked from the product blog.

The cookbook (text, examples, configs) is [MIT](./LICENSE). Heretic Lazy Shot itself is commercial software with a free trial.
