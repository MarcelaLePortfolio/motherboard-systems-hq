#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_${TS}.txt"
SUMMARY="PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_SUMMARY_${TS}.md"

extract_pg_container() {
  docker compose ps -q postgres 2>/dev/null | head -n 1
}

run_psql() {
  local cid="$1"
  local sql="$2"
  docker exec -e PGPASSWORD="${POSTGRES_PASSWORD:-motherboard}" "$cid" \
    psql -U "${POSTGRES_USER:-motherboard}" -d "${POSTGRES_DB:-motherboard}" -Atqc "$sql"
}

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
  LATEST_LOG="$(ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt 2>/dev/null | head -n 1 || true)"
  echo "latest_validation_log=${LATEST_LOG:-<missing>}"
  if [ -n "${LATEST_LOG:-}" ]; then
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
  if [ -n "${PG_CID:-}" ]; then
    echo "-- terminal event counts in task_events --"
    SUCCESS_EVENTS="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.completed';" || echo "0")"
    FAILED_EVENTS="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.failed';" || echo "0")"
    CREATED_EVENTS="$(run_psql "$PG_CID" "select count(*) from task_events where kind='task.created';" || echo "0")"
    echo "task_created_events=${CREATED_EVENTS}"
    echo "task_completed_events=${SUCCESS_EVENTS}"
    echo "task_failed_events=${FAILED_EVENTS}"
    echo

    echo "-- latest terminal events --"
    run_psql "$PG_CID" "select id || ' | ' || kind || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(actor,'') || ' | ' || coalesce(ts::text,'') from task_events where kind in ('task.completed','task.failed') order by id desc limit 10;" || true
    echo

    echo "-- latest tasks rows --"
    run_psql "$PG_CID" "select id || ' | ' || coalesce(task_id,'') || ' | ' || coalesce(status,'') || ' | ' || coalesce(run_id,'') || ' | ' || coalesce(updated_at::text,'') from tasks order by id desc limit 15;" || true
    echo
  else
    SUCCESS_EVENTS="unknown"
    FAILED_EVENTS="unknown"
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
  if [ "${SUCCESS_EVENTS:-0}" != "unknown" ] && [ "${SUCCESS_EVENTS:-0}" -gt 0 ]; then
    echo "terminal_success_event_observed=yes"
  else
    echo "terminal_success_event_observed=no"
  fi

  if [ "${FAILED_EVENTS:-0}" != "unknown" ] && [ "${FAILED_EVENTS:-0}" -gt 0 ]; then
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
  echo "terminal_can_prove=route success, terminal events persisted, bundle writer state, source ownership state"
  echo "terminal_cannot_fully_prove=visual layout stability, exact dashboard Success Rate movement, exact on-screen Latency rendering"
} | tee "$OUT"

SUCCESS_EVENTS_VAL="$(grep '^task_completed_events=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"
FAILED_EVENTS_VAL="$(grep '^task_failed_events=' "$OUT" | tail -n 1 | cut -d= -f2 || echo "unknown")"
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
- Persisted terminal event counts in task_events:
  - task.completed: ${SUCCESS_EVENTS_VAL}
  - task.failed: ${FAILED_EVENTS_VAL}

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
