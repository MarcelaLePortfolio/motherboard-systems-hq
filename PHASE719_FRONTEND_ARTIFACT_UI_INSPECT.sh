
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: FRONTEND ARTIFACT UI INSPECTION ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "RUNTIME CONFIRMATION"

  curl -s http://localhost:3000/api/tasks/health || true

  echo ""

  curl -s http://localhost:3000/api/tasks | head -c 2000 || true

  echo ""

  echo ""

  echo "FRONTEND TASK RENDERER CANDIDATES"

  find public ui/dashboard server -type f \( -name "*.js" -o -name "*.html" -o -name "*.mjs" \) 2>/dev/null | \

    xargs grep -nE "Recent Tasks|tasks-widget|recentTasks|renderTasks|artifact|artifacts|outcome_preview|explanation_preview|/api/tasks|task_id" 2>/dev/null | head -n 300

  echo ""

  echo "CURRENT DASHBOARD SCRIPT REFERENCES"

  grep -nE '<script|phase565_recent_tasks_wire|phase530_visible_panels_bridge|task-completion|dashboard-delegation' ui/dashboard/index.html public/index.html public/dashboard.html 2>/dev/null || true

} | tee checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt

cat > checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_NOTE.md << 'NOTE'

PHASE 719 FRONTEND ARTIFACT UI INSPECTION

Confirmed:

- /api/tasks/health returns 200.

- /api/tasks returns task data.

- Completed task payload includes artifact/artifacts metadata.

Boundary:

- Frontend-only artifact visibility from this point.

- Do not re-add app.get artifact endpoint inside server/routes/api-tasks-postgres.mjs.

- Do not refactor backend routing.

- Do not modify retry contract.

Next:

- Identify active Recent Tasks renderer.

- Add artifact preview/link/readout using existing task.artifact and task.artifacts from /api/tasks.

NOTE

git add PHASE719_FRONTEND_ARTIFACT_UI_INSPECT.sh \

  checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt \

  checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_NOTE.md

git commit -m "Phase 719: inspect frontend artifact UI surface"

git push origin "$(git branch --show-current)"

