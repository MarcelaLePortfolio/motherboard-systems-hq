#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== dashboard bundle cache key =="
curl -fsS "$BASE_URL/dashboard" | rg -n 'bundle\.js\?v='

echo "== health =="
curl -fsS "$BASE_URL/api/health"
echo

echo "== runs sample =="
curl -fsS "$BASE_URL/api/runs" | head -c 2000
echo

echo "== phase58d source present =="
rg -n 'phase58d_operator_console\.js' public/js/dashboard-bundle-entry.js

echo "== phase58d built bundle markers =="
rg -n 'Operator Console|Probe lifecycle is the primary signal|Empty panels are intentional|data-phase58d-primary|phase58d-operator-console' public/bundle.js
