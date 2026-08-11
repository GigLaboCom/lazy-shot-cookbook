# Assets

Images used by the cookbook. The per-file specification — what each asset must contain, its size, and the embed snippet to paste — lives in **[docs/ASSETS.md](../docs/ASSETS.md)**. This file is the standing rules.

## Two rules

1. **Everything here is made with Lazy Shot.** Captured with the app, arranged and beautified in the Compositor. A cookbook for a screenshot tool illustrated with someone else's screenshot tool would be embarrassing.
2. **Nothing sensitive.** No tokens, emails, customer names, or file paths with real usernames. Redact in-app with **Spoiler** (heavy pixelation), not Blur — light blur over text can be reversed, and this repo says so out loud.

## Layout

```text
assets/
├── brand/      logo, icon, social image (trademarked — see LICENSE)
├── setup/      screenshots of the setup path itself
├── demo/       the 45-second demo video
└── recipes/    one subdirectory per recipe: NN-slug/
```

## Recordings

Lazy Shot captures stills; it has no video or GIF recording, and the Compositor exports PNG, JPEG and WebP. So the two GIFs and the demo video are recorded with your screen-recording tool of choice — what matters is that everything in frame is Lazy Shot doing real work at real speed.

Shot-by-shot scenarios with timings are in [docs/ASSETS.md](../docs/ASSETS.md#scenarios). An alternative for the two GIFs: export the capture sequence from the library and assemble the frames with `ffmpeg`, so every frame is a genuine library item.

## Conventions

- **Format:** PNG for stills, GIF for the two loops, MP4 (H.264) for the demo, WebP if a PNG would exceed 1 MB.
- **Width:** 1280px for full-width figures, 900px for setup screenshots. GitHub scales down; it doesn't scale up gracefully.
- **Size:** GIFs under 5 MB, PNGs under 1 MB, the video under 20 MB. README images load before anyone reads a word.
- **Naming:** the exact filenames in [docs/ASSETS.md](../docs/ASSETS.md) — recipes and the checklist reference them by name.
- **Theme:** light, unless the asset is specifically about dark mode.
- **Scope:** capture the window, not the display. It's what keeps the surrounding desktop out of a public repo.
- **Alt text is mandatory.** Describe what happens, never `![screenshot]`. The snippets in the spec already have it written.
- **Burned-in keyword captions** are part of the asset wherever the spec asks for them — half of these images exist to make the naming convention visible.

## What's still missing

Placeholders sit in the target files as `<!-- TODO(assets): A<n> — … -->`. Grep `TODO(assets)` to see what's outstanding and exactly where it goes.
