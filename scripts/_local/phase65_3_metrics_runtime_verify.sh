#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-/tmp/phase65_metrics_runtime_verify.out}"
BASE_URL="${BASE_URL:-http://localhost:3000}"

wait_for_dashboard() {
  local url="$1"
  local attempts="${2:-60}"
  local sleep_s="${3:-2}"
  local i
  for i in $(seq 1 "$attempts"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "dashboard_up=1"
      return 0
    fi
    sleep "$sleep_s"
  done
  echo "dashboard_up=0"
  return 1
}

sample_task_events() {
  local url="$1"
  local seconds="${2:-12}"

  if command -v timeout >/dev/null 2>&1; then
    timeout "${seconds}s" curl -NfsS "$url" || true
    return 0
  fi

  curl -NfsS "$url" &
  local pid=$!
  sleep "$seconds" || true
  kill "$pid" >/dev/null 2>&1 || true
  wait "$pid" 2>/dev/null || true
}

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
  wait_for_dashboard "$BASE_URL" 60 2 || true

  echo
  echo "-- dashboard metric hooks --"
  curl -fsS "$BASE_URL" | grep -nE 'metric-tasks|metric-success|metric-latency' || true

  echo
  echo "-- task-events SSE probe (idle health) --"
  sample_task_events "$BASE_URL/events/task-events" 12

  echo
  echo "-- current recent tasks snapshot --"
  curl -fsS "$BASE_URL/api/tasks?limit=12" || true

  echo
  echo "-- current runs snapshot --"
  curl -fsS "$BASE_URL/api/runs?limit=20" || true

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
