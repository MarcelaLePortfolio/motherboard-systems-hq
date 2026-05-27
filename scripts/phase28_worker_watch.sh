#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

PGCTR="${PGCTR:-motherboard_systems_hq-postgres-1}"
WCTR="${WCTR:-motherboard_systems_hq-worker-1}"
TASK_ID="${TASK_ID:-131}"

echo "=== containers ==="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | sed -n '1,80p'
echo
echo "=== worker env excerpt ==="
docker inspect "$WCTR" --format 'Cmd={{json .Config.Cmd}}
Entrypoint={{json .Config.Entrypoint}}
Env={{range .Config.Env}}{{println .}}{{end}}' | sed -n '1,220p'
echo
echo "=== precheck: task row ==="
docker exec -it "$PGCTR" sh -lc "
set -e
DB=${POSTGRES_DB:-postgres}
psql -U ${POSTGRES_USER:-postgres} -d "$DB" -c "
select id,status,attempt,locked_by,locked_at,updated_at
from tasks
where id=${TASK_ID};
"
"
echo
echo "=== tail worker logs (ctrl-c to stop) ==="
docker logs -f --tail 200 "$WCTR"
