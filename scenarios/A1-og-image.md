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

**Already produced — it's checked in.** The source is [`og/og.html`](./og/og.html) and the renderer is [`og/render.sh`](./og/render.sh):

```bash
./scenarios/og/render.sh          # → assets/brand/og-1200x630.png
```

Headless Chrome, one page, no design tool. Same reasoning as `step.sh`: the asset is reproducible from a text file, so changing the tagline is a one-line edit and a re-run rather than a hunt for whoever has the source file. The script fails loudly if the output isn't exactly 1200×630.

This is the one asset that isn't a screenshot of anything, so the dogfood rule doesn't apply — it's about images *of the product*. Compose it in the Compositor on a custom canvas instead if you prefer; nothing depends on the HTML route.

### To change it

Edit `og/og.html`, re-run the script, look at the PNG. Then re-run the thumbnail check, which is what the whole design is tuned against:

```bash
ffmpeg -i assets/brand/og-1200x630.png \
  -vf "scale=300:-2:flags=lanczos,scale=900:-2:flags=neighbor" /tmp/og300.png
```

That downscales to link-card size and blows it back up with nearest-neighbour, so you see exactly the detail that survives. The title and tagline must stay readable; the subline is allowed to go soft.

Two deliberate deviations from the spec above, both documented in the CSS:

- **The tagline is `#e05252`, not `#8b0000`.** The icon's red on a near-black field fails contrast badly at any size. It's the same hue, lightened; the true `#8b0000` is used solid, in the rule under the title and in the bloom behind the icon.
- **The icon is the white variant** (`assets/brand/lazy-shot-icon-white.svg`, from the app's `icons/cat_aim_white.svg`). The standard mark is a black cat, which disappears on this background.

## After the file exists

Committing it is not enough. GitHub only uses a social preview if it's uploaded in **Settings → General → Social preview**. The file in the repo is the source of truth; uploading it is a separate manual step, and it's the step people forget.

## Checklist

- [x] Exactly 1200×630 — asserted by `render.sh`
- [x] Readable at 300px wide — verified with the downscale test above
- [x] Nothing important in the outer 100px — the frame's padding is 110px / 65px
- [x] Tool count matches the README — 23
- [ ] **Uploaded in repository Settings → General → Social preview** — the only step left, and the one people forget

## Known cosmetic issue

The crown in the source artwork carries a stray hairline off its top-right point. It's in `cat_aim_white.svg` as shipped with the app, not something this render introduces — visible at full size, invisible at link-card size. Fix it upstream in `heretic-lazy-shot/icons/` if it bothers you, then re-copy the SVG and re-run the script.
