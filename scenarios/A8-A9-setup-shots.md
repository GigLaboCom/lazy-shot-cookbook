# A8 & A9 — the setup screenshots

Two stills, both quick, both worth more than they look. They answer "is this real and will it work in one command?" before anyone reads a recipe.

## A8 — `assets/setup/settings-mcp.png`

**Output:** ✅ **shot** — 1280 × 500, 70 KB.

The Settings → MCP tab, server enabled, port visible.

**1280, not 900.** This scenario used to say 900 wide. On a 1862 px app window the settings panel is 1668 px, so 900 renders "Bind Address" at about 7 px and the asset stops doing its job. Crop used: `crop=1668:652:100:118` then scale to 1280. Recompute for your window; the rule is that the smallest label must survive, not that the number matches this page.

**Before shooting:** set the bind address back to `127.0.0.1` if you've changed it. `SECURITY.md` tells readers to keep the server on loopback; a screenshot showing `0.0.0.0` contradicts the advice on the same page they're reading. Check it with `get_app_status` rather than by eye — `settings.mcp_bind` — because the dropdown is easy to walk past. Changing it restarts the MCP server, so expect one tool call to fail right after.

Light theme. Capture Lazy Shot's own window:

```text
capture_window query "Heretic Lazy Shot", keyword "setup-mcp-tab"
```

Then trim to the panel in the Compositor — no desktop, no other windows, no traffic-light buttons unless the whole window is in frame.

**Embed** — README step 1 and `docs/SETUP.md` prerequisites:

```markdown
![The MCP tab in Lazy Shot settings with the server enabled and listening on port 5055](../assets/setup/settings-mcp.png)
```

## A9 — `assets/setup/claude-code-connected.png`

**Output:** ✅ **shot** — 890 × 184, 20 KB.

The trust asset: `/mcp` in Claude Code showing `lazy-shot` connected, with the tool count. (This used to say "and both prompts" — `/mcp` lists servers, status and tool counts, not prompts. The real panel settled it.)

**Before shooting:** use a scratch project, not a client one. Check the shell prompt, the window title, and the list of other MCP servers — all three leak. A path like `~/work/acme-migration` in the prompt is exactly the thing that gets noticed.

Set it up so the leak can't happen rather than cropping it away afterwards:

```bash
mkdir -p /tmp/lazy-shot-demo
cp examples/claude-code/.mcp.json /tmp/lazy-shot-demo/
cd /tmp/lazy-shot-demo && claude
```

`/tmp/lazy-shot-demo` is short and says nothing about you, which matters because the path appears twice in frame — in the shell prompt and in Claude Code's own **Project MCPs** header. Using the repo's own example config means the screenshot doubles as proof that `examples/claude-code/.mcp.json` works as shipped.

**Open it as its own window** (`Cmd+N`), not a tab. The window tracker is per window, so a tab produces no entry to target by name.

`/mcp` lists *every* server, including account-level ones — Gmail, Drive, Calendar and anything else you've connected. Crop to the **Project MCPs** block: it drops all of that plus the "Welcome back <name>" banner, and what's left is exactly the claim, `lazy-shot · connected · 23 tools`.

Native scale, no upscaling. Terminal glyphs are hinted for their pixel size and go mushy the moment you enlarge them — which is why this asset is 890 wide and A8 is 1280.

```text
capture_window query "<your terminal window title>", keyword "setup-claude-code-mcp"
```

Crop to the `/mcp` output block. If the tool list is long, crop to the header line plus enough rows to show it's a real listing — the count is the point, not the enumeration.

**Embed** — `docs/SETUP.md`, Claude Code section:

```markdown
![Claude Code's /mcp output showing the lazy-shot server connected with its tools and prompts](../assets/setup/claude-code-connected.png)
```

## Checklist for both

- [x] Light theme
- [x] Window, not display
- [x] A8: bind address reads `127.0.0.1`
- [x] A9: no client paths, no other MCP servers you'd rather not advertise
- [x] Tool count matches what `docs/TOOLS.md` claims — if the app has shipped new tools since, the docs need updating before the screenshot does
