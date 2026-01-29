#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

: "${POSTGRES_URL:?POSTGRES_URL required}"

echo "== Phase 34 reclaim-kill verify =="

for f in \
  drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql \
  server/worker/phase34_claim_one.sql \
  server/worker/phase34_heartbeat.sql \
  server/worker/phase34_reclaim_stale.sql \
  server/worker/phase34_kill_owner_for_test.sql
do
  [[ -f "$f" ]] || { echo "FAIL missing $f"; exit 1; }
done

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -f drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql >/dev/null

TASK_ID="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -Atc \
"insert into tasks(title, agent, status, source, trace_id, meta)
 values('phase34-verify','verify','queued','verify', 'phase34-verify-'||extract(epoch from now())::bigint::text, '{}'::jsonb)
 returning id;")"
echo "task_id=$TASK_ID"

OWNER_A="verify-A"
OWNER_B="verify-B"

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v owner="$OWNER_A" -f server/worker/phase34_heartbeat.sql >/dev/null

NOW_MS="$(python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
)"

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v owner="$OWNER_A" -v now_ms="$NOW_MS" -v lease_ms="1000" \
  -f server/worker/phase34_claim_one.sql >/dev/null

CB="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -Atc "select claimed_by from tasks where id=$TASK_ID;")"
[[ "$CB" == "$OWNER_A" ]] || { echo "FAIL claim A (got <$CB>)"; exit 1; }

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v owner="$OWNER_A" -f server/worker/phase34_kill_owner_for_test.sql >/dev/null
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -c "update tasks set lease_expires_at=0 where id=$TASK_ID;" >/dev/null

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v now_ms="$NOW_MS" -v stale_heartbeat_ms="0" \
  -f server/worker/phase34_reclaim_stale.sql >/dev/null

CB2="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -Atc "select coalesce(claimed_by,'') from tasks where id=$TASK_ID;")"
ST2="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -Atc "select status from tasks where id=$TASK_ID;")"
[[ -z "$CB2" && "$ST2" == "queued" ]] || { echo "FAIL reclaim (status=<$ST2> claimed_by=<$CB2>)"; exit 1; }

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v owner="$OWNER_B" -f server/worker/phase34_heartbeat.sql >/dev/null
psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -v owner="$OWNER_B" -v now_ms="$NOW_MS" -v lease_ms="60000" \
  -f server/worker/phase34_claim_one.sql >/dev/null

CB3="$(psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -Atc "select claimed_by from tasks where id=$TASK_ID;")"
[[ "$CB3" == "$OWNER_B" ]] || { echo "FAIL claim B (got <$CB3>)"; exit 1; }

echo "PASS"
