#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "=== 1) probe baseline (expect 200) ==="
curl -fsS -o /dev/null -w "GET /api/policy/probe => %{http_code}\n" "$BASE_URL/api/policy/probe"

echo
echo "=== 2) task mutation baseline (expect NOT 403) ==="
curl -sS -o /dev/null -w "POST /api/tasks => %{http_code}\n" -X POST "$BASE_URL/api/tasks" \
  -H "content-type: application/json" \
  --data '{}' || true

echo
echo "=== 3) probe enforce (expect 403) ==="
# Caller supplies the same env/flag they used in Phase 48 to flip enforce on.
# This smoke assumes server already running with enforcement enabled when you run step 3.
curl -sS -o /dev/null -w "GET /api/policy/probe => %{http_code}\n" "$BASE_URL/api/policy/probe" || true

echo
echo "=== 4) task mutation enforce (expect 403) ==="
curl -sS -o /dev/null -w "POST /api/tasks => %{http_code}\n" -X POST "$BASE_URL/api/tasks" \
  -H "content-type: application/json" \
  --data '{}' || true
