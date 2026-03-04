#!/usr/bin/env bash
set -euo pipefail

# Phase 58 — Demo Path Smoke (read-only assertions)
# Purpose: deterministically assert the "golden demo path" signals are observable via HTTP:
#   /api/health OK
#   /api/runs contains:
#     - at least one row with policy signal visible (last_event_kind starts with "policy.")
#     - at least one terminal row (is_terminal true OR task_status terminal)
#
# This script does NOT mutate DB directly and does NOT require psql.

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8080}"
BASE_URL="${BASE_URL:-http://${HOST}:${PORT}}"

HEALTH_URL="${HEALTH_URL:-${BASE_URL}/api/health}"
RUNS_URL="${RUNS_URL:-${BASE_URL}/api/runs}"

TIMEOUT_S="${TIMEOUT_S:-90}"
SLEEP_S="${SLEEP_S:-1}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1" >&2; exit 2; }; }
need curl
need python3

deadline=$(( $(date +%s) + TIMEOUT_S ))

echo "== Phase 58 demo-path smoke =="
echo "BASE_URL=$BASE_URL"
echo "HEALTH_URL=$HEALTH_URL"
echo "RUNS_URL=$RUNS_URL"
echo "TIMEOUT_S=$TIMEOUT_S"

wait_for_health() {
  while true; do
    if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
      echo "OK: /api/health"
      return 0
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      echo "ERROR: /api/health did not become ready within ${TIMEOUT_S}s" >&2
      curl -sS -i "$HEALTH_URL" || true
      return 1
    fi
    sleep "$SLEEP_S"
  done
}

assert_demo_signals() {
  while true; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
      echo "ERROR: demo signals not observed within ${TIMEOUT_S}s" >&2
      echo "DEBUG: last /api/runs payload (truncated):" >&2
      curl -fsS "$RUNS_URL" | python3 - <<'PY' || true
import json,sys
j=json.load(sys.stdin)
rows=j.get("rows",[])
print(json.dumps({"ok": j.get("ok"), "rows_len": len(rows), "sample": rows[:3]}, indent=2))
PY
      return 1
    fi

    payload="$(curl -fsS "$RUNS_URL" || true)"
    if [ -z "$payload" ]; then
      sleep "$SLEEP_S"
      continue
    fi

    python3 - "$payload" <<'PY'
import json,sys
payload=sys.argv[1]
j=json.loads(payload)
rows=j.get("rows",[]) or []

# Basic shape requirements
required_top=["ok","rows"]
for k in required_top:
    if k not in j:
        print(f"NEED_TOPKEY:{k}")
        sys.exit(10)

# Field expectations per row (best-effort; we treat missing as failure because demo needs visibility)
# We require these to exist on at least ONE row:
need_any_fields=["run_id","task_id","task_status","is_terminal","last_event_kind","last_event_id"]
missing_any=set(need_any_fields)
for r in rows:
    for f in list(missing_any):
        if f in r:
            missing_any.discard(f)
if missing_any:
    print("MISSING_FIELDS_ANYROW:" + ",".join(sorted(missing_any)))
    sys.exit(11)

# Policy visibility: any row whose last_event_kind begins with "policy."
policy_visible=False
for r in rows:
    k=r.get("last_event_kind") or ""
    if isinstance(k,str) and k.startswith("policy."):
        policy_visible=True
        break

# Terminal visibility: any row that is terminal by flag OR by status
terminal_statuses={"completed","failed","canceled","cancelled","succeeded","done","error"}
terminal_visible=False
for r in rows:
    if r.get("is_terminal") is True:
        terminal_visible=True
        break
    st=(r.get("task_status") or "").lower()
    if st in terminal_statuses:
        terminal_visible=True
        break

if not policy_visible:
    print("WAIT:policy_not_visible")
    sys.exit(20)
if not terminal_visible:
    print("WAIT:terminal_not_visible")
    sys.exit(21)

# Optional: ensure event ids are integers/strings that parse as ints on at least one row (monotonicity handled elsewhere)
ok_last_event_id=False
for r in rows:
    v=r.get("last_event_id")
    if v is None: 
        continue
    try:
        int(v)
        ok_last_event_id=True
        break
    except Exception:
        pass
if not ok_last_event_id:
    print("MISSING:last_event_id_not_intlike")
    sys.exit(22)

print("OK:demo_signals_observed")
PY

    rc=$?
    if [ "$rc" -eq 0 ]; then
      return 0
    fi

    sleep "$SLEEP_S"
  done
}

wait_for_health
assert_demo_signals

echo "PASS: Phase 58 demo-path smoke"
