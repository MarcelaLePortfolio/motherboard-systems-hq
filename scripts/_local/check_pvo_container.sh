#!/usr/bin/env bash
set -euo pipefail

URL="${1:-[http://127.0.0.1:8080/dashboard}](http://127.0.0.1:8080/dashboard})"

echo "=== Fetch: $URL ==="
HTML="$(curl -fsS "$URL")"

echo
echo "=== Count: id="project-visual-output" (must be 1) ==="
echo "$HTML" | grep -o 'id="project-visual-output"' | wc -l | awk '{print "count=" $1}'

echo
echo "=== Lines containing project-visual-output-card (single grep -n) ==="
echo "$HTML" | nl -ba | grep -n "project-visual-output-card" || true

echo
echo "=== Lines containing project-visual-output (single grep -n) ==="
echo "$HTML" | nl -ba | grep -n "project-visual-output" | head -n 50 || true

echo
echo "=== Asset HEAD checks (css/js) ==="
BASE="$(printf "%s" "$URL" | sed -E 's#(/dashboard|/dashboard/)?$##')"
curl -I --max-time 10 "${BASE}/css/dashboard.css" | head -n 8 || true
curl -I --max-time 10 "${BASE}/js/dashboard-tasks-widget.js" | head -n 8 || true

echo
echo "OK: check complete."
