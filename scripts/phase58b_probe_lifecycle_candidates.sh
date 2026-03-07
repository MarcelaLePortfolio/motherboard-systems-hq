#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== dashboard + probe lifecycle candidates =="

echo
echo "-- files mentioning policy.probe.run --"
rg -n --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!coverage' \
  'policy\.probe\.run' . || true

echo
echo "-- files mentioning event stream labels --"
rg -n --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!coverage' \
  'Event Stream|event stream|task event|task-events|task_events|heartbeat' \
  app components src lib || true

echo
echo "-- files hitting runs/health/task-events APIs --"
rg -n --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!coverage' \
  '/api/runs|/api/health|/api/task-events|/api/tasks' \
  app components src lib || true

echo
echo "-- likely dashboard entrypoints --"
find app components src -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) 2>/dev/null \
  | rg '/(dashboard|ops|console|operator|runs?)/|page\.(tsx|ts|jsx|js)$' || true
