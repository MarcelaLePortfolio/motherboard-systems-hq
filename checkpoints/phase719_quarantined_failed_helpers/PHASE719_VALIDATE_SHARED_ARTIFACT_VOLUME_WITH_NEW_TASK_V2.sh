
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VALIDATE SHARED ARTIFACT VOLUME WITH NEW TASK V2 ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_VERIFY_V2.txt"

TEST_TITLE="Phase 719 artifact preview validation: create a short rendered preview proof with headline and three bullets."

echo "[1] Create validation task through existing task API"

CREATE_RESPONSE="$(

  curl -sS --max-time 10 \

    -X POST "http://localhost:3000/api/tasks/create" \

    -H "Content-Type: application/json" \

    --data-raw "{\"title\":\"$TEST_TITLE\",\"agent\":\"cade\",\"source\":\"phase719-preview-validation\"}" \

  || true

)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_CREATE_RESPONSE_V2.json

TASK_ID="$(

  printf '%s' "$CREATE_RESPONSE" | python3 -c 'import json,sys

try:

    print(json.load(sys.stdin).get("task_id",""))

except Exception:

    print("")

'

)"

echo "[2] Validation task_id: $TASK_ID"

echo "[3] Wait for worker completion"

for i in $(seq 1 30); do

  STATUS="$(

    TASK_ID="$TASK_ID" curl -s --max-time 10 "http://localhost:3000/api/tasks" | TASK_ID="$TASK_ID" python3 -c 'import json,sys,os

tid=os.environ.get("TASK_ID","")

try:

    data=json.load(sys.stdin)

    for t in data.get("tasks",[]):

        if t.get("task_id")==tid:

            print(t.get("status",""))

            raise SystemExit

except Exception:

    pass

print("")

' || true

  )"

  echo "poll $i status=$STATUS"

  if [ "$STATUS" = "completed" ]; then

    break

  fi

  sleep 2

done

{

  echo "PHASE 719 SHARED ARTIFACT VOLUME NEW TASK VERIFY V2"

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

  echo "Dashboard logs:"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "Worker logs:"

  docker logs --tail 160 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK.sh || true

git add PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK_V2.sh

git add checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_CREATE_RESPONSE_V2.json

git add "$OUT"

git commit -m "Phase 719: validate shared artifact volume with new task"

git push origin "$BRANCH"

echo "===== SHARED ARTIFACT VOLUME NEW TASK VALIDATION COMPLETE ====="

