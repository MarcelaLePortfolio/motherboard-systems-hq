#!/bin/bash
set -euo pipefail

echo "=== TEMPORARY SSE DISABLE (ISOLATION TEST) ==="

# Comment out EventSource usage across public JS files
find public/js -type f -name "*.js" -print0 | while IFS= read -r -d '' file; do
  sed -i '' 's/new EventSource(/\/\/ PHASE488_DISABLED new EventSource(/g' "$file" || true
done

echo "=== REBUILD DASHBOARD ==="
docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== OPEN CLEAN SESSION ==="
open -na "Google Chrome" --args --incognito --auto-open-devtools-for-tabs http://localhost:8080/

echo
echo "=== TEST ==="
echo "1. Hard refresh"
echo "2. Click Quick check once"
echo
echo "If Matilda replies -> CONFIRMED SSE exhaustion root cause"
echo "If still timeout -> not SSE related"
