#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' || true)"
: "${PGC:?ERROR: postgres container not found}"

CLAIM_SQL_PATH="${CLAIM_SQL_PATH:-server/worker/phase28_claim_one.sql}"
[[ -f "$CLAIM_SQL_PATH" ]] || { echo "ERROR: missing $CLAIM_SQL_PATH" >&2; exit 1; }

TASK_ID_SUFFIX="$(date +%s)"
TASK_ID="smoke.phase32.nullmax.${TASK_ID_SUFFIX}"

echo "=== Phase32 smoke: deterministic preflight (no competing queued tasks) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SET lock_timeout = '2s';
SET statement_timeout = '10s';

DELETE FROM tasks
WHERE task_id LIKE 'smoke.phase32.%' OR task_id LIKE 'smoke.phase39.%';

DO $$
DECLARE q int;
BEGIN
  SELECT count(*) INTO q FROM tasks WHERE status='queued';
  IF q <> 0 THEN
    RAISE EXCEPTION 'preflight failed: queued tasks present (%). Refusing to run smoke.', q;
  END IF;
END$$;

SELECT 'OK: queue empty' AS verdict;
SQL

echo
echo "=== insert queued task with max_attempts NULL (Tier A, available now) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
INSERT INTO tasks (task_id, status, attempts, max_attempts, action_tier, title, available_at)
VALUES ('$TASK_ID', 'queued', 0, NULL, 'A', 'smoke phase32 NULL max_attempts', now());

SELECT id, task_id, status, attempts, max_attempts, action_tier
FROM tasks
WHERE task_id = '$TASK_ID';
SQL

echo
echo "=== claim via canonical claim SQL (bind via psql vars; no positional params leak) ==="
python3 - <<'PY' > /tmp/phase32_claim_exec.sql
import pathlib, re
s = pathlib.Path("server/worker/phase28_claim_one.sql").read_text(encoding="utf-8")
m = re.search(r'(?im)^\s*with\s+', s)
if not m:
    raise SystemExit("ERROR: could not find WITH clause in claim sql")
body = s[m.start():].strip()
body = body.replace("$1", ":'run_id'").replace("$2", ":'owner'")

print(r"\pset pager off")
print(r"\set run_id 'smoke.nullmax.RUN'")
print(r"\set owner  'smoke-nullmax'")
print(body + ";")
PY

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < /tmp/phase32_claim_exec.sql

echo
echo "=== assert task is now running and owned ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
SELECT
  CASE
    WHEN status='running' AND locked_by='smoke-nullmax' AND run_id='smoke.nullmax.RUN'
    THEN 'OK: claimed NULL max_attempts task'
    ELSE 'FAIL: did not claim as expected'
  END AS verdict,
  id, task_id, status, locked_by, run_id, attempts, max_attempts, action_tier
FROM tasks
WHERE task_id = '$TASK_ID';
SQL

echo "OK: Phase32 NULL max_attempts claim smoke passed."
