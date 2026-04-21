#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — UI ROUTE CONTRACT AUDIT"
echo "────────────────────────────────"

BASE_URL="${BASE_URL:-http://localhost:8080}"
TMP_HTML="$(mktemp)"
TMP_ASSETS="$(mktemp)"
TMP_ROUTE_HITS="$(mktemp)"
trap 'rm -f "$TMP_HTML" "$TMP_ASSETS" "$TMP_ROUTE_HITS"' EXIT

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== git status --short =="
git status --short

echo
echo "== docker compose ps =="
docker compose ps

echo
echo "== fetch dashboard html =="
curl -fsS "$BASE_URL" > "$TMP_HTML"
echo "saved html snapshot to $TMP_HTML"

echo
echo "== extract referenced js assets from html =="
grep -Eo 'src="[^"]+\.js[^"]*"' "$TMP_HTML" \
  | sed -E 's/^src="([^"]+)".*/\1/' \
  | sed 's#^/#'"$BASE_URL"'/#' \
  | sort -u \
  | tee "$TMP_ASSETS" || true

echo
echo "== route references found in html =="
grep -Eo '/api/[A-Za-z0-9._/-]+|/events/[A-Za-z0-9._/-]+|/diagnostics/[A-Za-z0-9._/-]+' "$TMP_HTML" \
  | sort -u \
  | tee "$TMP_ROUTE_HITS" || true

while IFS= read -r asset; do
  [[ -n "$asset" ]] || continue
  echo
  echo "== scanning asset: $asset =="
  curl -fsS "$asset" \
    | grep -Eo '/api/[A-Za-z0-9._/-]+|/events/[A-Za-z0-9._/-]+|/diagnostics/[A-Za-z0-9._/-]+' \
    | sort -u \
    | tee -a "$TMP_ROUTE_HITS" || true
done < "$TMP_ASSETS"

echo
echo "== unique route references from served UI assets =="
sort -u "$TMP_ROUTE_HITS" || true

echo
echo "== safe GET probes for likely read-only routes =="
for path in \
  /api/health \
  /api/tasks \
  /api/runs \
  /api/guidance \
  /diagnostics/system-health \
  /events/tasks \
  /events/ops \
  /events/reflections
do
  echo
  echo "-- GET $BASE_URL$path --"
  curl -i -s --max-time 5 "$BASE_URL$path" | sed -n '1,40p' || true
done

echo
echo "== repo references for likely interactive endpoints =="
rg -n '/api/chat|/api/delegate-task|/api/tasks-mutations|/api/guidance|/diagnostics/system-health|/events/tasks|/events/ops|/events/reflections' \
  . \
  -g '!node_modules' \
  -g '!.next' \
  -g '!.git' \
  -g '!dist' \
  -g '!.runtime' || true

echo
echo "────────────────────────────────"
echo "PHASE 487 — UI ROUTE CONTRACT AUDIT COMPLETE"
echo "────────────────────────────────"
echo "Use this to identify:"
echo "1. Which routes the current UI actually expects"
echo "2. Which read-only routes respond"
echo "3. Which missing routes are true UI contract gaps"
