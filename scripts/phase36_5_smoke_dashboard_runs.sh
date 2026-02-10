#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE_URL:-http://127.0.0.1:3000}"

html="$(curl -fsS "$BASE/" | head -c 300000)"

# 1) Dashboard HTML should reference the widget JS (server-side deterministic)
echo "$html" | grep -q 'dashboard-tasks-widget.js' || {
  echo "FAIL: dashboard HTML did not reference dashboard-tasks-widget.js"
  exit 1
}

# 2) Fetch that JS and ensure it contains the deterministic marker logic (build-time deterministic)
js="$(curl -fsS "$BASE/js/dashboard-tasks-widget.js" | head -c 500000)"

# Accept either HTML marker or dataset assignment as evidence
echo "$js" | grep -q 'data-runs-panel="1"\|dataset\.runsPanel\s*=\s*"1"' || {
  echo 'FAIL: dashboard-tasks-widget.js missing runs panel marker ("data-runs-panel=\"1\"" or dataset.runsPanel="1")'
  exit 1
}

# 3) Optional: verify /api/runs is reachable
curl -fsS "$BASE/api/runs?limit=1" >/dev/null || {
  echo "FAIL: /api/runs not reachable"
  exit 1
}

echo "OK: dashboard references tasks widget JS; JS contains Runs panel marker; /api/runs reachable."
