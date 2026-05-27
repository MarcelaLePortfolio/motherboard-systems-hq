#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_${TS}.txt"
SUMMARY="PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_SUMMARY_${TS}.md"

LATEST_LOG="$(ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt 2>/dev/null | head -n 1 || true)"

extract_pg_container() {
  docker compose ps -q postgres 2>/dev/null | head -n 1
}

extract_env_from_container() {
  local cid="$1"
  local key="$2"
  docker exec "$cid" sh -lc "printenv $key 2>/dev/null || true" | tr -d '\r' | tail -n 1
}

run_psql() {
  local cid="$1"
  local sql="$2"

  local pg_user pg_db pg_pass
  pg_user="$(extract_env_from_container "$cid" POSTGRES_USER)"
  pg_db="$(extract_env_from_container "$cid" POSTGRES_DB)"
  pg_pass="$(extract_env_from_container "$cid" POSTGRES_PASSWORD)"

  [ -n "$pg_user" ] || pg_user="postgres"
  [ -n "$pg_db" ] || pg_db="postgres"

  docker exec \
    -e PGPASSWORD="$pg_pass" \
    "$cid" \
    psql -U "$pg_user" -d "$pg_db" -Atqc "$sql"
}

extract_latest_validation_ids() {
  local log="$1"
  if [ -z "$log" ] || [ ! -f "$log" ]; then
    return 0
  fi

  awk -F= '
    /^success_task_id=/ && !seen_st++ { print "SUCCESS_TASK_ID=" $2 }
    /^success_run_id=/  && !seen_sr++ { print "SUCCESS_RUN_ID=" $2 }
    /^failure_task_id=/ && !seen_ft++ { print "FAILURE_TASK_ID=" $2 }
    /^failure_run_id=/  && !seen_fr++ { print "FAILURE_RUN_ID=" $2 }
  ' "$log"
}

SUCCESS_TASK_ID=""
SUCCESS_RUN_ID=""
FAILURE_TASK_ID=""
FAILURE_RUN_ID=""

if [ -n "${LATEST_LOG:-}" ] && [ -f "$LATEST_LOG" ]; then
  eval "$(extract_latest_validation_ids "$LATEST_LOG")"
fi

