# Changelog

All notable changes to this cookbook are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This repository documents a moving target — the app's MCP surface — so entries
note which app version a change was verified against.

## [Unreleased]

### Added

- Initial cookbook: six shipped recipes (00–05) and three proposed (06–08).
- Drop-in agent rules: `CLAUDE.md`, generated vendor-neutral `AGENTS.md`, and a Cursor rules file.
- `docs/TOOLS.md` — full reference for all 23 tools, 4 resources and 2 prompts, verified against app **0.0.8**.
- `docs/SETUP.md` — per-client setup and a troubleshooting table.
- `principles/FILE-PATHS-NOT-BASE64.md` — the design argument behind the file-path contract.
- Example configurations for Claude Code, Claude Desktop, Cursor and VS Code.
- `scripts/sync-agent-rules.sh` to keep `AGENTS.md` generated from `CLAUDE.md`, enforced in CI.

### Changed

- Tool count corrected from 18 to **23**: the OCR group (`ocr_screenshot`, `ocr_image_path`, `list_ocr_languages`) plus `show_window` and `edit_screenshot` were added to the app after the first draft of these recipes.
- "Copy the uncopyable" promoted from proposed to shipped and rewritten around the real OCR tools; recipes renumbered accordingly (visual regression 05 → 06).
- Product links point at `giglabo.com/heretic/applications/heretic-lazy-shot`; repository links at `GigLaboCom/lazy-shot-cookbook`.
- **MCP server name is `lazy-shot`, not `heretic-lazy-shot`.** The app's own Settings → MCP tab hands out connection snippets naming the server `lazy-shot`, on all four client tabs. The cookbook said `heretic-lazy-shot` everywhere, so a reader who pasted the app's snippet and then followed these docs would not find their own server. The name is arbitrary and both work; the docs are what had to move, because the app is what people copy from. Paths (`~/.heretic-lazy-shot/`), the product name and the source-repo name are unchanged.

### Fixed

Reconciled every factual claim against the app source at 0.0.8:

- **Licence gating documented.** The MCP server is licence-gated: unlimited calls when active, **10 tool calls per day** on the free tier, no access when hard-blocked. This was missing entirely and is the first thing a reader hits.
- **Removed the "flash notification" claim.** MCP captures are silent — no overlay, no notification, and the main window is not brought forward. The privacy argument now rests on what is actually true: no ambient watching mode, one explicit call per capture, every call logged.
- **Corrected the log location.** There is no `mcp.log`; MCP operations go to the app's rotating per-run log in `~/.heretic-lazy-shot/logs/`, tagged `[MCP]`.
- **Removed the resource-subscription claim.** The server declares `subscribe: false` and `listChanged: false`; resources are read on demand.
- Port fallback is a walk over the next ten ports, not an open-ended auto-increment.
