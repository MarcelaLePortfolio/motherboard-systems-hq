#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

PGC="${PGC:-}"
if [[ -z "${PGC}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | grep -E 'postgres' | head -n 1 || true)"
fi
if [[ -z "${PGC}" ]]; then
  echo "ERROR: could not auto-detect postgres container. Set PGC=..." >&2
  exit 2
fi

sql() {
  docker exec -i "$PGC" psql -v ON_ERROR_STOP=1 -U postgres -d postgres -Atc "$1"
}
# Resolve POSTGRES_URL from compose config by default.
POSTGRES_URL="${POSTGRES_URL:-}"
if [[ -z "${POSTGRES_URL}" ]]; then
  POSTGRES_URL="$(docker compose config 2>/dev/null | awk '/POSTGRES_URL:/{print $2; exit}' || true)"
fi
if [[ -z "${POSTGRES_URL}" ]]; then
  echo "ERROR: POSTGRES_URL not found. Set POSTGRES_URL=postgres://... (or ensure compose config includes it)." >&2
  exit 3
fi

echo "PGC=$PGC"
echo "POSTGRES_URL=$POSTGRES_URL"

echo "=== counts BEFORE ==="
t0="$(sql "select count(*) from tasks")"
e0="$(sql "select count(*) from task_events")"
echo "tasks=$t0 task_events=$e0"

echo
echo "=== attempt DB write under enforce (expect POLICY_ENFORCED) ==="
POLICY_ENFORCE_MODE="enforce" POSTGRES_URL="$POSTGRES_URL" node scripts/phase50_node_write_attempt.mjs

echo
echo "=== counts AFTER ==="
t1="$(sql "select count(*) from tasks")"
e1="$(sql "select count(*) from task_events")"
echo "tasks=$t1 task_events=$e1"

echo
echo "=== assert unchanged ==="
[[ "$t1" == "$t0" ]] || { echo "FAIL: tasks changed ($t0 -> $t1)"; exit 4; }
[[ "$e1" == "$e0" ]] || { echo "FAIL: task_events changed ($e0 -> $e1)"; exit 5; }
echo "OK: no DB writes under enforce."
