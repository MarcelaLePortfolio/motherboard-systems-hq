#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-/tmp/phase65_metrics_runtime_verify.out}"

{
  echo "== Phase 65 runtime verification =="
  echo
  echo "-- branch / head --"
  git branch --show-current
  git rev-parse --short HEAD

  echo
  echo "-- protection guards --"
  bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
  bash scripts/_local/phase64_8_pre_push_contract_guard.sh

  echo
  echo "-- rebuild dashboard --"
  docker compose build dashboard
  docker compose up -d dashboard

  echo
  echo "-- wait for dashboard --"
  for i in $(seq 1 30); do
    if curl -fsS http://localhost:3000 >/dev/null 2>&1; then
      echo "dashboard_up=1"
      break
    fi
    sleep 2
  done

  echo
  echo "-- dashboard metric hooks --"
  curl -fsS http://localhost:3000 | grep -nE 'metric-tasks|metric-success|metric-latency' || true

  echo
  echo "-- task-events SSE probe (idle health) --"
  timeout 12s curl -NfsS http://localhost:3000/events/task-events || true

  echo
  echo "-- current recent tasks snapshot --"
  curl -fsS 'http://localhost:3000/api/tasks?limit=12' || true

  echo
  echo "-- current runs snapshot --"
  curl -fsS 'http://localhost:3000/api/runs?limit=20' || true

  echo
  echo "Manual browser verification checklist:"
  echo "1. Open dashboard."
  echo "2. Confirm Tasks Running shows 0 when idle."
  echo "3. Confirm Success Rate and Latency render without breaking interactivity."
  echo "4. Trigger one task."
  echo "5. Confirm Tasks Running increments during active lifecycle."
  echo "6. Confirm terminal event decrements Tasks Running."
  echo "7. Confirm Success Rate changes only after terminal event."
  echo "8. Confirm Latency changes only after start-to-terminal duration exists."
} | tee "$OUT"

echo
echo "Verification log written to: $OUT"
