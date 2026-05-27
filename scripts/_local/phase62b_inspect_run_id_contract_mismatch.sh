#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_RUN_ID_CONTRACT_MISMATCH_INSPECTION_$(date -u +%Y%m%dT%H%M%SZ).txt"
SUMMARY="PHASE62B_RUN_ID_CONTRACT_MISMATCH_SUMMARY_$(date -u +%Y%m%dT%H%M%SZ).md"
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

{
  echo "PHASE 62B — RUN_ID CONTRACT MISMATCH INSPECTION"
  echo "generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "base_url=${BASE_URL}"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== create route implementation =="
  sed -n '70,145p' server/routes/api-tasks-postgres.mjs
  echo

  echo "== complete route implementation =="
  sed -n '146,186p' server/routes/api-tasks-postgres.mjs
  echo

  echo "== fail route implementation =="
  sed -n '184,224p' server/routes/api-tasks-postgres.mjs
  echo

  echo "== appendTaskEvent run_id enforcement =="
  sed -n '1,230p' server/task-events.mjs
  echo

  echo "== create a fresh task and capture raw response =="
  CREATE_JSON="$(mktemp)"
  curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
    -H 'Content-Type: application/json' \
    -d '{
      "title":"phase62b run_id contract inspection task",
      "status":"queued",
      "meta":{"actor":"phase62b-contract-inspect","note":"inspect run_id mismatch"}
    }' | tee "${CREATE_JSON}"
  echo
  echo "-- create response pretty --"
  python3 -m json.tool "${CREATE_JSON}" || cat "${CREATE_JSON}"
  echo

  TASK_ID="$(
    python3 - <<'PY' "${CREATE_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    (p.get("event") or {}).get("task_id"),
    (p.get("event") or {}).get("payload", {}).get("task_id"),
    (p.get("data") or {}).get("task_id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract task_id from create response")
PY
)"
  echo "task_id=${TASK_ID}"
  echo

  RUN_ID_FROM_CREATE="$(
    python3 - <<'PY' "${CREATE_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("run_id"),
    (p.get("event") or {}).get("run_id"),
    (p.get("event") or {}).get("payload", {}).get("run_id"),
    (p.get("data") or {}).get("run_id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
print("")
PY
)"
  echo "run_id_from_create=${RUN_ID_FROM_CREATE:-<missing>}"
  echo

  echo "== recent tasks probe for created task =="
  curl -fsS "${BASE_URL}/api/tasks?limit=10"
  echo
  echo

  echo "== verbose complete call without run_id =="
  COMPLETE_NO_RUNID="$(mktemp)"
  cat > "${COMPLETE_NO_RUNID}" <<JSON
{
  "task_id":"${TASK_ID}",
  "status":"completed",
  "meta":{"actor":"phase62b-contract-inspect","note":"complete without run_id"}
}
JSON
  curl -sS -i -X POST "${BASE_URL}/api/tasks/complete" \
    -H 'Content-Type: application/json' \
    --data-binary @"${COMPLETE_NO_RUNID}" || true
  echo
  rm -f "${COMPLETE_NO_RUNID}"

  echo "== verbose fail call without run_id =="
  FAIL_NO_RUNID="$(mktemp)"
  cat > "${FAIL_NO_RUNID}" <<JSON
{
  "task_id":"${TASK_ID}",
  "status":"failed",
  "error":"phase62b contract inspection failure sample",
  "meta":{"actor":"phase62b-contract-inspect","note":"fail without run_id"}
}
JSON
  curl -sS -i -X POST "${BASE_URL}/api/tasks/fail" \
    -H 'Content-Type: application/json' \
    --data-binary @"${FAIL_NO_RUNID}" || true
  echo
  rm -f "${FAIL_NO_RUNID}"

  if [ -n "${RUN_ID_FROM_CREATE}" ]; then
    echo "== verbose complete call with discovered run_id =="
    COMPLETE_WITH_RUNID="$(mktemp)"
    cat > "${COMPLETE_WITH_RUNID}" <<JSON
{
  "task_id":"${TASK_ID}",
  "run_id":"${RUN_ID_FROM_CREATE}",
  "status":"completed",
  "meta":{"actor":"phase62b-contract-inspect","note":"complete with discovered run_id"}
}
JSON
    curl -sS -i -X POST "${BASE_URL}/api/tasks/complete" \
      -H 'Content-Type: application/json' \
      --data-binary @"${COMPLETE_WITH_RUNID}" || true
    echo
    rm -f "${COMPLETE_WITH_RUNID}"
  else
    echo "== discovered run_id unavailable from create path =="
    echo "run_id remains absent from create response"
    echo
  fi

  rm -f "${CREATE_JSON}"
} | tee "${OUT}"

cat > "${SUMMARY}" <<EOF2
PHASE 62B — RUN_ID CONTRACT MISMATCH SUMMARY
Date: $(date -u +%Y-%m-%d)

INSPECTION GOAL

Determine whether the blocker is:
- create route not surfacing run_id
- create route not generating run_id
- terminal routes requiring run_id that runtime validation cannot provide
- fail route sharing the same mismatch

SAFE RESULT

This inspection makes no layout edits, no transport edits, no reducer edits, and no authority edits.

NEXT DECISION RULE

Proceed only after the inspection proves exactly where run_id is lost or required.

Artifacts:
- inspection_log=${OUT}
EOF2

echo "summary_written=${SUMMARY}"
echo "inspection_log=${OUT}"
