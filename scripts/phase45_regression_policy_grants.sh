#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true
setopt INTERACTIVE_COMMENTS 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

PGC="${PGC:-motherboard_systems_hq-postgres-1}"
SQL_FILE="${SQL_FILE:-server/sql/phase45_policy_grants.sql}"

echo "=== Phase45: ensure postgres container present ==="
docker ps --format '{{.Names}}' | grep -qx "$PGC" || { echo "ERROR: postgres container $PGC not running"; exit 1; }

echo "=== Phase45: apply SQL (idempotent) ==="
[ -f "$SQL_FILE" ] || { echo "ERROR: SQL_FILE not found: $SQL_FILE"; exit 1; }
docker exec -i "$PGC" psql -v ON_ERROR_STOP=1 -f - < "$SQL_FILE"

echo "=== Phase45: sanity check table exists ==="
docker exec "$PGC" psql -v ON_ERROR_STOP=1 -Atqc "SELECT to_regclass('public.policy_grants') IS NOT NULL;" \
| grep -qx "t" || { echo "ERROR: policy_grants missing after apply"; exit 1; }

echo "=== Phase45: deterministic active semantics (expires_at) ==="
docker exec "$PGC" psql -v ON_ERROR_STOP=1 -Atqc "
  TRUNCATE policy_grants;
  INSERT INTO policy_grants(created_by, subject, scope, decision, reason, expires_at)
  VALUES
    ('phase45-test', 'subject:A', 'scope:X', 'allow', 'ok', now() + interval '10 minutes'),
    ('phase45-test', 'subject:A', 'scope:X', 'allow', 'expired', now() - interval '10 minutes'),
    ('phase45-test', 'subject:A', 'scope:X', 'deny',  'deny', NULL);
  SELECT count(*) FROM policy_grants_active WHERE subject='subject:A' AND scope='scope:X';
" | grep -qx "2" || { echo "ERROR: policy_grants_active semantics unexpected"; exit 1; }

echo "OK: Phase45 policy_grants regression clean."
