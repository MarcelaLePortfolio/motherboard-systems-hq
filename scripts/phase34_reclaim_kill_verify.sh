#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

: "${POSTGRES_URL:?POSTGRES_URL required}"

# Ensure ~/.psqlrc does not print noise (e.g. "Pager usage is off.")
PSQL_BASE=(env PSQLRC=/dev/null psql -X -q "$POSTGRES_URL" -v ON_ERROR_STOP=1)

echo "== Phase 34 reclaim-kill verify =="

for f in \
  drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql \
  server/worker/phase34_claim_task_id_for_test.sql \
  server/worker/phase34_heartbeat.sql \
  server/worker/phase34_reclaim_stale.sql \
  server/worker/phase34_kill_owner_for_test.sql
do
  [[ -f "$f" ]] || { echo "FAIL missing $f"; exit 1; }
done

"${PSQL_BASE[@]}" -f drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql >/dev/null

TASK_ID="$("${PSQL_BASE[@]}" -Atc \
"insert into tasks(title, agent, status, source, trace_id, meta)
 values('phase34-verify','verify','created','verify', 'phase34-verify-'||extract(epoch from now())::bigint::text, '{}'::jsonb)
 returning id;")"
TASK_ID="$(echo "$TASK_ID" | tr -d '[:space:]')"
[[ -n "$TASK_ID" ]] || { echo "FAIL: empty task_id"; exit 1; }
echo "task_id=$TASK_ID"

OWNER_A="verify-A"
OWNER_B="verify-B"

"${PSQL_BASE[@]}" -v owner="$OWNER_A" -f server/worker/phase34_heartbeat.sql >/dev/null

NOW_MS="$(python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
)"

# deterministically claim THIS task
"${PSQL_BASE[@]}" -v task_id="$TASK_ID" -v owner="$OWNER_A" -v now_ms="$NOW_MS" -v lease_ms="1000" \
  -f server/worker/phase34_claim_task_id_for_test.sql >/dev/null

CB="$("${PSQL_BASE[@]}" -Atc "select claimed_by from tasks where id=$TASK_ID;")"
CB="$(echo "$CB" | tr -d '[:space:]')"
[[ "$CB" == "$OWNER_A" ]] || { echo "FAIL claim A (got <$CB>)"; exit 1; }

# simulate crash: remove heartbeat, then force lease expiry
"${PSQL_BASE[@]}" -v owner="$OWNER_A" -f server/worker/phase34_kill_owner_for_test.sql >/dev/null
"${PSQL_BASE[@]}" -c "update tasks set lease_expires_at=0 where id=$TASK_ID;" >/dev/null

"${PSQL_BASE[@]}" -v now_ms="$NOW_MS" -v stale_heartbeat_ms="0" \
  -f server/worker/phase34_reclaim_stale.sql >/dev/null

CB2="$("${PSQL_BASE[@]}" -Atc "select coalesce(claimed_by,'') from tasks where id=$TASK_ID;")"
ST2="$("${PSQL_BASE[@]}" -Atc "select status from tasks where id=$TASK_ID;")"
CB2="$(echo "$CB2" | tr -d '[:space:]')"
ST2="$(echo "$ST2" | tr -d '[:space:]')"
[[ -z "$CB2" && "$ST2" == "created" ]] || { echo "FAIL reclaim (status=<$ST2> claimed_by=<$CB2>)"; exit 1; }

# deterministically re-claim THIS task under owner B
"${PSQL_BASE[@]}" -v owner="$OWNER_B" -f server/worker/phase34_heartbeat.sql >/dev/null
"${PSQL_BASE[@]}" -v task_id="$TASK_ID" -v owner="$OWNER_B" -v now_ms="$NOW_MS" -v lease_ms="60000" \
  -f server/worker/phase34_claim_task_id_for_test.sql >/dev/null

CB3="$("${PSQL_BASE[@]}" -Atc "select claimed_by from tasks where id=$TASK_ID;")"
CB3="$(echo "$CB3" | tr -d '[:space:]')"
[[ "$CB3" == "$OWNER_B" ]] || { echo "FAIL claim B (got <$CB3>)"; exit 1; }

echo "PASS"
