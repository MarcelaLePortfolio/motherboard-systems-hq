#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-motherboard_systems_hq}"

COMPOSE_FILES=(
  -f docker-compose.yml
  -f docker-compose.workers.yml
  -f docker-compose.phase47.postgres_url.override.yml
  -f docker-compose.phase54.postgres_bootstrap.override.yml
)

PSQL_AT=(docker compose "${COMPOSE_FILES[@]}" exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At)
PSQL_RAW=(docker compose "${COMPOSE_FILES[@]}" exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1)

STACK_WAS_UP=0

is_service_running() {
  local svc="$1"
  docker compose "${COMPOSE_FILES[@]}" ps "$svc" --format json | rg -q '"State":"running"'
}

bring_up_stack_if_needed() {
  if is_service_running postgres && is_service_running dashboard; then
    STACK_WAS_UP=1
    return 0
  fi
  STACK_WAS_UP=0
  docker compose "${COMPOSE_FILES[@]}" up -d --build
}

wait_http_200() {
  local url="$1"
  local code=""
  for _ in {1..60}; do
    code="$(curl -sS -o /dev/null -w "%{http_code}" "$url" || true)"
    if [[ "$code" == "200" ]]; then return 0; fi
    sleep 1
  done
  return 1
}

cleanup() {
  # Keep stack up if KEEP_STACK=1
  if [[ "${KEEP_STACK:-0}" == "1" ]]; then
    return 0
  fi
  if [[ "$STACK_WAS_UP" == "0" ]]; then
    docker compose "${COMPOSE_FILES[@]}" down --remove-orphans >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

echo "=== Phase 57 snapshot smoke ==="

bring_up_stack_if_needed

if ! wait_http_200 "$BASE_URL/api/runs"; then
  echo "❌ dashboard did not reach HTTP 200 on $BASE_URL/api/runs"
  docker compose "${COMPOSE_FILES[@]}" ps || true
  docker compose "${COMPOSE_FILES[@]}" logs --tail=200 || true
  exit 1
fi

echo "Applying Phase 57 SQL (idempotent)..."
if [[ ! -f drizzle_pg/0008_phase57_run_snapshot.sql ]]; then
  echo "❌ missing host file: drizzle_pg/0008_phase57_run_snapshot.sql"
  exit 1
fi
"${PSQL_RAW[@]}" < drizzle_pg/0008_phase57_run_snapshot.sql >/dev/null

# NOTE: probe currently emits under fixed ids (policy.probe.*), so smoke asserts those advance.
RUN_ID="policy.probe.run"
TASK_ID="policy.probe.task"

BEFORE_MAX="$("${PSQL_AT[@]}" -c "SELECT COALESCE(max(last_event_id),0) FROM run_snapshots WHERE run_id='${RUN_ID}';" | tr -d '[:space:]')"
echo "before_max_last_event_id=${BEFORE_MAX:-0}"

echo "Creating synthetic run via probe (expect 2xx)..."
PROBE_CODE="$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/policy/probe" \
  -H "content-type: application/json" \
  -d "{\"kind\":\"phase57.test\",\"task_id\":\"${TASK_ID}\",\"run_id\":\"${RUN_ID}\"}" || true)"

echo "probe_http_code=$PROBE_CODE"
if [[ "$PROBE_CODE" != 2* ]]; then
  echo "❌ probe did not return 2xx"
  docker compose "${COMPOSE_FILES[@]}" logs --tail=200 dashboard workerA workerB postgres || true
  exit 1
fi

sleep 1

echo "Refreshing snapshot projection for run_id=${RUN_ID}..."
INSERTED="$("${PSQL_AT[@]}" -c "SELECT run_snapshots_refresh('${RUN_ID}');" | tr -d '[:space:]' || true)"
echo "run_snapshots_refresh_inserted=${INSERTED:-0}"

AFTER_MAX="$("${PSQL_AT[@]}" -c "SELECT COALESCE(max(last_event_id),0) FROM run_snapshots WHERE run_id='${RUN_ID}';" | tr -d '[:space:]')"
echo "after_max_last_event_id=${AFTER_MAX:-0}"

if [[ "${AFTER_MAX:-0}" -le "${BEFORE_MAX:-0}" ]]; then
  echo "❌ Snapshot projection did not advance (max last_event_id did not increase)"
  echo "=== run_view (policy.probe.run) ==="
  "${PSQL_AT[@]}" -c "SELECT run_id, task_id, last_event_id, last_event_kind, last_event_ts, task_status, actor FROM run_view WHERE run_id='${RUN_ID}' LIMIT 10;" || true
  echo "=== task_events (policy.probe.run) ==="
  "${PSQL_AT[@]}" -c "SELECT id, kind, task_id, run_id, ts, actor FROM task_events WHERE run_id='${RUN_ID}' ORDER BY id DESC LIMIT 50;" || true
  exit 1
fi

echo "✅ Snapshot projection advanced: ${BEFORE_MAX:-0} -> ${AFTER_MAX:-0}"
