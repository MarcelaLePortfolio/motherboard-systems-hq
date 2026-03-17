#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_REAL_RUNTIME_VALIDATION_${TS}.txt"

CREATE_SUCCESS_JSON="$(mktemp)"
CREATE_FAILURE_JSON="$(mktemp)"

cleanup() {
  rm -f "$CREATE_SUCCESS_JSON" "$CREATE_FAILURE_JSON"
}
trap cleanup EXIT

extract_json_field() {
  local json_file="$1"
  local field_name="$2"
  python3 - <<'PY' "$json_file" "$field_name"
import json
import sys

path = sys.argv[1]
field = sys.argv[2]

with open(path, "r", encoding="utf-8") as fh:
    payload = json.load(fh)

def pick(obj, key):
    if not isinstance(obj, dict):
        return None
    if key in obj and obj.get(key) not in (None, ""):
        return obj.get(key)
    event = obj.get("event")
    if isinstance(event, dict) and event.get(key) not in (None, ""):
        return event.get(key)
    event_payload = event.get("payload") if isinstance(event, dict) else None
    if isinstance(event_payload, dict) and event_payload.get(key) not in (None, ""):
        return event_payload.get(key)
    data = obj.get("data")
    if isinstance(data, dict) and data.get(key) not in (None, ""):
        return data.get(key)
    return None

value = pick(payload, field)
if value in (None, ""):
    raise SystemExit(f"ERROR: could not extract {field} from create response")
print(str(value))
PY
}

{
  echo "PHASE 62B — REAL SUCCESS RATE RUNTIME VALIDATION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "base_url=${BASE_URL}"
  echo

  echo "== precheck routes =="
  if curl -fsS "${BASE_URL}/api/tasks" >/dev/null; then
    echo "ok: GET /api/tasks reachable"
  else
    echo "ERROR: GET /api/tasks unreachable"
    exit 1
  fi
  echo

  echo "== step 1: create success candidate =="
  curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
    -H 'Content-Type: application/json' \
    -d '{
      "title":"phase62b runtime success candidate",
      "status":"queued",
      "meta":{"actor":"phase62b-runtime-validation","note":"success candidate"}
    }' | tee "$CREATE_SUCCESS_JSON" | tee -a "$OUT"
  echo | tee -a "$OUT"

  SUCCESS_TASK_ID="$(extract_json_field "$CREATE_SUCCESS_JSON" "task_id")"
  SUCCESS_RUN_ID="$(extract_json_field "$CREATE_SUCCESS_JSON" "run_id")"
  echo "success_task_id=${SUCCESS_TASK_ID}" | tee -a "$OUT"
  echo "success_run_id=${SUCCESS_RUN_ID}" | tee -a "$OUT"
  echo | tee -a "$OUT"

  echo "== step 2: complete success candidate =="
  curl -fsS -X POST "${BASE_URL}/api/tasks/complete" \
    -H 'Content-Type: application/json' \
    -d "{
      \"task_id\":\"${SUCCESS_TASK_ID}\",
      \"run_id\":\"${SUCCESS_RUN_ID}\",
      \"status\":\"completed\",
      \"meta\":{\"actor\":\"phase62b-runtime-validation\",\"note\":\"success terminal event\"}
    }" | tee -a "$OUT"
  echo | tee -a "$OUT"

  sleep 2

  echo "== step 3: create failure candidate =="
  curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
    -H 'Content-Type: application/json' \
    -d '{
      "title":"phase62b runtime failure candidate",
      "status":"queued",
      "meta":{"actor":"phase62b-runtime-validation","note":"failure candidate"}
    }' | tee "$CREATE_FAILURE_JSON" | tee -a "$OUT"
  echo | tee -a "$OUT"

  FAILURE_TASK_ID="$(extract_json_field "$CREATE_FAILURE_JSON" "task_id")"
  FAILURE_RUN_ID="$(extract_json_field "$CREATE_FAILURE_JSON" "run_id")"
  echo "failure_task_id=${FAILURE_TASK_ID}" | tee -a "$OUT"
  echo "failure_run_id=${FAILURE_RUN_ID}" | tee -a "$OUT"
  echo | tee -a "$OUT"

  echo "== step 4: fail failure candidate =="
  curl -fsS -X POST "${BASE_URL}/api/tasks/fail" \
    -H 'Content-Type: application/json' \
    -d "{
      \"task_id\":\"${FAILURE_TASK_ID}\",
      \"run_id\":\"${FAILURE_RUN_ID}\",
      \"status\":\"failed\",
      \"error\":\"phase62b runtime validation failure sample\",
      \"meta\":{\"actor\":\"phase62b-runtime-validation\",\"note\":\"failure terminal event\"}
    }" | tee -a "$OUT"
  echo | tee -a "$OUT"

  sleep 2

  echo "== step 5: recent tasks probe =="
  curl -fsS "${BASE_URL}/api/tasks?limit=10" | tee -a "$OUT"
  echo | tee -a "$OUT"

  echo "== operator instructions ==" | tee -a "$OUT"
  echo "1. Keep http://127.0.0.1:8080/dashboard open during this run." | tee -a "$OUT"
  echo "2. Record initial Success Rate before running script." | tee -a "$OUT"
  echo "3. After step 2, note post-success Success Rate." | tee -a "$OUT"
  echo "4. After step 4, note post-failure Success Rate." | tee -a "$OUT"
  echo "5. Confirm Running Tasks returns to prior baseline after each terminal event." | tee -a "$OUT"
  echo "6. Confirm Latency still updates and no layout drift appears." | tee -a "$OUT"
  echo "7. If any ambiguity appears, stop and record findings only." | tee -a "$OUT"
  echo | tee -a "$OUT"

  echo "validation_log=${OUT}" | tee -a "$OUT"
  echo "PASS GATE NOT AUTOMATIC: dashboard movement must be visually confirmed." | tee -a "$OUT"
} | tee -a "$OUT"
