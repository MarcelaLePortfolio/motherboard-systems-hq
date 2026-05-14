
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: MINIMAL NEW TASK VOLUME TEST ====="

mkdir -p checkpoints

cat > /tmp/phase719_body.json << 'JSON'

{"title":"Phase 719 artifact preview validation: create a short rendered preview proof with headline and three bullets.","agent":"cade","source":"phase719-preview-validation"}

JSON

echo "[1] health"

curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

echo ""

echo "[2] create task"

curl -i -s --max-time 10 -X POST 'http://localhost:3000/api/tasks/create' -H 'Content-Type: application/json' --data-binary @/tmp/phase719_body.json | tee checkpoints/PHASE719_MINIMAL_CREATE_RESPONSE.txt || true

echo ""

echo "[3] wait"

sleep 8

echo "[4] tasks excerpt"

curl -s --max-time 10 'http://localhost:3000/api/tasks' | tee /tmp/phase719_tasks_after_create.json | head -c 4000 || true

echo ""

echo "[5] artifact files dashboard"

docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

echo ""

echo "[6] artifact files worker"

docker exec motherboard_systems_hq-worker-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

echo ""

echo "[7] extract newest artifact task id"

python3 - << 'PY' | tee checkpoints/PHASE719_MINIMAL_NEW_ARTIFACT_TASK_ID.txt

import json

from pathlib import Path

try:

    data=json.loads(Path("/tmp/phase719_tasks_after_create.json").read_text())

    for t in data.get("tasks", []):

        if t.get("artifact") or t.get("artifacts"):

            print(t.get("task_id",""))

            break

except Exception as e:

    print("")

PY

TASK_ID="$(cat checkpoints/PHASE719_MINIMAL_NEW_ARTIFACT_TASK_ID.txt | head -n 1)"

echo "[8] preview route for newest artifact task: $TASK_ID"

if [ -n "$TASK_ID" ]; then

  curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | tee checkpoints/PHASE719_MINIMAL_PREVIEW_ROUTE_RESPONSE.txt | head -n 160 || true

else

  echo "No artifact task id found."

fi

{

  echo "STATUS"

  git status --short

  echo ""

  echo "HEAD"

  git log --oneline --decorate -5

  echo ""

  echo "COMPOSE VOLUMES"

  grep -nE 'worker_artifacts|/app/data/artifacts|guidance_data' docker-compose.yml || true

} > checkpoints/PHASE719_MINIMAL_NEW_TASK_VOLUME_TEST_SUMMARY.txt

git add PHASE719_MINIMAL_NEW_TASK_VOLUME_TEST.sh

git add checkpoints/PHASE719_MINIMAL_CREATE_RESPONSE.txt

git add checkpoints/PHASE719_MINIMAL_NEW_ARTIFACT_TASK_ID.txt

git add checkpoints/PHASE719_MINIMAL_PREVIEW_ROUTE_RESPONSE.txt

git add checkpoints/PHASE719_MINIMAL_NEW_TASK_VOLUME_TEST_SUMMARY.txt

git commit -m "Phase 719: minimally validate artifact volume with new task"

git push origin "$(git branch --show-current)"

echo "===== MINIMAL NEW TASK VOLUME TEST COMPLETE ====="

