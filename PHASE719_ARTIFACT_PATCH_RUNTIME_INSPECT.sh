
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ARTIFACT PATCH RUNTIME INSPECTION ====="

echo ""

echo "[1] Local git + runtime status"

git status --short

git log --oneline --decorate -6

docker compose ps

echo ""

echo "[2] Local worker artifact patch presence"

python3 - << 'PY'

from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")

text = p.read_text(errors="ignore")

checks = [

    "import fs from \"node:fs\";",

    "function persistTaskArtifact",

    "const artifact = persistTaskArtifact",

    "artifact,",

    "artifacts: [artifact]",

]

for c in checks:

    print(f"{c}: {c in text}")

lines = text.splitlines()

for i, line in enumerate(lines, start=1):

    if "persistTaskArtifact" in line or "task.completed" in line or "artifact" in line:

        start = max(1, i - 4)

        end = min(len(lines), i + 8)

        print(f"\n--- local lines {start}-{end} ---")

        for n in range(start, end + 1):

            print(f"{n}: {lines[n-1]}")

PY

echo ""

echo "[3] Container worker artifact patch presence"

docker compose exec -T worker sh -lc '

echo "worker file:"

ls -l /app/server/worker/phase26_task_worker.mjs

echo ""

echo "artifact terms:"

grep -nE "persistTaskArtifact|artifact|artifacts|task.completed" /app/server/worker/phase26_task_worker.mjs | head -80 || true

'

echo ""

echo "[4] Latest completed task event payload from Postgres"

docker compose exec -T postgres psql -U postgres -d postgres -c "

SELECT

  id,

  kind,

  task_id,

  payload->'artifact' AS artifact,

  payload->'artifacts' AS artifacts,

  left(payload::text, 1200) AS payload_preview

FROM task_events

WHERE kind = 'task.completed'

ORDER BY id DESC

LIMIT 3;

"

echo ""

echo "[5] Worker logs since restart"

docker compose logs --tail=120 worker

echo ""

echo "===== PHASE 719 ARTIFACT PATCH RUNTIME INSPECTION COMPLETE ====="

