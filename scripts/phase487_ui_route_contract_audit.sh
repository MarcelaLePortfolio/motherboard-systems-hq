#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — UI ROUTE CONTRACT AUDIT (LITE)"
echo "────────────────────────────────"

BASE_URL="${BASE_URL:-http://localhost:8080}"
TMP_HTML="$(mktemp)"
TMP_ROUTES="$(mktemp)"
trap 'rm -f "$TMP_HTML" "$TMP_ROUTES"' EXIT

curl -fsS "$BASE_URL" > "$TMP_HTML"

grep -Eo '/api/[A-Za-z0-9._/-]+|/events/[A-Za-z0-9._/-]+|/diagnostics/[A-Za-z0-9._/-]+' "$TMP_HTML" \
  | sort -u > "$TMP_ROUTES" || true

for path in \
  /api/health \
  /api/tasks \
  /api/runs \
  /api/guidance \
  /diagnostics/system-health
do
  code="$(curl -o /dev/null -s -w '%{http_code}' --max-time 5 "$BASE_URL$path" || true)"
  echo "$path $code"
done

echo
echo "served-html-route-hints:"
cat "$TMP_ROUTES" || true

echo
echo "repo-contract-hints:"
rg -n '/api/chat|/api/delegate-task|/api/tasks-mutations|/api/guidance|/diagnostics/system-health|/events/tasks|/events/ops|/events/reflections' \
  public server scripts/_local app \
  -g '!node_modules' \
  -g '!.next' \
  -g '!dist' \
  -g '!.runtime' \
  | sed -n '1,120p' || true
