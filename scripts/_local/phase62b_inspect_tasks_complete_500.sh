#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_TASKS_COMPLETE_500_INSPECTION_${TS}.txt"
SUMMARY="PHASE62B_TASKS_COMPLETE_500_SUMMARY_${TS}.md"

SUCCESS_TASK_ID="${1:-}"

{
  echo "PHASE 62B — /api/tasks/complete 500 inspection"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "base_url=${BASE_URL}"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== route source candidates =="
  rg -n '/api/tasks/complete|task\.completed|router\.post\("/api/tasks/complete"|app\.post\("/api/tasks/complete"' \
    server public scripts 2>/dev/null || true
  echo

  echo "== route implementation =="
  sed -n '130,210p' server/routes/api-tasks-postgres.mjs || true
  echo

  echo "== enforcement / guard clues =="
  rg -n 'assertNotEnforced|phase44|allowlist|enforce|forbid|403|500' \
    server/routes/api-tasks-postgres.mjs server server/enforcement 2>/dev/null || true
  echo

  echo "== runtime reproduce =="
  if [ -n "${SUCCESS_TASK_ID}" ]; then
    echo "using_existing_task_id=${SUCCESS_TASK_ID}"
  else
    echo "-- create candidate task --"
    CREATE_JSON="$(mktemp)"
    curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
      -H 'Content-Type: application/json' \
      -d '{
        "kind":"phase62b.inspect.complete",
        "type":"phase62b.inspect.complete",
        "title":"phase62b complete 500 inspection task",
        "meta":{"actor":"phase62b-inspect","note":"complete 500 inspection"}
      }' | tee "${CREATE_JSON}"
    echo
    SUCCESS_TASK_ID="$(
      python3 - <<'PY' "${CREATE_JSON}"
import json, sys
p=json.load(open(sys.argv[1]))
for v in [p.get("task_id"), p.get("id"), (p.get("data") or {}).get("task_id"), (p.get("data") or {}).get("id")]:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract task id")
PY
    )"
    echo "created_task_id=${SUCCESS_TASK_ID}"
    rm -f "${CREATE_JSON}"
  fi
  echo

  echo "-- POST /api/tasks/complete verbose --"
  COMPLETE_BODY="$(mktemp)"
  cat > "${COMPLETE_BODY}" <<JSON
{
  "task_id":"${SUCCESS_TASK_ID}",
  "status":"completed",
  "meta":{"actor":"phase62b-inspect","note":"complete 500 inspection"}
}
JSON
  curl -sS -i -X POST "${BASE_URL}/api/tasks/complete" \
    -H 'Content-Type: application/json' \
    --data-binary @"${COMPLETE_BODY}" || true
  echo
  rm -f "${COMPLETE_BODY}"

  echo "== recent task probe =="
  curl -fsS "${BASE_URL}/api/tasks?limit=10" || true
  echo
} | tee "${OUT}"

{
  echo "PHASE 62B — /api/tasks/complete 500 concise summary"
  echo "Date: $(date -u +"%Y-%m-%d")"
  echo
  echo "Known state:"
  echo "- real runtime validation advanced past /api/tasks/create"
  echo "- POST /api/tasks/complete returned HTTP 500"
  echo "- this blocks terminal success proof for Success Rate hydration"
  echo
  echo "What this means:"
  echo "- Success Rate corridor is still preserved"
  echo "- runtime validation is blocked by backend task completion failure"
  echo "- final acceptance is NOT earned yet"
  echo
  echo "Next safe step:"
  echo "- inspect /api/tasks/complete contract and backend error source"
  echo "- do not patch Success Rate forward while terminal success route is failing"
  echo
  echo "Artifacts:"
  echo "- inspection_log=${OUT}"
} > "${SUMMARY}"

echo "summary_written=${SUMMARY}"
echo "inspection_log=${OUT}"
