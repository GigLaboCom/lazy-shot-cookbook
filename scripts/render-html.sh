#!/usr/bin/env bash
# Render a self-contained HTML file to a PNG of an exact size, with headless
# Chrome. Used for the assets that are typeset rather than photographed.
#
#   scripts/render-html.sh <input.html> <output.png> <width> <height>
#
# The HTML's <body> must be exactly width x height, or Chrome pads/crops it.
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "usage: $0 <input.html> <output.png> <width> <height>" >&2
  exit 2
fi

input="$1"
output="$2"
width="$3"
height="$4"

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

"$chrome" --headless --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 \
  --screenshot="$output" \
  --window-size="${width},${height}" \
  "$input" 2>/dev/null

if command -v ffprobe >/dev/null 2>&1; then
  dims="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$output")"
  if [ "$dims" != "${width},${height}" ]; then
    echo "wrong size: got ${dims}, expected ${width},${height}" >&2
    exit 1
  fi
fi

echo "wrote $output ($(du -h "$output" | cut -f1))"
