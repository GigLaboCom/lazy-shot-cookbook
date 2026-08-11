# Recipe 08 — Dashboard watch: judgment-based alerting

> **Status: proposed.** The workflow below is complete and internally consistent, but hasn't been through a full validation pass yet. Kick the tires and [tell us what breaks](https://github.com/GigLaboCom/lazy-shot-cookbook/issues/new?template=recipe-proposal.yml).

**Problem:** dashboards are built for a human glance — and nobody glances at 03:00. Threshold alerts catch the failures you predicted; the ones that get you are the charts that just *look wrong*: a queue draining too slowly, a heatmap with a new stripe, a panel silently showing "No data".

**Idea:** put the glance on a schedule. Your scheduler captures the dashboard through Lazy Shot, an LLM step compares the picture against a keyworded known-good baseline, and alerts arrive **with the screenshot attached** — evidence-first alerting that complements, never replaces, your threshold rules.

## Prerequisites

- One always-on machine running **both** Lazy Shot and your scheduler (self-hosted n8n, a cron-driven agent, whatever you already operate). Captures are local, so the eyes and the scheduler must share a filesystem. An idle mini PC is exactly enough.
- The dashboard in a **dedicated browser window** at a fixed size, on a machine that doesn't sleep or lock. A locked screen photographs a lock screen.

## Setup: the baseline

Once, by hand, on a known-good day:

```text
capture_window "Grafana" with keyword "dash-<name>-baseline"
```

Re-shoot the baseline whenever the dashboard layout legitimately changes.

## The flow

```text
Schedule (*/15) ──▶ capture_window "Grafana", keyword "dash-<name>-check"
                     (collisions auto-suffix: -check-2, -check-3 — the
                      suffix numbers your series for free)
                ──▶ cheap gate: magick compare vs baseline, or
                    ocr_screenshot and grep for "No data" / "Error"
                ──▶ if the gate fires: LLM step reads candidate + baseline
                      "Compare candidate to baseline. Ignore expected drift:
                       changing values, moving time axis. Flag structural
                       anomalies: missing or empty panels, 'No data', error
                       banners, flatlined or spiking shapes, new colours.
                       Reply VERDICT: OK or VERDICT: ANOMALY + one paragraph."
                ──▶ if ANOMALY ──▶ notify with the candidate file attached
                              └─▶ else: end, silently
```

With an MCP-capable scheduler the capture steps are ordinary tool calls against `http://localhost:5055/mcp`; with a plain cron job, a one-shot agent invocation does the same thing.

## The cheapest gate is text, not pixels

Most dashboard failures announce themselves in words: "No data", "Query error", "N/A", a panel title without a number under it. `ocr_screenshot` finds those on-device, for free, in under a second:

```text
ocr_screenshot the check capture. If the text contains any of:
"No data", "Error", "N/A", "Failed", "timeout" — alert immediately with
the matched string, and skip the vision comparison entirely.
Otherwise run the vision step.
```

That single filter catches the majority of real incidents at zero token cost, and it turns the vision call into the exception rather than the rule.

## Housekeeping

A weekly agent chore keeps the series tidy without losing history:

```text
search_screenshots "dash-<name>-check" with date_to = 30 days ago —
soft-delete everything returned except captures referenced in an
incident. Report the count.
```

Soft delete means "cleaned up" never means "gone" — filter to `status: "deleted"` any time.

## During the incident

This is where the library pays out. `search_screenshots` with `date_from` / `date_to` replays the dashboard's actual appearance across the incident window — the postmortem gets *what the humans would have seen*, not just what Prometheus stored. Pair with [recipe 05](../05-copy-the-uncopyable/) to extract exact numbers from any captured frame.

## Cost & cadence honesty

Every vision check is an LLM call. At 15-minute cadence that's roughly 2,900 calls a month per dashboard — fine with a small vision model, worth thinking about with a frontier one. Tune the cadence to the dashboard's blast radius, and put the OCR gate in front so the expensive tier only runs when something already looks off.

## Tools used

`capture_window` · `assign_keyword` · `ocr_screenshot` · `search_screenshots` · `get_screenshot` · `delete_screenshot` — orchestrated by whatever scheduler you already run.

## Gotchas

- This is **judgment-based** alerting: it will catch "this looks wrong", and it will occasionally be wrong about it. Route it to a channel, not to PagerDuty severity 1.
- Browser-window discipline is the whole reliability story: fixed size, fixed monitor, auto-refresh on, a session that doesn't expire — or the watch alerts on your login page, which is, to be fair, also an anomaly worth knowing about.
- Captures are silent, which cuts both ways here: the watch won't interrupt anyone, and it also won't tell you it stopped working. Alert on *absence* too — if no new `dash-<name>-check` capture appeared in the last hour, something died.
- If your scheduler runs in a container, the screenshots directory must be mounted at the same path that appears in the tool responses, or downstream steps will read a path that doesn't exist.
