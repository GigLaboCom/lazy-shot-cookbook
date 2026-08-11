# Contributing

The best content in this repo will come from workflows we didn't think of. If Lazy Shot's MCP server does something useful in your setup — an agent framework we haven't covered, a CI trick, a weird multi-monitor rig — write it up.

By participating you agree to the [Code of Conduct](./CODE_OF_CONDUCT.md).

## Ground rules

1. **Real workflows only.** A recipe must be something you actually run, with a copy-paste prompt or config that works as pasted.
2. **Honest about limits.** Every recipe has a *Gotchas* section with at least two entries. If your workflow breaks on Windows, needs an experimental flag, or is slower than doing it by hand — say so. This repo earns trust by conceding, not by overclaiming.
3. **No tool invention.** Only the real 23 MCP tools, 4 resources and 2 prompts documented in [docs/TOOLS.md](./docs/TOOLS.md). If your recipe needs something that doesn't exist, that's a feature request — open it as an issue and we genuinely want to hear it.
4. **Dogfood the assets.** Screenshots and GIFs in recipes are made with Lazy Shot itself (annotated in the overlay, beautified in the Compositor). The assets are demos.
5. **Nothing sensitive in images.** Redact before you commit — blur or spoiler in the app, then check the exported file. Reviewers will reject anything with a visible token, email address or customer name.

## Recipe template

```text
recipes/NN-your-slug/README.md

# Recipe NN — <Name>
**Problem:** one paragraph.
**Idea:** one paragraph.
## The loop            — ASCII diagram of the flow
## Copy-paste prompt   — a fenced block that works verbatim
## Tools used          — inline list of real MCP tool names
## Gotchas             — at least two honest ones
```

Proposed recipes carry a status banner at the top until they've been validated. Ship it as proposed rather than sitting on it.

## Process

- Small fixes — typos, broken links, a clearer gotcha — go straight to a PR.
- New recipes start as a [recipe proposal issue](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml) so two people don't write the same one, then a PR.
- Accepted recipes are credited in the recipe header and linked from the product blog when they fit a post.

## Before you open a PR

```bash
./scripts/sync-agent-rules.sh --check   # AGENTS.md must match CLAUDE.md
npx markdownlint-cli2 "**/*.md"         # same lint CI runs
```

If you edited `CLAUDE.md`, run `./scripts/sync-agent-rules.sh` (without `--check`) and commit the regenerated `AGENTS.md` — CI fails if the two drift.

Link checking runs in CI; localhost URLs are ignored by design ([.lycheeignore](./.lycheeignore)).

## Style

- British or American spelling, consistently within a file. Don't reformat someone else's file to switch.
- Tool names in `code`, product names in prose.
- Prefer the specific over the sweeping: "`capture_window` survives the window moving, not resizing" beats "captures are robust".
- One idea per sentence. These pages get skimmed by people deciding whether to trust the product.
