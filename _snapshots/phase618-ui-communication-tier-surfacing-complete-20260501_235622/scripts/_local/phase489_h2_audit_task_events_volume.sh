#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H2_TASK_EVENTS_VOLUME_AUDIT.txt"
POSTGRES_CONTAINER="motherboard_systems_hq-postgres-1"

{
  echo "PHASE 489 — H2 TASK EVENTS VOLUME AUDIT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== TASK_EVENTS ROW COUNT ==="
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "
select count(*) from task_events;
"
' || true
  echo

  echo "=== LATEST 20 TASK_EVENTS ROWS ==="
  docker exec -i "$POSTGRES_CONTAINER" sh -lc '
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc "
select
  coalesce(to_char(created_at at time zone '\''UTC'\'', '\''YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'\''), '\''—'\'') || '\'' | '\'' ||
  coalesce(kind, '\''—'\'') || '\'' | task='\'' || coalesce(task_id, '\''—'\'') || '\'' | actor='\'' || coalesce(actor, '\''—'\'') || '\'' | run='\'' || coalesce(run_id, '\''—'\'')
from task_events
order by ts desc, id desc
limit 20;
"
' || true
  echo

  echo "=== LIVE SSE SAMPLE (3s) ==="
  python3 - <<'PY'
import subprocess, sys
cmd = ["curl", "-N", "-s", "--max-time", "3", "http://localhost:8080/events/task-events?cursor=0"]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
for line in proc.stdout:
    sys.stdout.write(line)
    sys.stdout.flush()
PY
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
