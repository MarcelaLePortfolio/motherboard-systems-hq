#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:3000}"

html="$(curl -fsS "$BASE/" | head -c 200000)"

# Deterministic marker: the panel sets data-runs-panel="1"
echo "$html" | grep -q 'data-runs-panel="1"' || {
  echo 'FAIL: dashboard HTML missing runs panel marker data-runs-panel="1"'
  exit 1
}

# Optional: confirm the JS file name is present (best-effort)
echo "$html" | grep -q 'dashboard-tasks-widget.js' || {
  echo "WARN: dashboard HTML did not reference dashboard-tasks-widget.js (continuing)"
}

echo "OK: dashboard includes Runs panel marker."
