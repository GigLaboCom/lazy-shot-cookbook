# Example configurations

Copy-paste-ready configs for connecting an MCP client to Heretic Lazy Shot. All of them assume the defaults: `http://localhost:5055/mcp`, transport streamable-http, no authentication.

**Check the port first.** It auto-increments when 5055 is busy. The live value is shown in Settings → MCP and returned by `get_app_status`.

| Client | File | Where it goes |
| --- | --- | --- |
| Claude Code (project scope) | [`claude-code/.mcp.json`](./claude-code/.mcp.json) | Repository root, committed — everyone on the project gets the server |
| Claude Desktop | [`claude-desktop/claude_desktop_config.json`](./claude-desktop/claude_desktop_config.json) | macOS `~/Library/Application Support/Claude/`, Windows `%APPDATA%\Claude\` |
| Cursor | [`cursor/mcp.json`](./cursor/mcp.json) | `.cursor/mcp.json` in the project, or `~/.cursor/mcp.json` globally |
| Cursor rules | [`cursor/lazy-shot.mdc`](./cursor/lazy-shot.mdc) | `.cursor/rules/lazy-shot.mdc` |
| VS Code | [`vscode/mcp.json`](./vscode/mcp.json) | `.vscode/mcp.json` in the project |

Claude Code users can skip the file entirely:

```bash
claude mcp add --transport http lazy-shot http://localhost:5055/mcp
```

Whichever client you use, also drop the agent rules into your project — [`CLAUDE.md`](../CLAUDE.md) for Claude, [`AGENTS.md`](../AGENTS.md) for everything else, `cursor/lazy-shot.mdc` for Cursor. Without them the agent will invent its own keyword conventions and screenshot its own terminal at least once.

Full setup notes and troubleshooting: [docs/SETUP.md](../docs/SETUP.md).
