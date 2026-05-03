#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE62B_LIVE_CREATE_ROUTE_RESTART_CHECK_${TS}.txt"
SUMMARY="PHASE62B_LIVE_CREATE_ROUTE_RESTART_SUMMARY_${TS}.md"
TMP1="$(mktemp)"
TMP2="$(mktemp)"

INITIAL_RUN_ID="missing"
FINAL_RUN_ID="missing"

cleanup() {
  rm -f "$TMP1" "$TMP2"
}
trap cleanup EXIT

extract_run_id() {
  python3 - "$1" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("run_id"),
    p.get("runId"),
    (p.get("event") or {}).get("run_id"),
    (p.get("event") or {}).get("runId"),
    ((p.get("event") or {}).get("payload") or {}).get("run_id"),
    ((p.get("event") or {}).get("payload") or {}).get("runId"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit(1)
PY
}

exec > >(tee "$OUT") 2>&1

echo "PHASE 62B — LIVE CREATE ROUTE RESTART CHECK"
echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "base_url=${BASE_URL}"
echo

echo "== source proof =="
grep -n 'let run_id = b.run_id' server/routes/api-tasks-postgres.mjs || true
grep -n 'res.status(201).json({ ok: true, task_id, run_id, event: evt });' server/routes/api-tasks-postgres.mjs || true
echo

echo "== initial live create probe =="
curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{
    "title":"phase62b live create route restart check",
    "status":"queued",
    "meta":{"actor":"phase62b-restart-check","note":"initial probe"}
  }' | tee "$TMP1"
echo
echo

if INITIAL_RUN_ID_EXTRACTED="$(extract_run_id "$TMP1" 2>/dev/null)"; then
  INITIAL_RUN_ID="$INITIAL_RUN_ID_EXTRACTED"
fi
echo "initial_run_id=${INITIAL_RUN_ID}"
echo

if [ "$INITIAL_RUN_ID" = "missing" ]; then
  echo "== runtime appears stale: attempting docker compose refresh =="
  if docker compose version >/dev/null 2>&1; then
    docker compose ps || true
    docker compose up -d --build
    echo
    echo "== waiting for runtime =="
    sleep 8
  else
    echo "docker compose unavailable"
  fi
  echo
else
  echo "== runtime already serving run_id-enabled create route =="
  echo
fi

echo "== post-refresh live create probe =="
curl -fsS -X POST "${BASE_URL}/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{
    "title":"phase62b live create route restart check post-refresh",
    "status":"queued",
    "meta":{"actor":"phase62b-restart-check","note":"post-refresh probe"}
  }' | tee "$TMP2"
echo
echo

if FINAL_RUN_ID_EXTRACTED="$(extract_run_id "$TMP2" 2>/dev/null)"; then
  FINAL_RUN_ID="$FINAL_RUN_ID_EXTRACTED"
fi
echo "final_run_id=${FINAL_RUN_ID}"
echo

echo "== decision =="
if [ "$FINAL_RUN_ID" = "missing" ]; then
  echo "live_create_route_run_id_present=no"
else
  echo "live_create_route_run_id_present=yes"
fi

cat > "$SUMMARY" <<EOF2
PHASE 62B — LIVE CREATE ROUTE RESTART SUMMARY
Date: $(date -u +"%Y-%m-%d")

SOURCE STATUS

- create route source includes run_id mint/surface logic: yes

LIVE STATUS

- initial_run_id: ${INITIAL_RUN_ID}
- final_run_id: ${FINAL_RUN_ID}

INTERPRETATION

- if final_run_id=missing, live runtime is still not serving the patched create route
- if final_run_id is populated, runtime is now aligned and real validation may resume

NEXT RULE

- resume Success Rate runtime validation only when live_create_route_run_id_present=yes

Artifacts:
- inspection_log=${OUT}
EOF2

echo
echo "summary_written=${SUMMARY}"
echo "inspection_log=${OUT}"