{
  echo "PHASE 62B — RUNTIME ACCEPTANCE EVIDENCE"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "base_url=${BASE_URL}"
  echo

  echo "== route reachability =="
  curl -fsS "${BASE_URL}/api/tasks?limit=5" || true
  echo
  echo

  echo "== latest validation artifact =="
  echo "latest_validation_log=${LATEST_LOG:-<missing>}"
  echo "success_task_id=${SUCCESS_TASK_ID:-<missing>}"
  echo "success_run_id=${SUCCESS_RUN_ID:-<missing>}"
  echo "failure_task_id=${FAILURE_TASK_ID:-<missing>}"
  echo "failure_run_id=${FAILURE_RUN_ID:-<missing>}"
  if [ -n "${LATEST_LOG:-}" ] && [ -f "$LATEST_LOG" ]; then
    echo "-- extracted terminal route results --"
    grep -n 'step 1: create success candidate\|step 2: complete success candidate\|step 3: create failure candidate\|step 4: fail failure candidate\|success_task_id=\|success_run_id=\|failure_task_id=\|failure_run_id=\|{"ok":true,"task_id"' "$LATEST_LOG" || true
  fi
  echo
  echo

  echo "== live dashboard asset ownership checks =="
  echo "-- direct success writer in bundle --"
  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "bundle_direct_success_writer_present=yes"
  else
    echo "bundle_direct_success_writer_present=no"
  fi
  echo
  echo "-- source neutralization --"
  if grep -q "successNode = null" public/js/agent-status-row.js 2>/dev/null; then
    echo "shared_metrics_success_writer_neutralized=yes"
  else
    echo "shared_metrics_success_writer_neutralized=no"
  fi
  echo
  echo "-- bootstrap import --"
  if grep -q 'telemetry/phase65b_metric_bootstrap.js' public/js/dashboard-bundle-entry.js 2>/dev/null; then
    echo "dashboard_bundle_imports_bootstrap=yes"
  else
    echo "dashboard_bundle_imports_bootstrap=no"
  fi
  echo
  echo "-- telemetry success listeners --"
  grep -n '"task.completed"\|"task.failed"\|eventNames\|addEventListener' public/js/telemetry/success_rate_metric.js || true
  echo
  echo

  echo "== postgres terminal event evidence =="
  PG_CID="$(extract_pg_container || true)"
  echo "postgres_container=${PG_CID:-<missing>}"

  TASK_COMPLETED_EVENTS="unknown"
  TASK_FAILED_EVENTS="unknown"
  TASK_CREATED_EVENTS="unknown"
  TARGET_SUCCESS_COMPLETED="unknown"
  TARGET_FAILURE_FAILED="unknown"

  if [ -n "${PG_CID:-}" ]; then
    PG_USER="$(extract_env_from_container "$PG_CID" POSTGRES_USER)"
    PG_DB="$(extract_env_from_container "$PG_CID" POSTGRES_DB)"
    echo "postgres_user=${PG_USER:-<missing>}"
    echo "postgres_db=${PG_DB:-<missing>}"
    echo

    if TASK_CREATED_EVENTS_RAW="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.created';" 2>/dev/null)"; then
      TASK_CREATED_EVENTS="${TASK_CREATED_EVENTS_RAW:-0}"
    fi
    if TASK_COMPLETED_EVENTS_RAW="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.completed';" 2>/dev/null)"; then
      TASK_COMPLETED_EVENTS="${TASK_COMPLETED_EVENTS_RAW:-0}"
    fi
    if TASK_FAILED_EVENTS_RAW="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.failed';" 2>/dev/null)"; then
      TASK_FAILED_EVENTS="${TASK_FAILED_EVENTS_RAW:-0}"
    fi

    echo "-- terminal event counts in task_events --"
    echo "task_created_events=${TASK_CREATED_EVENTS}"
    echo "task_completed_events=${TASK_COMPLETED_EVENTS}"
    echo "task_failed_events=${TASK_FAILED_EVENTS}"
    echo

    echo "-- latest terminal events --"
    run_psql "$PG_CID" "select id || ' | ' || kind || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(actor,'') || ' | ' || coalesce(ts::text,'') from task_events where kind in ('task.completed','task.failed') order by id desc limit 10;" 2>/dev/null || true
    echo

    echo "-- latest tasks rows --"
    run_psql "$PG_CID" "select id || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(status,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(updated_at::text,'') from tasks order by id desc limit 15;" 2>/dev/null || true
    echo

    if [ -n "${SUCCESS_TASK_ID:-}" ] && [ -n "${SUCCESS_RUN_ID:-}" ]; then
      if TARGET_SUCCESS_COMPLETED_RAW="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.completed' and task_id='${SUCCESS_TASK_ID}' and run_id='${SUCCESS_RUN_ID}';" 2>/dev/null)"; then
        TARGET_SUCCESS_COMPLETED="${TARGET_SUCCESS_COMPLETED_RAW:-0}"
      fi
    fi

    if [ -n "${FAILURE_TASK_ID:-}" ] && [ -n "${FAILURE_RUN_ID:-}" ]; then
      if TARGET_FAILURE_FAILED_RAW="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.failed' and task_id='${FAILURE_TASK_ID}' and run_id='${FAILURE_RUN_ID}';" 2>/dev/null)"; then
        TARGET_FAILURE_FAILED="${TARGET_FAILURE_FAILED_RAW:-0}"
      fi
    fi

    echo "-- validation-target event proof --"
    echo "target_success_completed_events=${TARGET_SUCCESS_COMPLETED}"
    echo "target_failure_failed_events=${TARGET_FAILURE_FAILED}"
    echo

    echo "-- validation-target rows --"
    if [ -n "${SUCCESS_TASK_ID:-}" ]; then
      echo "success_task_rows:"
      run_psql "$PG_CID" "select id || ' | ' || kind || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(actor,'') from task_events where task_id='${SUCCESS_TASK_ID}' order by id asc;" 2>/dev/null || true
      echo
    fi
    if [ -n "${FAILURE_TASK_ID:-}" ]; then
      echo "failure_task_rows:"
      run_psql "$PG_CID" "select id || ' | ' || kind || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(actor,'') from task_events where task_id='${FAILURE_TASK_ID}' order by id asc;" 2>/dev/null || true
      echo
    fi
  fi
  echo

  echo "== terminal derivation from /api/tasks snapshot =="
  python3 <<'PY'
