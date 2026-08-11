# Setup

Getting Heretic Lazy Shot connected to your agent, per client, plus what to do when it doesn't work.

## Prerequisites

1. **Lazy Shot installed and running** on the same machine as your agent — [giglabo.com/heretic/applications/heretic-lazy-shot](https://giglabo.com/heretic/applications/heretic-lazy-shot). macOS or Windows, free trial, no credit card.
2. **The MCP server enabled**: Settings → MCP. Default `http://localhost:5055/mcp`, transport **streamable-http**.
3. **Screen-recording permission** granted to Lazy Shot. macOS: System Settings → Privacy & Security → Screen & System Audio Recording. Without it, captures come back empty or black.
4. **Optional but recommended:** the Window Activity Tracker (Settings → Experimental). `list_tracked_windows` and `capture_tracked_window` need it; [recipe 04](../recipes/04-release-day-batch-capture/) is built on it.

![The MCP tab in Lazy Shot settings: the server running on port 5055, the enable toggle on, the bind address set to 127.0.0.1, and a ready-to-copy Claude Code connection snippet](../assets/setup/settings-mcp.png)

That panel is the whole of step 2, and it also answers three questions people ask afterwards: the live port, the bind address, and a connection snippet per client that you can copy instead of retyping anything from this page.

If 5055 is taken, the server walks up to the next ten ports and binds the first one free. The live port is shown in the UI and returned by `get_app_status` — if a client can't connect, check there before debugging anything else.

**Leave the bind address on `127.0.0.1`.** The dropdown also offers `0.0.0.0`, which exposes an unauthenticated screen-capture server to every host that can route to you. The app's CORS rule allows only localhost origins, but CORS is a browser rule — a direct HTTP client from another machine ignores it. Details in [SECURITY.md](../SECURITY.md). One side effect worth knowing: on `0.0.0.0` the connection snippets print `localhost`, and on `127.0.0.1` they print `127.0.0.1`. Both work.

## Licence and the free-tier quota

The MCP server is gated by the app's licence, and this catches people out, so it's worth stating plainly before you build a workflow on it:

| Licence state | MCP access |
| --- | --- |
| Active (paid, or trial in progress) | Unlimited tool calls |
| Free tier — no key, or the trial has expired | **10 tool calls per day** by default |
| Hard-blocked (revoked key, tampered clock) | No MCP access at all |

Every `tools/call` counts against the free-tier quota — including cheap ones like `get_app_status`. Ten calls is enough to try a recipe once; it is not enough to run [recipe 00](../recipes/00-see-what-you-shipped/)'s iteration loop, which spends a call per iteration. Reading resources and prompts doesn't consume quota.

When the quota runs out the server returns an explicit error — *"Free-tier daily MCP limit reached (10 calls/day)"* — rather than failing silently. The limit is a setting (Settings → Experimental) if you need to adjust it for your own machine.

Activation is one-time and offline (Ed25519-signed PASETO tokens); there's no per-call phone-home.

## Claude Code

```bash
claude mcp add --transport http lazy-shot http://localhost:5055/mcp
```

Verify with `/mcp` inside a session — you should see the server connected, its 23 tools, and the two prompts.

To share the connection with a team or across machines, commit a project-scoped [`.mcp.json`](../examples/claude-code/.mcp.json) instead of adding it per user.

Then drop [`CLAUDE.md`](../CLAUDE.md) into your project root so the agent starts with the house rules rather than inventing its own conventions.

## Claude Desktop

Edit `claude_desktop_config.json`:

- macOS — `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows — `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "lazy-shot": { "url": "http://localhost:5055/mcp" }
  }
}
```

Restart Claude Desktop. Full file: [`examples/claude-desktop/`](../examples/claude-desktop/).

## Cursor

Project-scoped `.cursor/mcp.json` (or the global `~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "lazy-shot": { "url": "http://localhost:5055/mcp" }
  }
}
```

Cursor reads rules from `.cursor/rules/*.mdc` rather than `CLAUDE.md` — a ready-made rules file is in [`examples/cursor/`](../examples/cursor/).

## VS Code (GitHub Copilot / MCP)

`.vscode/mcp.json`:

```json
{
  "servers": {
    "lazy-shot": { "type": "http", "url": "http://localhost:5055/mcp" }
  }
}
```

See [`examples/vscode/`](../examples/vscode/).

## n8n (self-hosted)

Use the **MCP Client** node with `http://localhost:5055/mcp` and the streamable-HTTP transport.

The one rule that matters: **n8n must run on the same machine as Lazy Shot.** Tool responses are local file paths, so a containerised n8n needs the screenshots directory mounted at the same path it appears in the responses, or the downstream nodes will read from a path that doesn't exist inside the container. Recipes [04](../recipes/04-release-day-batch-capture/) and [08](../recipes/08-dashboard-watch/) cover the scheduled workflows.

## Any other MCP client

Transport **streamable-http**, URL `http://localhost:5055/mcp`, no authentication. Anything that speaks MCP over HTTP works; the file-path contract means the client must be able to read local files for vision workflows to be useful.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Tools fail with "daily MCP limit reached" or "License is not active" | The licence gate, not a bug — see [the quota section](#licence-and-the-free-tier-quota) |
| Client shows the server as failed/offline | Is Lazy Shot running? Is the MCP server toggled on? Is the port still 5055 (`get_app_status`)? |
| Tools connect, captures are black or empty | Screen-recording permission (macOS Privacy & Security). Re-grant, then restart the app |
| `capture_window` finds nothing | The query is fuzzy but not magic — try the process name; `list_tracked_windows` shows what's actually visible to the app |
| The agent screenshots its own terminal | It called `capture_active_window`. Fix it with the rules file, not by asking nicely — see [CLAUDE.md](../CLAUDE.md), rule 7 |
| `list_tracked_windows` returns nothing | Window Activity Tracker is off (Settings → Experimental) |
| Everything is slow on the first OCR call | The language pack is downloading (~4 MB, one time) |
| Captures land, but the agent can't read them | The agent isn't local, or has no file-read tool. This server is local-first by design — [why](../principles/FILE-PATHS-NOT-BASE64.md) |

Every MCP operation is logged to the app's rotating session log — one file per app run, named `heretic-lazy-shot_<date>_<time>.log`, in `~/.heretic-lazy-shot/logs/`. MCP entries are tagged, so `grep '\[MCP\]'` on the newest file gives you the tool calls, their parameters, and their outcomes. Attach that excerpt to bug reports.

## Security note

The MCP server has **no authentication** and binds to `127.0.0.1` by default. Anything that can reach that port can capture your screen. Don't bind it to `0.0.0.0` on an untrusted network — see [SECURITY.md](../SECURITY.md).
