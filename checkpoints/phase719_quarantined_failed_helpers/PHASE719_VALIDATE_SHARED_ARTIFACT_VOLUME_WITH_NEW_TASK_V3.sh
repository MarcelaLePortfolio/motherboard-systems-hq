
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VALIDATE SHARED ARTIFACT VOLUME WITH NEW TASK V3 ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_VERIFY_V3.txt"

BODY_FILE="checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_BODY.json"

CREATE_RESPONSE_FILE="checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_CREATE_RESPONSE_V3.json"

cat > "$BODY_FILE" << 'JSON'

{

  "title": "Phase 719 artifact preview validation: create a short rendered preview proof with headline and three bullets.",

  "agent": "cade",

  "source": "phase719-preview-validation"

}

JSON

echo "[1] Create validation task through existing task API"

curl -sS --max-time 10 \

  -X POST "http://localhost:3000/api/tasks/create" \

  -H "Content-Type: application/json" \

  --data-binary @"$BODY_FILE" \

  > "$CREATE_RESPONSE_FILE" || true

cat "$CREATE_RESPONSE_FILE"

TASK_ID="$(python3 - << 'PY'

import json

from pathlib import Path

try:

    data = json.loads(Path("checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_CREATE_RESPONSE_V3.json").read_text())

    print(data.get("task_id",""))

except Exception:

    print("")

PY

)"

echo ""

echo "[2] Validation task_id: $TASK_ID"

echo "[3] Wait for worker completion"

for i in $(seq 1 30); do

  curl -s --max-time 10 "http://localhost:3000/api/tasks" > /tmp/phase719_tasks.json || true

  STATUS="$(TASK_ID="$TASK_ID" python3 - << 'PY'

import json, os

from pathlib import Path

tid = os.environ.get("TASK_ID", "")

try:

    data = json.loads(Path("/tmp/phase719_tasks.json").read_text())

    for task in data.get("tasks", []):

        if task.get("task_id") == tid:

            print(task.get("status", ""))

            raise SystemExit

except Exception:

    pass

print("")

PY

)"

  echo "poll $i status=$STATUS"

  if [ "$STATUS" = "completed" ]; then

    break

  fi

  sleep 2

done

{

  echo "PHASE 719 SHARED ARTIFACT VOLUME NEW TASK VERIFY V3"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "Created task:"

  echo "$TASK_ID"

  echo ""

  echo "Runtime health:"

  curl -i -s --max-time 10 "http://localhost:3000/api/tasks/health" || true

  echo ""

  echo "Task list excerpt:"

  curl -s --max-time 10 "http://localhost:3000/api/tasks" | head -c 3000 || true

  echo ""

  echo ""

  echo "Dashboard artifact files:"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

  echo ""

  echo "Worker artifact files:"

  docker exec motherboard_systems_hq-worker-1 sh -lc 'find /app/data/artifacts -maxdepth 2 -type f -print 2>/dev/null | sort | tail -20' || true

  echo ""

  echo "Artifact preview route for validation task:"

  if [ -n "$TASK_ID" ]; then

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 180 || true

  else

    echo "No validation task_id available."

  fi

  echo ""

  echo "Compose artifact volume markers:"

  grep -nE "worker_artifacts|/app/data/artifacts|guidance_data" docker-compose.yml || true

  echo ""

  echo "Dashboard logs:"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "Worker logs:"

  docker logs --tail 160 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK.sh || true

git add PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK_V2.sh || true

git add PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK_V3.sh

git add "$BODY_FILE"

git add "$CREATE_RESPONSE_FILE"

git add "$OUT"

git commit -m "Phase 719: validate shared artifact volume with new task"

git push origin "$BRANCH"

echo "===== SHARED ARTIFACT VOLUME NEW TASK VALIDATION COMPLETE ====="

