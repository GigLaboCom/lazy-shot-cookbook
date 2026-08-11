#!/usr/bin/env bash
# Render og.html to assets/brand/og-1200x630.png at exactly 1200x630.
#
# Headless Chrome rather than a design tool, for the same reason step.sh exists:
# the asset is reproducible from a text file. Change a word in og.html, re-run
# this, and the PNG is regenerated identically on any machine.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
out="$repo/assets/brand/og-1200x630.png"

chrome="${CHROME:-}"
if [ -z "$chrome" ]; then
  for candidate in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "$(command -v google-chrome || true)" \
    "$(command -v chromium || true)"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then chrome="$candidate"; break; fi
  done
fi

if [ -z "$chrome" ]; then
  echo "no Chrome or Chromium found; set CHROME=/path/to/binary" >&2
  exit 1
fi

# --window-size must match the body dimensions in og.html, or Chrome
# screenshots the viewport and you get a cropped or padded image.
"$chrome" --headless --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 \
  --screenshot="$out" \
  --window-size=1200,630 \
  "$here/og.html" 2>/dev/null

if command -v ffprobe >/dev/null 2>&1; then
  dims="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$out")"
  if [ "$dims" != "1200,630" ]; then
    echo "wrong size: got ${dims}, expected 1200,630" >&2
    exit 1
  fi
fi

echo "wrote $out ($(du -h "$out" | cut -f1))"
