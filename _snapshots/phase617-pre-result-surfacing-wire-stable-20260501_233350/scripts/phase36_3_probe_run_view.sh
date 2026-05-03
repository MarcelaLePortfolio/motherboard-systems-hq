#!/usr/bin/env bash
set -euo pipefail

P="${P:-motherboard_systems_hq}"

PGC="$(docker ps --format '{{.Names}}' | grep -E "^${P}-postgres-1$" || true)"
: "${PGC:?ERROR: postgres container not found (expected ${P}-postgres-1)}"

echo "=== run_view columns ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
\d+ run_view
SQL

echo
echo "=== run_view sample (limit 10) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT
  run_id,
  task_id,
  actor,
  task_status,
  is_terminal,
  last_event_kind,
  last_event_ts,
  last_event_id,
  last_heartbeat_ts,
  heartbeat_age_ms,
  lease_expires_at,
  lease_fresh,
  lease_ttl_ms,
  terminal_event_kind,
  terminal_event_ts,
  terminal_event_id
FROM run_view
ORDER BY last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST, run_id DESC
LIMIT 10;
SQL

echo
echo "=== distinct task_status values ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT task_status, COUNT(*) AS n
FROM run_view
GROUP BY task_status
ORDER BY task_status NULLS LAST;
SQL

echo
echo "=== distinct last_event_kind values (top 50) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<'SQL'
\pset pager off
SELECT last_event_kind, COUNT(*) AS n
FROM run_view
GROUP BY last_event_kind
ORDER BY n DESC NULLS LAST, last_event_kind
LIMIT 50;
SQL
