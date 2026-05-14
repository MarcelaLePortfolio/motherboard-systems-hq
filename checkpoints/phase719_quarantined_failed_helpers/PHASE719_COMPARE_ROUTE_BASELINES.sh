
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: COMPARE ROUTE BASELINES ====="

mkdir -p checkpoints

refs=(

  "dev"

  "phase719-artifact-layer-baseline"

  "phase719-inspect-pill-restored"

  "phase719-recent-tasks-single-owner"

  "phase719-triage-ui-baseline"

  "phase718-operator-lineage-ui-stable"

  "phase717-recent-tasks-polished"

  "phase717-stable-telemetry-console"

  "phase716-renderer-containment-verified"

)

{

  echo "CURRENT REF"

  git rev-parse --short HEAD

  git branch --show-current

  echo ""

  echo "CURRENT RUNTIME"

  curl -i -s http://localhost:3000/ | head -n 20 || true

  echo ""

  curl -i -s http://localhost:3000/api/tasks | head -n 40 || true

  echo ""

  for ref in "${refs[@]}"; do

    echo "================ REF: $ref ================"

    git rev-parse --short "$ref" 2>/dev/null || true

    echo ""

    echo "--- server.js route wiring ---"

    git show "$ref:server.js" 2>/dev/null | grep -nE 'apiTasksRouter|registerApiTasksRoutes|/api/tasks|/api/delegate-task|task-events|operatorGuidance|express.static|Dashboard is running|app.get\("/"' || true

    echo ""

    echo "--- api-tasks-postgres export/routes ---"

    git show "$ref:server/routes/api-tasks-postgres.mjs" 2>/dev/null | grep -nE 'apiTasksRouter|registerApiTasksRoutes|export|/api/tasks|/api/artifacts|router\.|app\.' || true

    echo ""

    echo "--- dashboard renderer candidates ---"

    git ls-tree -r --name-only "$ref" 2>/dev/null | grep -E 'public/.*\.(js|html)$|server\.js|app/.*\.(tsx|ts)$|src/.*\.(tsx|ts|js)$' | while read -r file; do

      if git show "$ref:$file" 2>/dev/null | grep -qE 'Recent Tasks|Task History|/api/tasks|renderTasks|task-card|task_id|dataset.task'; then

        echo "$file"

      fi

    done | head -n 60

    echo ""

  done

} | tee checkpoints/PHASE719_ROUTE_BASELINE_COMPARISON.txt

git add PHASE719_COMPARE_ROUTE_BASELINES.sh checkpoints/PHASE719_ROUTE_BASELINE_COMPARISON.txt

git commit -m "Phase 719: compare route baselines for recovery"

git push origin phase719-artifact-visibility-ui

echo "===== BASELINE COMPARISON COMPLETE ====="

