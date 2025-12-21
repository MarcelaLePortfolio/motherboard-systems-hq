#!/usr/bin/env bash
set -euo pipefail

BASE="${1:-http://127.0.0.1:8080}"

echo "🔎 Verifying dashboard layout at: $BASE/dashboard"

html="$(curl -fsS "$BASE/dashboard")"

markers=(
  "Matilda Chat Console"
  "Task Delegation"
  "System Reflections"
  'id="project-visual-output-card"'
)

missing=0
for m in "${markers[@]}"; do
  if ! grep -qF "$m" <<<"$html"; then
    echo "❌ Missing marker: $m"
    missing=1
  else
    echo "✅ Found: $m"
  fi
done

echo
echo "ℹ️ bundle.js cache-bust (if present):"
grep -oE '/bundle\.js\?v=[0-9]+' <<<"$html" | head -n 1 || echo "(none found)"

echo
echo "ℹ️ HTTP headers:"
curl -sSI "$BASE/dashboard" | rg -ni "HTTP/|cache-control|pragma|expires|etag|last-modified|content-type|location:" || true

if [ "$missing" -ne 0 ]; then
  echo
  echo "🧯 Layout contract FAILED."
  echo "Suggested recovery: git checkout v14.8-dashboard-ux-restored -- public/ && docker compose up -d --build"
  exit 2
fi

echo
echo "🎉 Layout contract PASSED."
