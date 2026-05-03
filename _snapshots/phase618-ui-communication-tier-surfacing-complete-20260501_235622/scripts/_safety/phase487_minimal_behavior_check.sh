#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 MINIMAL BEHAVIOR CHECK ==="

BASE_URLS=(
  "http://127.0.0.1:3001"
  "http://127.0.0.1:3000"
)

PATHS=(
  "/tasks/recent"
  "/logs/recent"
  "/diagnostics/systemHealth"
)

echo
echo "=== Probing known local targets ==="
for base in "${BASE_URLS[@]}"; do
  echo "--- BASE: $base ---"
  for path in "${PATHS[@]}"; do
    echo ">>> GET $base$path"
    curl -sS -m 3 -i "$base$path" | sed -n '1,20p' || echo "(request failed)"
    echo
  done
done

echo "=== END PHASE 487 MINIMAL BEHAVIOR CHECK ==="
