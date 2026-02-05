#!/usr/bin/env bash
set -euo pipefail
: "${BASE_URL:=http://127.0.0.1:8080}"
: "${RUN_ID:?set RUN_ID=<run_id>}"
: "${TOKEN:=}"

RUN_ID="$(printf "%s" "$RUN_ID" | tr -d '\r' | tail -n 1 | xargs)"
[ -n "$RUN_ID" ] || { echo "ERROR: RUN_ID empty after sanitize"; exit 1; }

H=(-sS -D -)
if [ -n "$TOKEN" ]; then
  H+=(-H "Authorization: Bearer $TOKEN")
fi

echo "=== GET $BASE_URL/api/runs/$RUN_ID ==="
curl "${H[@]}" "$BASE_URL/api/runs/$RUN_ID" | sed -n '1,160p'
