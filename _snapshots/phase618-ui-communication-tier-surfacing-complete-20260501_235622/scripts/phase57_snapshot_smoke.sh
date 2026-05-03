#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-motherboard_systems_hq}"

COMPOSE_FILES=(
  -f docker-compose.yml
  -f docker-compose.workers.yml
  -f docker-compose.phase47.postgres_url.override.yml
  -f docker-compose.phase54.postgres_bootstrap.override.yml
  -f docker-compose.phase57.shadow.env.override.yml
  -f docker-compose.phase57.shadow.env.override.yml
)

ensure_external_network() {
  # Some compose overlays declare the default network as external.
  # If the network does not exist, docker compose will fail hard.
  # If it exists but is missing compose labels, compose may still refuse it.
  local net="${COMPOSE_PROJECT_NAME}_default"

  if docker network inspect "$net" >/dev/null 2>&1; then
    local lbl=""
    lbl="$(docker network inspect "$net" --format '{{ index .Labels "com.docker.compose.network" }}' 2>/dev/null || true)"
    if [[ "${lbl:-}" != "default" ]]; then
      docker network rm "$net" >/dev/null 2>&1 || true
    fi
  fi

  if ! docker network inspect "$net" >/dev/null 2>&1; then
    docker network create --label com.docker.compose.network=default "$net" >/dev/null
  fi
}

PSQL_AT=(docker compose "${COMPOSE_FILES[@]}" exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -At)
PSQL_RAW=(docker compose "${COMPOSE_FILES[@]}" exec -T postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1)

STACK_WAS_UP=0

is_service_running() {
  local svc="$1"
  docker compose "${COMPOSE_FILES[@]}" ps "$svc" --format json | grep -q '"State":"running"'
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

ensure_external_network
bring_up_stack_if_needed

if ! wait_http_200 "$BASE_URL/api/runs"; then
  echo "❌ dashboard did not reach HTTP 200 on $BASE_URL/api/runs"
  docker compose "${COMPOSE_FILES[@]}" ps || true
  docker compose "${COMPOSE_FILES[@]}" logs --tail=200 || true
  exit 1
fi

echo "Applying Phase 57 SQL (idempotent)..."

echo "Ensuring run_view exists (Phase 36.1) ..."
"${PSQL_RAW[@]}" < drizzle_pg/0007_phase36_1_run_view.sql >/dev/null
if [[ ! -f drizzle_pg/0008_phase57_run_snapshot.sql ]]; then
  echo "❌ missing host file: drizzle_pg/0008_phase57_run_snapshot.sql"
  exit 1
fi
"${PSQL_RAW[@]}" < drizzle_pg/0008_phase57_run_snapshot.sql >/dev/null

# NOTE: probe currently emits under fixed ids (policy.probe.*), so smoke asserts those advance.
RUN_ID="policy.probe.run"
TASK_ID="policy.probe.task"

# last_event_id may be UUID/text depending on lane; use last_event_ts (epoch ms) for monotonic advancement.
BEFORE_TS="$("${PSQL_AT[@]}" -c "SELECT COALESCE(max(last_event_ts::bigint),0) FROM run_snapshots WHERE run_id='${RUN_ID}';" | tr -d '[:space:]')"
echo "before_max_last_event_ts=${BEFORE_TS:-0}"

echo "Waiting for dashboard to be ready (from inside container)..."
for i in $(seq 1 120); do
  code="$(docker compose exec -T dashboard sh -lc 'curl -sS -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/api/health || true')"
  if [ "$code" = "200" ]; then
    echo "dashboard: ready."
    break
  fi
  sleep 0.25
done

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

AFTER_TS="$("${PSQL_AT[@]}" -c "SELECT COALESCE(max(last_event_ts::bigint),0) FROM run_snapshots WHERE run_id='${RUN_ID}';" | tr -d '[:space:]')"
echo "after_max_last_event_ts=${AFTER_TS:-0}"

if [[ "${AFTER_TS:-0}" -le "${BEFORE_TS:-0}" ]]; then
  echo "❌ Snapshot projection did not advance (max last_event_ts did not increase)"
  echo "=== run_view (policy.probe.run) ==="
  "${PSQL_AT[@]}" -c "SELECT run_id, task_id, last_event_id, last_event_kind, last_event_ts, task_status, actor FROM run_view WHERE run_id='${RUN_ID}' LIMIT 10;" || true
  echo "=== task_events (policy.probe.run) ==="
  "${PSQL_AT[@]}" -c "SELECT id, kind, task_id, run_id, ts, actor FROM task_events WHERE run_id='${RUN_ID}' ORDER BY id DESC LIMIT 50;" || true
  exit 1
fi

echo "✅ Snapshot projection advanced: ${BEFORE_TS:-0} -> ${AFTER_TS:-0}"
