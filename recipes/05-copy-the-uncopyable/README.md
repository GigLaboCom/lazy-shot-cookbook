# Recipe 05 — Copy the uncopyable

**Problem:** the most important text on your screen is often the text you can't select. Error dialogs. Legacy desktop apps. RDP and VM sessions. A colleague's screen share on a call. A BI dashboard with no export button. A chart that *is* the data.

**Idea:** capture it, name it, and get structured output back — a diagnosis, a config file, a Markdown table, JSON. The screenshot stays in the library as the citable source.

The twist that makes this recipe different from "take a screenshot and ask the model": Lazy Shot has **two** ways to read a screen, and they fail in opposite directions. Choosing correctly is the whole skill.

<!-- TODO(assets): A7 — assets/recipes/05-copy-the-uncopyable/ocr-to-markers.png — spec in docs/ASSETS.md -->

## Two blades

| | `ocr_screenshot` (Tesseract, local) | Agent vision (read the file) |
| --- | --- | --- |
| **Good at** | Exact characters, long dense text, logs, IDs, stack traces | Structure, layout, meaning, mixed content, "what does this *mean*" |
| **Bad at** | Column structure, reading order in complex layouts, stylised text | Exactness — it will smooth a typo'd token into a plausible one |
| **Confidence** | Reports a per-word score you can filter on | Sounds equally certain either way |
| **Privacy** | Fully on-device. Nothing leaves the machine | With a cloud model, the pixels go to your model provider |
| **Cost** | Free, ~instant | Vision tokens per look |

The honest headline: **capture is always local; *reading by a cloud agent* is not.** For a confidential screen, OCR it locally and let the agent work on the text — or redact first ([recipe 02](../02-visual-bug-fixing/), principle 5).

Best results usually come from using both: OCR for the characters, vision for what they mean.

## The loop

```text
capture (window / region, keyword "grab-<what>")
        │
        ├──▶ ocr_screenshot ──▶ verbatim text ──┐
        │                                       ├──▶ structured output
        └──▶ agent reads file_path ─────────────┘    (table / JSON / config / diagnosis)
                                                          │
              later: "where did that number come from?" ──▶ open_screenshot
```

## Copy-paste prompt (Claude Code / Claude Desktop)

```text
When I say "grab this":
1. capture_window on the app I name (or capture_region if I gave
   coordinates — list_displays first on multi-monitor), keyword
   "grab-<short-content-slug>". Returned keyword wins.
2. Call ocr_screenshot on it. If the content isn't English, pass lang
   (e.g. "eng+deu"); call list_ocr_languages if unsure.
3. Then read the image yourself, and reconcile:
   - error dialog → the OCR text verbatim as the error, your diagnosis
     from the image, next step
   - settings/config screen → an equivalent config file or CLI flags
   - table → Markdown table; use the image for column structure and the
     OCR text for the values
   - chart → the trend in words plus approximate key values, clearly
     labelled as read-from-pixels approximations
   - screen share → decisions and action items with owners
4. If OCR and your reading of the image disagree on a character, say so
   instead of picking silently.
5. End with "source: <keyword> → <file_path>" so the extraction is
   auditable.
```

## Confidence instead of confidence-sounding

`ocr_screenshot` with `format: "metadata"` returns every recognised word with a bounding box and a confidence score of 0–100. That gives the agent something it otherwise never has: a *calibrated* signal about its own reading.

```text
ocr_screenshot format "metadata". Report any word under 60 confidence as
"unclear" rather than guessing it. If the unclear word is load-bearing —
an ID, a number, a filename — tell me to enlarge the source window and
re-capture instead of proceeding.
```

For a licence key or an order number, "I can't read character 7 reliably" is worth far more than a fluent guess.

## Bounding boxes are marker coordinates

The same metadata makes the agent able to *point*. Each word's box centre is exactly what `add_markers` wants:

```text
After OCR, place markers on the words I asked about: take each match's
bounding box, use its centre as the marker x/y, and add_markers with the
matches numbered in reading order. Give me the marker layer's path and
tell me which OCR box each coordinate came from.
```

"The error mentions three different timeouts — ① ② ③" with badges landing on the actual words, from a tool chain that never guessed a coordinate. This is the payoff of markers and OCR living in the same app.

Two things to be clear about, because this is the recipe where the temptation to over-claim is strongest. First, the badges land in **metadata**, not pixels — markers are never drawn into a file, including on export. Open the layer in the app and toggle markers on and you'll see them sitting exactly on the words; paste the path into a README and you'll see a plain screenshot. Second, that's usually fine here: the value is that the agent knows *where* the phrase is and can say so in coordinates it didn't invent. When you do need the badges in a shipped image, either capture the app with markers visible, or place **Counter** annotations by hand. ([Details](../../docs/TOOLS.md#add_markers).)

## Worked examples

- **The 40-line stack trace in a modal that won't let you select text.** Grab → OCR verbatim → agent diagnoses → you never retype a `NullReferenceException` by hand again.
- **A legacy ERP's settings screens before a migration.** Grab each tab → agent emits one YAML capturing the whole configuration → the migration has a source of truth with screenshots backing every line.
- **Quarterly numbers in a dashboard with no export.** Grab the table region → OCR the values, vision for the column structure → Markdown table with `source: grab-q3-revenue` under it.
- **A screen share during an incident call.** Grab the shared Grafana view at the key moment → afterwards the agent writes the timeline from the captures (pairs with [recipe 08](../08-dashboard-watch/)).
- **A scanned PDF page or an old screenshot already on disk.** `ocr_image_path` with an optional `region` reads a file directly — no re-capture — as long as it lives inside the screenshots or app-data directory.

## Tools used

`capture_window` · `capture_region` · `capture_active_window` · `list_displays` · `assign_keyword` · `ocr_screenshot` · `ocr_image_path` · `list_ocr_languages` · `add_markers` · `open_screenshot` · `search_screenshots`

## Gotchas

- **Resolution is fixed at capture time.** A tighter region does not add pixels. Enlarge the source window *before* grabbing; don't crop harder afterwards. If OCR comes back garbled, try `variant: "best"` before re-capturing — it's 5–10× slower but noticeably better on low-DPI text.
- **Set `lang` deliberately.** Running English OCR over Cyrillic or Japanese produces confident nonsense. `list_ocr_languages` shows what's installed; missing packs auto-download (~4 MB, one time). Mixed content takes `eng+rus` syntax and is slower.
- **OCR flattens layout.** Multi-column tables and side-by-side panels come back in an order that may not match reading order. Use the image for structure, OCR for characters — that's why the prompt asks for both.
- **Numbers read off charts are estimates.** The prompt forces the agent to label them as such. Keep that line.
- **`ocr_image_path` is path-restricted** to the screenshots and app-data directories. That's a security boundary — it's not going to OCR `~/Documents` for you, and shouldn't.
