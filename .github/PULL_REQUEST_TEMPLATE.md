## What this changes

<!-- One or two sentences. Link the recipe proposal issue if there is one. -->

## Checklist

- [ ] Only real MCP tools are referenced (see [docs/TOOLS.md](../docs/TOOLS.md)) — nothing invented
- [ ] Copy-paste prompts work **verbatim**, as pasted, and I've run them
- [ ] New or changed recipes have a *Gotchas* section with at least two honest entries
- [ ] Any images are made in Lazy Shot itself, and contain no tokens, emails, or customer data
- [ ] `./scripts/sync-agent-rules.sh --check` passes (run the script and commit `AGENTS.md` if you edited `CLAUDE.md`)
- [ ] Markdown lint passes: `npx markdownlint-cli2 "**/*.md"`

## For new recipes

- [ ] I actually run this workflow
- [ ] Platform(s) tested: <!-- macOS / Windows -->
- [ ] Client(s) tested: <!-- Claude Code / Claude Desktop / Cursor / n8n / … -->
- [ ] Lazy Shot version: <!-- from get_app_status -->
