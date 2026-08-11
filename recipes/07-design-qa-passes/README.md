# Recipe 07 — Design QA passes with marker-preset checklists

> **Status: proposed.** The workflow below is complete and internally consistent, but hasn't been through a full validation pass yet. Kick the tires and [tell us what breaks](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml).

**Problem:** design review is the least reproducible process in software. Feedback lives in Slack threads and screenshots-of-screenshots, every reviewer checks different things, and "did anyone look at the German dark-mode empty state?" has no answer.

**Idea:** encode the review checklist as a **marker preset** — a saved, named layout of numbered badges. Every screen gets the identical numbered pass, findings attach to numbers, and the report writes itself. This is the workflow marker presets were built for.

## Two modes

**Checklist mode** — the same numbered points on every screen. Define the preset once in the app (markers are a metadata layer, so build it on any capture): ① header/title, ② primary action, ③ empty state, ④ error state, ⑤ footer/legal — whatever your five points are. Save it as `ui-review-5`.

**Findings mode** — the agent places explicit-coordinate markers on each defect it actually spots, and the auto-incrementing numbers become the line items of the review.

## Copy-paste prompt (checklist mode)

```text
Design QA pass "<pass-name>" over these screens: <list>.
For each screen:
1. capture_window with the app query and keyword
   "<screen>-review-<pass-name>".
2. get_marker_preset "ui-review-5" so you know what each number means and
   where it sits; add_markers using that preset (this forks a marker
   layer — its pixels match the original, so don't expect to see badges).
3. Read the ORIGINAL capture, and use the preset coordinates to locate
   each numbered point in it. For each point give a verdict: PASS, or a
   one-line finding.
Compile the pass into one report:
| screen | ① | ② | ③ | ④ | ⑤ |  — PASS or the finding, with the capture's
file_path per row. Findings that are bugs get a suggested "<slug>" for
recipe-02 treatment.
```

## Copy-paste prompt (findings mode)

```text
Free review of "<screen>": capture_window, keyword
"<screen>-findings-<date>". Read the capture and hunt specifically for:
truncated labels, misaligned elements, inconsistent spacing rhythm,
low-contrast text, mixed icon styles, dark-mode leaks, untranslated
strings. add_markers with explicit coordinates on every defect found, in
severity order. Report: marker № → defect → severity → suggested fix.
```

## The localisation pass, done properly

"Untranslated strings" is the one finding a human reviewer misses most reliably and OCR catches every time:

```text
For each screen, in each locale: capture_window, then ocr_screenshot with
lang set to that locale's language plus eng (e.g. "deu+eng"). Flag every
string that is still English in a non-English locale, and every string
whose box is wider than its container looks in the image (truncation
candidate). Then place markers on the flagged words using their OCR
bounding-box centres.
```

Run it across your locale × theme matrix and the pass becomes a table nobody had to click through — Lazy Shot's own EN/RU/DE × three themes is the house example.

## Why presets and not prose

- **Consistency:** every screen, every release, the same numbered pass. Review quality stops depending on who reviewed.
- **Reapplication is free:** next release, the agent reapplies `ui-review-5` to fresh captures. The checklist survives the UI it checks.
- **Numbers are addresses:** "③ fails on Settings" is a complete, unambiguous finding. Slack threads can't do that.
- **Nothing is destroyed:** marker layers for the addressing, pristine originals for the record, and every past pass stays searchable by its `-review-` keyword.

## Fits the other recipes

Findings that are real bugs graduate to [recipe 02](../02-visual-bug-fixing/) — the `<slug>-before` evidence already exists, it's this capture. Screens that pass graduate to [recipe 01](../01-self-documenting-ui/) and become documentation. One capture, three lifecycles.

## Tools used

`capture_window` · `assign_keyword` · `add_markers` · `list_marker_presets` · `get_marker_preset` · `search_marker_presets` · `ocr_screenshot` · `search_screenshots`

## Gotchas

- Preset **creation** is an in-app act (place markers, save the set). MCP can list, get, search and apply presets, not author them. Deliberate: the checklist is a human decision.
- **The numbers are addresses, not pictures.** Markers are metadata and are never drawn into a file, including on export — so an agent that applies a preset and then "reads the annotated copy" is looking at an unmarked screenshot. It must get the positions from `get_marker_preset` or `get_screenshot`'s `metadata.markers` and correlate them with the image itself. The prompts above do this; if you write your own, don't skip it. ([Details](../../docs/TOOLS.md#add_markers).)
- Agent vision is strong on truncation, contrast, inconsistency and missing states; weak on exact pixel measurements. "Spacing looks off at ②" is a flag for a human with a ruler, not a verdict.
- Preset marker positions are absolute coordinates — they assume a consistent window size across screens, same as [recipe 06](../06-visual-regression-watch/)'s stability rules.
- OCR truncation detection is a heuristic, not a measurement: it flags candidates worth a human glance, and it will produce false positives on intentionally clipped text.
