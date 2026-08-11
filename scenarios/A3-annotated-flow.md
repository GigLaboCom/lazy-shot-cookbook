# A3 — the annotated documentation flow

**Output:** `assets/recipes/01-self-documenting-ui/annotated-flow.png`, 1280 wide, three panels.

The claim: documentation screenshots are build artifacts. The proof is three panels showing one capture becoming an annotated copy becoming a docs page — with the numbers matching across all three.

## Stage

```bash
cd scenarios/app
npm run dev                  # http://localhost:5173/#/settings
./step.sh 3                  # clean card layout
```

The settings screen has four labelled rows: workspace name, default currency, weekly digest, retention. Four rows, four markers — a clean numbered pass.

## Panels

| # | Prompt to paste | Yields |
| --- | --- | --- |
| 1 | `capture_window query "Google Chrome", keyword "settings-step-1". Report the file path.` | The raw capture |
| 2 | `add_markers on "settings-step-1", keyword "settings-step-1-markers", numbering the four controls in reading order: ① workspace name, ② default currency, ③ weekly digest, ④ retention. Give me the copy's path — do not touch the original.` | The annotated copy |
| 3 | `Read the annotated copy and write the docs snippet: the image, then a numbered caption list where each number matches its marker. Then ocr_screenshot "settings-step-1" and confirm every control label you wrote actually appears in the OCR text.` | The rendered docs |

The OCR check in panel 3 doesn't appear in the final image, but keep it in the run — it's what stops a docs page from describing a button that was renamed.

## Expected docs output

The agent should produce something like:

```markdown
![Workspace settings](./settings-step-1-markers.png)

1. **Workspace name** — the display name used across the app.
2. **Default currency** — applied to every new dashboard.
3. **Weekly digest** — a Monday summary email; off by default for new members.
4. **Retention** — how long raw events are kept before rollup.
```

## What each panel shows

**Panel 1** — the raw capture. Caption: `settings-step-1`.
**Panel 2** — the annotated copy with ①②③④. Caption: `settings-step-1-markers`.
**Panel 3** — the rendered docs snippet, numbered captions visible.

Panels 1 and 2 side by side are the argument that annotation **forks** rather than mutates. Don't crop either caption; the two different keywords are what proves there are two files.

## Compose

Three panels left to right at uniform height, 1280 wide total, thin gutters. Panel 3 can be a touch narrower — it's the payoff, not the evidence.

## Embed

Recipe 01, replacing the `TODO(assets): A3` placeholder:

```markdown
![A settings screen captured, the same capture forked into an annotated copy with four numbered markers, and the generated docs snippet whose captions match those numbers](../../assets/recipes/01-self-documenting-ui/annotated-flow.png)
```

## Checklist

- [ ] Marker numbers match the caption numbers across panels 2 and 3
- [ ] Both keywords legible — two files, visibly
- [ ] Markers centred on the controls, not floating between rows
- [ ] Panel 3 shows rendered Markdown, not raw source
