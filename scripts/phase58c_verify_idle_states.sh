#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== dashboard shell markers =="
curl -fsS "$BASE_URL/dashboard" | rg -n 'reflections-list|ops-alerts-list|phase16-sse-indicator-text|bundle\.js|dashboard-bundle-entry\.js' || true

echo "== health =="
curl -fsS "$BASE_URL/api/health"
echo

echo "== runs sample =="
curl -fsS "$BASE_URL/api/runs" | head -c 2000
echo

echo "== bundle entry includes phase58c =="
rg -n 'phase58c_idle_states\.js' public/js/dashboard-bundle-entry.js

echo "== built bundle includes phase58c =="
rg -n 'Waiting for first reflection|No agent signals yet|Waiting for first task event beyond heartbeat|SSE: idle|reflections: idle' public/bundle.js

echo "== source idle strings present =="
rg -n 'Waiting for first reflection|No agent signals yet|Waiting for first task event beyond heartbeat|SSE: idle|reflections: idle' public/js/phase58c_idle_states.js
