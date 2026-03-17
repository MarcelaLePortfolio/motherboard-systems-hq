#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
OUT="PHASE62B_REAL_RUNTIME_VALIDATION_$(date -u +%Y%m%dT%H%M%SZ).txt"

echo "PHASE 62B — REAL SUCCESS RATE RUNTIME VALIDATION" | tee "$OUT"
echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" | tee -a "$OUT"
echo "base_url=${BASE_URL}" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== precheck routes ==" | tee -a "$OUT"
curl -fsS "${BASE_URL}/api/tasks?limit=5" | tee -a "$OUT" >/dev/null
echo "ok: GET /api/tasks reachable" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== step 1: create success candidate ==" | tee -a "$OUT"
CREATE_SUCCESS_JSON="$(mktemp)"
curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{
    "kind":"demo.seed",
    "type":"demo.seed",
    "title":"phase62b runtime success candidate",
    "name":"phase62b runtime success candidate",
    "payload":{"msg":"phase62b success validation"},
    "meta":{"actor":"phase62b-runtime-validation","note":"success candidate"}
  }' | tee "$CREATE_SUCCESS_JSON" | tee -a "$OUT"
echo | tee -a "$OUT"

SUCCESS_TASK_ID="$(python3 - <<'PY' "$CREATE_SUCCESS_JSON"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    p.get("taskId"),
    p.get("id"),
    (p.get("task") or {}).get("task_id"),
    (p.get("task") or {}).get("taskId"),
    (p.get("task") or {}).get("id"),
    (p.get("data") or {}).get("task_id"),
    (p.get("data") or {}).get("taskId"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract success task id from create response")
PY
)"
echo "success_task_id=${SUCCESS_TASK_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== step 2: complete success candidate ==" | tee -a "$OUT"
curl -fsS -X POST "${BASE_URL}/api/tasks/complete" \
  -H 'Content-Type: application/json' \
  -d "{
    \"task_id\":\"${SUCCESS_TASK_ID}\",
    \"status\":\"completed\",
    \"meta\":{\"actor\":\"phase62b-runtime-validation\",\"note\":\"success terminal event\"}
  }" | tee -a "$OUT"
echo | tee -a "$OUT"

sleep 2

echo "== step 3: create failure candidate ==" | tee -a "$OUT"
CREATE_FAILURE_JSON="$(mktemp)"
curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{
    "kind":"demo.seed",
    "type":"demo.seed",
    "title":"phase62b runtime failure candidate",
    "name":"phase62b runtime failure candidate",
    "payload":{"msg":"phase62b failure validation"},
    "meta":{"actor":"phase62b-runtime-validation","note":"failure candidate"}
  }' | tee "$CREATE_FAILURE_JSON" | tee -a "$OUT"
echo | tee -a "$OUT"

FAILURE_TASK_ID="$(python3 - <<'PY' "$CREATE_FAILURE_JSON"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    p.get("taskId"),
    p.get("id"),
    (p.get("task") or {}).get("task_id"),
    (p.get("task") or {}).get("taskId"),
    (p.get("task") or {}).get("id"),
    (p.get("data") or {}).get("task_id"),
    (p.get("data") or {}).get("taskId"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract failure task id from create response")
PY
)"
echo "failure_task_id=${FAILURE_TASK_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"

echo "== step 4: fail failure candidate ==" | tee -a "$OUT"
curl -fsS -X POST "${BASE_URL}/api/tasks/fail" \
  -H 'Content-Type: application/json' \
  -d "{
    \"task_id\":\"${FAILURE_TASK_ID}\",
    \"status\":\"failed\",
    \"error\":\"phase62b runtime validation failure sample\",
    \"meta\":{\"actor\":\"phase62b-runtime-validation\",\"note\":\"failure terminal event\"}
  }" | tee -a "$OUT"
echo | tee -a "$OUT"

sleep 2

echo "== step 5: recent tasks probe ==" | tee -a "$OUT"
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

rm -f "$CREATE_SUCCESS_JSON" "$CREATE_FAILURE_JSON"
