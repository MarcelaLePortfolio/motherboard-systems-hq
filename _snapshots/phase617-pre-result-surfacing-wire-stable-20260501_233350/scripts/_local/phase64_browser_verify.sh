#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/dashboard}"

SNIPPET_FILE="$(mktemp)"
trap 'rm -f "$SNIPPET_FILE"' EXIT

cat > "$SNIPPET_FILE" << 'JS'
(() => {
  const out = {
    hasDebug: Boolean(window.__PHASE64_AGENT_ACTIVITY_DEBUG),
    snapshot: window.__PHASE64_AGENT_ACTIVITY_DEBUG?.snapshot?.() ?? null,
    cards: window.__PHASE64_AGENT_ACTIVITY_DEBUG?.cards?.() ?? null,
    html: document.getElementById('agent-status-container')?.outerHTML ?? null
  };
  console.log("PHASE64_BROWSER_VERIFY", out);
  return out;
})()
JS

echo "== Phase 64 browser verify =="
echo "URL=$URL"
echo

if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$SNIPPET_FILE"
  echo "Console snippet copied to clipboard."
else
  echo "pbcopy not available; snippet path: $SNIPPET_FILE"
fi

echo
echo "1) Open dashboard"
echo "2) Hard refresh"
echo "3) Paste clipboard into browser console"
echo "4) Copy the PHASE64_BROWSER_VERIFY result back into chat"

if command -v open >/dev/null 2>&1; then
  open "$URL"
fi
