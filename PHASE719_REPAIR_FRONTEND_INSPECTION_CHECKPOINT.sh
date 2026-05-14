
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REPAIR FRONTEND INSPECTION CHECKPOINT ====="

mkdir -p checkpoints

rm -f checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt

touch checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt

chmod 644 checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt

{

  echo "PHASE 719 FRONTEND ARTIFACT UI INSPECTION"

  echo ""

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "RUNTIME CONFIRMATION"

  curl -s http://localhost:3000/api/tasks/health || true

  echo ""

  curl -s http://localhost:3000/api/tasks | head -c 3000 || true

  echo ""

  echo ""

  echo "ACTIVE FRONTEND TASK RENDERER"

  echo "public/js/phase530_visible_panels_bridge.js"

  echo ""

  echo "RELEVANT LINES"

  grep -nE "function taskRows|const taskId|outcome_preview|explanation_preview|artifact|artifacts|recentTasks.innerHTML|getJson\\(\"/api/tasks" public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "BOUNDARY"

  echo "- frontend-only from here"

  echo "- use artifact/artifacts already returned by /api/tasks"

  echo "- do not re-add /api/artifacts/:task_id inside api-tasks-postgres.mjs"

  echo "- do not refactor backend routing"

  echo "- do not modify retry contract"

} > checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt

cat > checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_NOTE.md << 'NOTE'

PHASE 719 FRONTEND ARTIFACT UI INSPECTION NOTE

Confirmed:

- Runtime recovered.

- /api/tasks/health returns ok.

- /api/tasks returns completed tasks.

- Task payload already includes artifact/artifacts metadata.

- Active Recent Tasks renderer is public/js/phase530_visible_panels_bridge.js.

Next:

- Patch public/js/phase530_visible_panels_bridge.js only.

- Surface artifact metadata already present on each task card.

- No backend route changes.

NOTE

git add PHASE719_REPAIR_FRONTEND_INSPECTION_CHECKPOINT.sh \

  checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt \

  checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_NOTE.md

git commit -m "Phase 719: repair frontend inspection checkpoint"

git push origin "$(git branch --show-current)"

