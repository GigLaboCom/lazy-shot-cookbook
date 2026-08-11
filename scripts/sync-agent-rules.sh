#!/usr/bin/env bash
# Regenerate AGENTS.md from the shared block in CLAUDE.md.
#
# CLAUDE.md is the drop-in file for Claude Code / Claude Desktop; AGENTS.md is
# the vendor-neutral copy for every other agent that looks for that filename.
# The rules themselves must never drift, so exactly one file is authored by
# hand and the other is generated from it.
#
#   ./scripts/sync-agent-rules.sh          regenerate AGENTS.md
#   ./scripts/sync-agent-rules.sh --check  fail if AGENTS.md is stale (CI)

set -euo pipefail

cd "$(dirname "$0")/.."

SOURCE="CLAUDE.md"
TARGET="AGENTS.md"

header() {
  cat <<'EOF'
# Screenshots: Heretic Lazy Shot

<!-- GENERATED FILE — edit CLAUDE.md and run ./scripts/sync-agent-rules.sh
     Vendor-neutral copy of the drop-in agent rules. Drop it into your project
     root next to (or instead of) CLAUDE.md.
     Requires Lazy Shot running with the MCP server enabled: Settings → MCP.
     Endpoint: http://localhost:5055/mcp (streamable-http).
     Source: https://github.com/GigLaboCom/lazy-shot-cookbook -->
EOF
}

body() {
  awk '/SHARED:BEGIN/{flag=1; next} /SHARED:END/{flag=0} flag' "$SOURCE"
}

if ! grep -q 'SHARED:BEGIN' "$SOURCE"; then
  echo "error: $SOURCE has no SHARED:BEGIN marker" >&2
  exit 1
fi

# Command substitution strips trailing newlines, so the blank line that
# separates the header comment from the body is re-added explicitly here.
generated="$(printf '%s\n\n%s' "$(header)" "$(body)")"

if [[ "${1:-}" == "--check" ]]; then
  if ! diff -u <(printf '%s\n' "$generated") "$TARGET" >/dev/null 2>&1; then
    echo "error: $TARGET is out of sync with $SOURCE" >&2
    echo "run ./scripts/sync-agent-rules.sh and commit the result" >&2
    diff -u "$TARGET" <(printf '%s\n' "$generated") || true
    exit 1
  fi
  echo "ok: $TARGET is in sync with $SOURCE"
else
  printf '%s\n' "$generated" > "$TARGET"
  echo "wrote $TARGET"
fi
