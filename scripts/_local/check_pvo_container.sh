#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/dashboard}"

# Guardrail: refuse Markdown-style URLs like [http://...](http://...)
if printf "%s" "$URL" | grep -qE '^\[https?://.*\]\(https?://'; then
  echo "ERROR: URL looks like Markdown, not a raw URL:" >&2
  echo "  $URL" >&2
  echo "Use:" >&2
  echo "  ./scripts/_local/check_pvo_container.sh http://127.0.0.1:8080/dashboard" >&2
  exit 2
fi

echo "=== Fetch: $URL ==="
HTML="$(curl -fsS "$URL")"

echo
echo '=== Count: id="project-visual-output" (must be 1) ==='
echo "$HTML" | grep -o 'id="project-visual-output"' | wc -l | awk '{print "count=" $1}'

echo
echo '=== Lines containing project-visual-output-card ==='
echo "$HTML" | nl -ba | grep 'project-visual-output-card' || true

echo
echo '=== Lines containing project-visual-output ==='
echo "$HTML" | nl -ba | grep 'project-visual-output' | head -n 50 || true

echo
echo "=== Asset HEAD checks (css/js) ==="
BASE="$(printf "%s" "$URL" | sed -E 's#(/dashboard|/dashboard/)?$##')"
curl -I --max-time 10 "${BASE}/css/dashboard.css" | head -n 8 || true
curl -I --max-time 10 "${BASE}/js/dashboard-tasks-widget.js" | head -n 8 || true

echo
echo "OK: check complete."
