
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 REPAIR DUPLICATE IMPORTS AND VERIFY ====="

echo ""

echo "[1] Remove duplicate node:fs/node:path imports"

python3 - << 'PY'

from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")

text = p.read_text()

text = text.replace('import fs from "node:fs";\n', '')

text = text.replace('import path from "node:path";\n', '')

p.write_text(text)

print("duplicate imports removed")

PY

echo ""

echo "[2] Syntax check"

node --check server/worker/phase26_task_worker.mjs

echo ""

echo "[3] Rebuild and restart"

docker compose build worker dashboard

docker compose up -d

echo ""

echo "[4] Confirm worker is running"

sleep 5

docker compose ps -a

docker compose logs --tail=80 worker

echo ""

echo "[5] Delegate fresh artifact verification task"

curl -s -X POST "http://localhost:3000/api/delegate-task" -H "Content-Type: application/json" --data-raw '{"title":"Create a verified artifact proof for Moonrise Bakery with headline, tagline, and three section ideas.","task":"Create a verified artifact proof for Moonrise Bakery with headline, tagline, and three section ideas."}' | python3 -m json.tool || true

echo ""

echo "[6] Wait for completion"

sleep 15

echo ""

echo "[7] Verify artifact metadata and file inside worker container"

curl -s "http://localhost:3000/api/tasks" > /tmp/phase719-duplicate-import-repair-api-tasks.json

ARTIFACT_PATH="$(python3 - << 'PY'

import json

from pathlib import Path

import sys

data = json.loads(Path("/tmp/phase719-duplicate-import-repair-api-tasks.json").read_text())

tasks = data.get("tasks", [])

print("ok:", data.get("ok"), file=sys.stderr)

print("task_count:", len(tasks), file=sys.stderr)

if not tasks:

    raise SystemExit("No tasks returned.")

task = tasks[0]

artifact = task.get("artifact")

print("task_id:", task.get("task_id"), file=sys.stderr)

print("status:", task.get("status"), file=sys.stderr)

print("artifact:", json.dumps(artifact, indent=2), file=sys.stderr)

if task.get("status") != "completed":

    raise SystemExit("Latest task is not completed.")

if not artifact:

    raise SystemExit("Artifact metadata missing.")

if not artifact.get("path"):

    raise SystemExit("Artifact path missing.")

print(artifact["path"])

PY

)"

echo "artifact_path=$ARTIFACT_PATH"

docker compose exec -T worker sh -lc "test -s '$ARTIFACT_PATH' && wc -c '$ARTIFACT_PATH' && sed -n '1,80p' '$ARTIFACT_PATH'"

echo ""

echo "[8] Commit verified repair"

git status --short

git add server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs PHASE719_ADD_REAL_ARTIFACT_PERSISTENCE.sh PHASE719_REPAIR_DUPLICATE_IMPORTS_AND_VERIFY.sh

git commit -m "Phase 719: verify real worker artifact persistence"

git push origin dev

echo ""

echo "===== PHASE 719 REAL ARTIFACT PERSISTENCE VERIFIED AND PUSHED ====="

