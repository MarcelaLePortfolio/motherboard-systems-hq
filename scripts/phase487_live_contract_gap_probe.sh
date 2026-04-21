#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — LIVE CONTRACT GAP PROBE"
echo "────────────────────────────────"

BASE_URL="${BASE_URL:-http://localhost:8080}"
OUT="docs/phase487_live_contract_gap_probe.md"

mkdir -p docs

{
  echo "# Phase 487 Live Contract Gap Probe"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Safe live probes"
  echo

  for path in \
    /api/health \
    /api/tasks \
    /api/runs \
    /api/guidance \
    /diagnostics/system-health \
    /events/ops \
    /events/reflections \
    /events/tasks \
    /events/task-events \
    /api/chat \
    /api/delegate-task
  do
    code="$(curl -o /dev/null -s -w '%{http_code}' --max-time 5 "$BASE_URL$path" || true)"
    echo "- GET $path -> $code"
  done

  echo
  echo "## Repo route ownership scan"
  echo
  echo '```'
  rg -n \
    'app\.(get|post|use)\("/api/chat"|app\.(get|post|use)\("/api/delegate-task"|app\.(get|post|use)\("/events/ops"|app\.(get|post|use)\("/events/reflections"|app\.(get|post|use)\("/events/tasks"|app\.(get|post|use)\("/events/task-events"|app\.(get|post|use)\("/api/guidance"|app\.(get|post|use)\("/diagnostics/system-health"' \
    server.mjs server public scripts/_local app \
    -g '!node_modules' \
    -g '!.next' \
    -g '!dist' \
    -g '!.runtime' || true
  echo '```'

  echo
  echo "## Current interpretation"
  echo
  echo "- Read-only health/guidance/tasks/runs surfaces are live if they return 200."
  echo "- Matilda chat and delegation are UI contract candidates only if source routes exist in repo."
  echo "- SSE routes are considered live only if backend route ownership exists and GET does not 404."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
