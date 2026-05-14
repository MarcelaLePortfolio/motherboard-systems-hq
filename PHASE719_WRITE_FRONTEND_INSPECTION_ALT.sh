
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: WRITE FRONTEND INSPECTION ALT CHECKPOINT ====="

mkdir -p checkpoints

ALT="checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_V2.txt"

cat > "$ALT" << 'NOTE'

PHASE 719 FRONTEND ARTIFACT UI INSPECTION V2

Confirmed:

- Runtime recovered.

- /api/tasks/health returns ok.

- /api/tasks returns completed tasks.

- Task payload already includes artifact/artifacts metadata.

- Active Recent Tasks renderer is public/js/phase530_visible_panels_bridge.js.

Boundary:

- Frontend-only from here.

- Use artifact/artifacts already returned by /api/tasks.

- Do not re-add /api/artifacts/:task_id inside api-tasks-postgres.mjs.

- Do not refactor backend routing.

- Do not modify retry contract.

Next:

- Patch public/js/phase530_visible_panels_bridge.js only.

- Surface artifact metadata on each task card.

NOTE

{

  echo ""

  echo "RUNTIME CONFIRMATION"

  curl -s http://localhost:3000/api/tasks/health || true

  echo ""

  curl -s http://localhost:3000/api/tasks | head -c 3000 || true

  echo ""

  echo ""

  echo "RELEVANT RENDERER LINES"

  grep -nE "function taskRows|const taskId|outcome_preview|explanation_preview|artifact|artifacts|recentTasks.innerHTML|getJson\\(\"/api/tasks" public/js/phase530_visible_panels_bridge.js || true

} >> "$ALT"

git add PHASE719_WRITE_FRONTEND_INSPECTION_ALT.sh "$ALT"

git commit -m "Phase 719: write alternate frontend inspection checkpoint"

git push origin "$(git branch --show-current)"

echo "===== ALT FRONTEND INSPECTION CHECKPOINT COMPLETE ====="

