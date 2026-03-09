#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8080/dashboard}"
TMP_HTML="$(mktemp)"
TMP_HEADERS="$(mktemp)"
trap 'rm -f "$TMP_HTML" "$TMP_HEADERS"' EXIT

curl -fsS -D "$TMP_HEADERS" "$URL" -o "$TMP_HTML"

echo "🔎 Verifying dashboard layout at: $URL"

required_markers=(
  'Operator Workspace'
  'Chat'
  'Task Delegation'
  'Telemetry Workspace'
  'Recent Tasks'
  'Task History'
  'Task Events'
  'Atlas Subsystem Status'
)

missing=0
for marker in "${required_markers[@]}"; do
  if grep -Fq "$marker" "$TMP_HTML"; then
    echo "✅ Found: $marker"
  else
    echo "❌ Missing marker: $marker"
    missing=1
  fi
done

echo
echo "ℹ️ HTTP headers:"
sed -n '1,20p' "$TMP_HEADERS"

echo
if [ "$missing" -eq 0 ]; then
  echo "✅ Layout contract PASSED."
else
  echo "🧯 Layout contract FAILED."
  exit 1
fi
