#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-/tmp/phase65_metrics_runtime_verify.out}"
DEFAULT_BASE_URL="${BASE_URL:-http://localhost:3000}"

resolve_dashboard_container_id() {
  docker compose ps -q dashboard 2>/dev/null || true
}

resolve_base_url() {
  local mapped
  mapped="$(docker compose port dashboard 3000 2>/dev/null | tail -n 1 || true)"
  if [[ -n "${mapped}" ]]; then
    echo "http://${mapped}"
    return 0
  fi
  echo "${DEFAULT_BASE_URL}"
}

wait_for_url() {
  local url="$1"
  local attempts="${2:-90}"
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

wait_for_container_http() {
  local cid="$1"
  local attempts="${2:-90}"
  local sleep_s="${3:-2}"
  local i
  for i in $(seq 1 "$attempts"); do
    if docker exec "$cid" sh -lc 'curl -fsS http://127.0.0.1:3000 >/dev/null 2>&1'; then
      echo "container_http_up=1"
      return 0
    fi
    sleep "$sleep_s"
  done
  echo "container_http_up=0"
  return 1
}

sample_task_events_host() {
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

sample_task_events_container() {
  local cid="$1"
  local seconds="${2:-12}"

  docker exec "$cid" sh -lc "
    if command -v timeout >/dev/null 2>&1; then
      timeout ${seconds}s curl -NfsS http://127.0.0.1:3000/events/task-events || true
    else
      curl -NfsS http://127.0.0.1:3000/events/task-events &
      pid=\$!
      sleep ${seconds} || true
      kill \$pid >/dev/null 2>&1 || true
      wait \$pid 2>/dev/null || true
    fi
  " || true
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
  echo "-- compose status --"
  docker compose ps dashboard || true

  CID="$(resolve_dashboard_container_id)"
  BASE_URL_RESOLVED="$(resolve_base_url)"

  echo
  echo "-- resolved runtime targets --"
  echo "container_id=${CID:-<none>}"
  echo "base_url=${BASE_URL_RESOLVED}"

  echo
  echo "-- wait for host dashboard url --"
  wait_for_url "$BASE_URL_RESOLVED" 90 2 || true

  echo
  echo "-- wait for in-container dashboard http --"
  if [[ -n "${CID}" ]]; then
    wait_for_container_http "$CID" 90 2 || true
  else
    echo "container_http_up=0"
  fi

  echo
  echo "-- dashboard metric hooks (host if reachable) --"
  curl -fsS "$BASE_URL_RESOLVED" | grep -nE 'metric-tasks|metric-success|metric-latency' || true

  echo
  echo "-- dashboard metric hooks (container fallback) --"
  if [[ -n "${CID}" ]]; then
    docker exec "$CID" sh -lc "curl -fsS http://127.0.0.1:3000 | grep -nE 'metric-tasks|metric-success|metric-latency'" || true
  fi

  echo
  echo "-- task-events SSE probe (host if reachable) --"
  sample_task_events_host "$BASE_URL_RESOLVED/events/task-events" 12

  echo
  echo "-- task-events SSE probe (container fallback) --"
  if [[ -n "${CID}" ]]; then
    sample_task_events_container "$CID" 12
  fi

  echo
  echo "-- current recent tasks snapshot (host if reachable) --"
  curl -fsS "$BASE_URL_RESOLVED/api/tasks?limit=12" || true

  echo
  echo "-- current recent tasks snapshot (container fallback) --"
  if [[ -n "${CID}" ]]; then
    docker exec "$CID" sh -lc "curl -fsS http://127.0.0.1:3000/api/tasks?limit=12" || true
  fi

  echo
  echo "-- current runs snapshot (host if reachable) --"
  curl -fsS "$BASE_URL_RESOLVED/api/runs?limit=20" || true

  echo
  echo "-- current runs snapshot (container fallback) --"
  if [[ -n "${CID}" ]]; then
    docker exec "$CID" sh -lc "curl -fsS http://127.0.0.1:3000/api/runs?limit=20" || true
  fi

  echo
  echo "-- recent container logs --"
  if [[ -n "${CID}" ]]; then
    docker logs --tail 120 "$CID" || true
  fi

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
