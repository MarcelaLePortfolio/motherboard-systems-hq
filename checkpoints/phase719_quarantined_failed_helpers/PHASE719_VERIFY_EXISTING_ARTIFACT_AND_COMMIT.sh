
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 VERIFY EXISTING ARTIFACT AND COMMIT ====="

echo ""

echo "[1] Runtime status"

docker compose ps

echo ""

echo "[2] Wait for worker completion"

sleep 15

echo ""

echo "[3] Verify latest task artifact through /api/tasks"

curl -s "http://localhost:3000/api/tasks" > /tmp/phase719-existing-artifact-tasks.json

python3 - << 'PY'

import json

from pathlib import Path

data = json.loads(Path("/tmp/phase719-existing-artifact-tasks.json").read_text())

tasks = data.get("tasks", [])

print("ok:", data.get("ok"))

print("task_count:", len(tasks))

if not tasks:

    raise SystemExit("No tasks returned.")

task = tasks[0]

artifact = task.get("artifact")

print("task_id:", task.get("task_id"))

print("status:", task.get("status"))

print("artifact:", json.dumps(artifact, indent=2))

print("artifacts:", json.dumps(task.get("artifacts"), indent=2))

if task.get("status") != "completed":

    raise SystemExit("Latest task is not completed yet.")

if not artifact:

    raise SystemExit("Artifact metadata missing from latest completed task.")

artifact_path = artifact.get("path")

if not artifact_path:

    raise SystemExit("Artifact path missing.")

p = Path(artifact_path)

print("artifact_path_exists:", p.exists())

if not p.exists():

    raise SystemExit("Artifact file does not exist at recorded path.")

print("artifact_size:", p.stat().st_size)

if p.stat().st_size <= 0:

    raise SystemExit("Artifact file is empty.")

print("artifact_preview:")

print(p.read_text(errors="ignore")[:1200])

PY

echo ""

echo "[4] Commit verified artifact patch"

git status --short

git add server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs PHASE719_ADD_REAL_ARTIFACT_PERSISTENCE.sh PHASE719_VERIFY_AND_COMMIT_ARTIFACT_PATCH.sh PHASE719_VERIFY_EXISTING_ARTIFACT_AND_COMMIT.sh

git commit -m "Phase 719: persist real worker artifacts"

git push origin dev

echo ""

echo "===== PHASE 719 REAL ARTIFACT PATCH VERIFIED AND PUSHED ====="