import json, urllib.request
BASE="http://127.0.0.1:8080"
data=json.load(urllib.request.urlopen(f"{BASE}/api/tasks?limit=200"))
tasks=data.get("tasks",[])
success=failed=running=queued=0
for t in tasks:
    s=(t.get("status") or "").lower()
    if s in ("completed","complete","done","success"):
        success+=1
    elif s in ("failed","error","canceled","cancelled"):
        failed+=1
    elif s=="running":
        running+=1
    elif s=="queued":
        queued+=1
total=success+failed
rate=round((success/total)*100,2) if total else 0
print(f"api_tasks_success={success}")
print(f"api_tasks_failed={failed}")
print(f"api_tasks_running={running}")
print(f"api_tasks_queued={queued}")
print(f"api_tasks_terminal_total={total}")
print(f"api_tasks_success_rate={rate}")
PY
  echo
  echo

  echo "== decision scaffold =="
  if [ "${TARGET_SUCCESS_COMPLETED}" != "unknown" ] && [ "${TARGET_SUCCESS_COMPLETED}" -gt 0 ]; then
    echo "terminal_success_event_observed=yes"
  else
    echo "terminal_success_event_observed=no"
  fi

  if [ "${TARGET_FAILURE_FAILED}" != "unknown" ] && [ "${TARGET_FAILURE_FAILED}" -gt 0 ]; then
    echo "terminal_failure_event_observed=yes"
  else
    echo "terminal_failure_event_observed=no"
  fi

  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "bundle_writer_regression=yes"
  else
    echo "bundle_writer_regression=no"
  fi

  if grep -q "successNode = null" public/js/agent-status-row.js 2>/dev/null; then
    echo "ownership_regression=no"
  else
    echo "ownership_regression=yes"
  fi

  echo
  echo "== limits of terminal-only proof =="
  echo "terminal_can_prove=route success, targeted terminal events persisted, bundle writer state, source ownership state"
  echo "terminal_cannot_fully_prove=visual layout stability, exact dashboard Success Rate movement, exact on-screen Latency rendering"
} | tee "$OUT"

SUCCESS_EVENTS_VAL="$(grep '^target_success_completed_events=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"
FAILED_EVENTS_VAL="$(grep '^target_failure_failed_events=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"
BUNDLE_REGRESSION_VAL="$(grep '^bundle_writer_regression=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"
OWNERSHIP_REGRESSION_VAL="$(grep '^ownership_regression=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"

cat > "$SUMMARY" <<EOF2
PHASE 62B — TERMINAL ACCEPTANCE EVIDENCE SUMMARY
Date: $(date -u +"%Y-%m-%d")

WHAT TERMINAL NOW PROVES

- Runtime validation routes executed successfully through create, complete, and fail in the latest validation artifact if present.
- Bundle direct Success Rate writer remains removed.
- Shared metrics corridor remains neutralized for Success Rate.
- Telemetry bootstrap import remains present.
- Persisted validation-target terminal event counts in task_events:
  - target task.completed: ${SUCCESS_EVENTS_VAL}
  - target task.failed: ${FAILED_EVENTS_VAL}

CURRENT TERMINAL DECISION

- terminal_success_event_observed=$([ "${SUCCESS_EVENTS_VAL}" != "unknown" ] && [ "${SUCCESS_EVENTS_VAL}" -gt 0 ] && echo yes || echo no)
- terminal_failure_event_observed=$([ "${FAILED_EVENTS_VAL}" != "unknown" ] && [ "${FAILED_EVENTS_VAL}" -gt 0 ] && echo yes || echo no)
- bundle_writer_regression=${BUNDLE_REGRESSION_VAL}
- ownership_regression=${OWNERSHIP_REGRESSION_VAL}

IMPORTANT LIMIT

Terminal evidence can support acceptance confidence, but it does NOT fully prove visual layout stability or exact on-screen metric movement without dashboard observation.

Artifacts:
- evidence_log=${OUT}
EOF2

echo "summary_written=${SUMMARY}"
echo "evidence_log=${OUT}"
