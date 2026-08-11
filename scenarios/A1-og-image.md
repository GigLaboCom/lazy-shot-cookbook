# A1 — the social preview

**Output:** `assets/brand/og-1200x630.png`, exactly 1200×630, under 500 KB.

The most-seen asset in the repository, by people who haven't decided to click yet. It has one job: make "a screenshot app that is also an MCP server" legible in the second and a half someone spends on a link card.

## Contents

- The cat-in-crosshair icon (`assets/brand/lazy-shot-logo.svg`), left or centred, generous margin
- **Lazy Shot Cookbook** — the title, large
- **Give your agent eyes.** — the line, one size down
- `23 MCP tools · macOS + Windows · one-time licence` — the subline, small and muted

Dark background, the icon's dark red (`#8b1a1a`) as the only accent. No screenshot inside it — link cards render small, and a screenshot-inside-a-screenshot turns to mush.

## Safe area

Platforms crop this differently. Keep everything meaningful inside the centre 1000×500; treat the outer 100px as bleed. Test at 300px wide — if the tagline stops being readable there, the type is too small.

## Produce

The one asset that isn't a screenshot of anything. Compose it in the Compositor on a custom 1200×630 canvas, or in any design tool. If the Compositor route is awkward for pure typography, don't force it — the dogfood rule is about images *of the product*.

## After the file exists

Committing it is not enough. GitHub only uses a social preview if it's uploaded in **Settings → General → Social preview**. The file in the repo is the source of truth; uploading it is a separate manual step, and it's the step people forget.

## Checklist

- [ ] Exactly 1200×630
- [ ] Readable at 300px wide
- [ ] Nothing important in the outer 100px
- [ ] Uploaded in repository Settings → General → Social preview
- [ ] Tool count matches the README
