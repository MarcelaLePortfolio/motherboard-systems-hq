
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: COMMIT READONLY ARTIFACT PREVIEW ROUTE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_READONLY_ARTIFACT_PREVIEW_ROUTE_FINAL_VERIFY.txt"

TASK_ID="$(curl -s --max-time 10 http://localhost:3000/api/tasks | node -e '

let s="";

process.stdin.on("data", d => s += d);

process.stdin.on("end", () => {

  try {

    const data = JSON.parse(s);

    const task = (data.tasks || []).find(t => t.artifact || (Array.isArray(t.artifacts) && t.artifacts.length));

    process.stdout.write(task?.task_id || "");

  } catch {}

});

')"

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK_ID"

  echo "$TASK_ID"

  echo ""

  echo "ARTIFACT PREVIEW ROUTE"

  if [ -n "$TASK_ID" ]; then

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 120 || true

  else

    echo "No artifact task found."

  fi

  echo ""

  echo "ROUTE MARKERS"

  grep -nE "artifact-preview|artifact_path_rejected|artifact_preview_failed" server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "SYNTAX"

  node --check server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee "$OUT"

git add server/routes/api-tasks-postgres.mjs

git add PHASE719_ADD_READONLY_ARTIFACT_PREVIEW_ROUTE.sh

git add PHASE719_COMMIT_READONLY_ARTIFACT_PREVIEW_ROUTE.sh

git add checkpoints/PHASE719_API_TASKS_POSTGRES_PRE_ARTIFACT_PREVIEW_ROUTE.mjs

git add checkpoints/PHASE719_API_TASKS_POSTGRES_POST_ARTIFACT_PREVIEW_ROUTE.mjs

git add "$OUT"

git commit -m "Phase 719: add readonly artifact preview content route"

git push origin "$BRANCH"

echo "===== READONLY ARTIFACT PREVIEW ROUTE COMMITTED ====="

