#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PGC="$(docker ps --format '{{.Names}}' | grep -E '^motherboard_systems_hq-postgres-1$' || true)"
if [[ -z "$PGC" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n 1 || true)"
fi
: "${PGC:?ERROR: postgres container not found}"

CLAIM_SQL_PATH="server/worker/phase28_claim_one.sql"
[[ -f "$CLAIM_SQL_PATH" ]] || { echo "ERROR: missing $CLAIM_SQL_PATH" >&2; exit 1; }

echo "Using CLAIM_SQL_PATH=$CLAIM_SQL_PATH"

SUFFIX="$(date +%s)"
TASK_A="smoke.phase39.actiontier.A.${SUFFIX}"
TASK_B="smoke.phase39.actiontier.B.${SUFFIX}"

echo "=== Phase39 smoke: deterministic preflight (no claimable Tier-A queued tasks) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SET lock_timeout = '2s';
SET statement_timeout = '10s';

DO $$
DECLARE q int;
BEGIN
  SELECT count(*) INTO q
  FROM tasks
  WHERE status='queued'
    AND COALESCE(action_tier,'A')='A'
    AND available_at <= now();

  IF q <> 0 THEN
    RAISE EXCEPTION
      'preflight failed: % claimable Tier-A queued tasks present. Refusing to run Phase39 smoke.',
      q;
  END IF;
END$$;

SELECT 'OK: no claimable Tier-A queued tasks' AS verdict;
SQL

echo
echo "=== insert Tier A + Tier B queued tasks (available_at NOW, max_attempts NULL) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
INSERT INTO tasks (task_id, status, attempts, max_attempts, action_tier, title, available_at)
VALUES
  ('$TASK_A', 'queued', 0, NULL, 'A', 'Phase39 smoke Tier A', now()),
  ('$TASK_B', 'queued', 0, NULL, 'B', 'Phase39 smoke Tier B', now());
SQL

echo
echo "=== claim twice via psql vars (no positional params) ==="

export CLAIM_SQL_PATH
export TASK_A
export TASK_B

python3 - <<'PY' > /tmp/phase39_claim_exec.sql
import pathlib, re

s = pathlib.Path("$CLAIM_SQL_PATH").read_text(encoding="utf-8")
m = re.search(r'(?im)^\s*with\s+', s)
if not m:
    raise SystemExit("ERROR: could not find WITH clause in claim sql")

body = s[m.start():].strip()
body = body.replace("\$1", ":'run_id'").replace("\$2", ":'owner'")

print(r"\pset pager off")
print(r"\set run_id 'smoke.phase39.actiontier.run1'")
print(r"\set owner  'smoke-phase39'")
print(r"\set task_a '%s'" % "$TASK_A")
print(r"\set task_b '%s'" % "$TASK_B")
print(body + ";")
print(r"\set run_id 'smoke.phase39.actiontier.run2'")
print(body + ";")

print(r"""
SELECT task_id, status, attempts, action_tier, locked_by, run_id
FROM tasks
WHERE task_id IN (:'task_a', :'task_b')
ORDER BY task_id;

DO $$DECLARE b_not_queued int;
BEGIN
  SELECT count(*) INTO b_not_queued
  FROM tasks
  WHERE task_id = :'task_b'
    AND status <> 'queued';
  IF b_not_queued <> 0 THEN
    RAISE EXCEPTION 'Phase39 gate failed: Tier B task was claimable (status changed)';
  END IF;
END$$;

DO $$DECLARE a_still_queued int;
BEGIN
  SELECT count(*) INTO a_still_queued
  FROM tasks
  WHERE task_id = :'task_a'
    AND status = 'queued';
  IF a_still_queued <> 0 THEN
    RAISE EXCEPTION 'Phase39 gate failed: Tier A task was NOT claimable (still queued)';
  END IF;
END$$;
""")
PY

docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < /tmp/phase39_claim_exec.sql

echo "OK: Phase 39 action_tier claim-time enforcement smoke passed."
