#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/server/worker/phase27_claim_one.sql"
mkdir -p "$(dirname "$OUT")"

has_priority=0


if [ -n "${POSTGRES_URL:-}" ] && command -v psql >/dev/null 2>&1; then
  if psql "$POSTGRES_URL" -X -A -t -q -c \
    "select 1 from information_schema.columns where table_schema='public' and table_name='tasks' and column_name='priority' limit 1;" \
    | grep -q '^1$'; then
    has_priority=1
  fi
fi

if [ "$has_priority" -eq 1 ]; then
  ORDER_BY="priority desc, id asc"
else
  ORDER_BY="id asc"
fi

cat > "$OUT" <<SQL
-- phase27: claim one queued task (conditional ORDER BY priority if present)
with cte as (
  select id
  from tasks
  where status = 'queued'
  order by ${ORDER_BY}
  for update skip locked
  limit 1
)
update tasks t
set
  status = 'running',
  updated_at = now()
from cte
where t.id = cte.id
returning t.*;
SQL

echo "[phase27] wrote $OUT (ORDER BY: $ORDER_BY)"
