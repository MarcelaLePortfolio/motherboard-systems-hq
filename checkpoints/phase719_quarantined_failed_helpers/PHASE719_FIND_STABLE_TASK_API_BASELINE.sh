
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: FIND STABLE TASK API BASELINE ====="

mkdir -p checkpoints

{

  echo "CURRENT BRANCH"

  git branch --show-current

  echo ""

  echo "CURRENT STATUS"

  git status --short

  echo ""

  echo "RECENT COMMITS"

  git log --oneline --decorate -30

  echo ""

  echo "RECENT TAGS"

  git tag --sort=-creatordate | head -n 30

  echo ""

  echo "COMMITS TOUCHING server.js"

  git log --oneline --decorate -- server.js | head -n 40

  echo ""

  echo "COMMITS TOUCHING api-tasks-postgres"

  git log --oneline --decorate -- server/routes/api-tasks-postgres.mjs | head -n 40

  echo ""

  echo "CURRENT SERVER ROUTE WIRING"

  grep -nE "apiTasksRouter|registerApiTasksRoutes|api/tasks|delegate-task|task-events|operatorGuidance|express.static|Dashboard is running" server.js || true

  echo ""

  echo "CURRENT TASK ROUTE FILE WIRING"

  grep -nE "router|get\\(|post\\(|/api/tasks|/api/artifacts|task_id|export" server/routes/api-tasks-postgres.mjs || true

  echo ""

  echo "SEARCH HISTORY FOR SERVER TASK ROUTE WIRING"

  for ref in $(git log --format='%H' --all -- server.js | head -n 80); do

    if git show "$ref:server.js" 2>/dev/null | grep -qE "apiTasksRouter|registerApiTasksRoutes|/api/tasks|/api/delegate-task"; then

      echo "MATCH $ref $(git log -1 --oneline "$ref")"

      git show "$ref:server.js" 2>/dev/null | grep -nE "apiTasksRouter|registerApiTasksRoutes|/api/tasks|/api/delegate-task|task-events|operatorGuidance|express.static|Dashboard is running" | head -n 40 || true

      echo ""

    fi

  done

  echo "SEARCH HISTORY FOR TASK ROUTE EXPORT SHAPE"

  for ref in $(git log --format='%H' --all -- server/routes/api-tasks-postgres.mjs | head -n 80); do

    if git show "$ref:server/routes/api-tasks-postgres.mjs" 2>/dev/null | grep -qE "apiTasksRouter|registerApiTasksRoutes|/api/tasks|/api/artifacts"; then

      echo "MATCH $ref $(git log -1 --oneline "$ref")"

      git show "$ref:server/routes/api-tasks-postgres.mjs" 2>/dev/null | grep -nE "apiTasksRouter|registerApiTasksRoutes|/api/tasks|/api/artifacts|export" | head -n 60 || true

      echo ""

    fi

  done

} | tee checkpoints/PHASE719_STABLE_TASK_API_BASELINE_SEARCH.txt

cat > checkpoints/PHASE719_STABLE_TASK_API_BASELINE_SEARCH_NOTE.md << 'NOTE'

PHASE 719 STABLE TASK API BASELINE SEARCH

Reason:

- Current runtime shows root placeholder only.

- Current runtime shows /api/tasks returning Cannot GET /api/tasks.

- Artifact UI work is blocked until real dashboard/task API baseline is restored.

Purpose:

- Identify the last safe commit/tag containing dashboard task route wiring.

- Do not patch UI until the task API and dashboard surface are restored.

NOTE

git add PHASE719_FIND_STABLE_TASK_API_BASELINE.sh checkpoints/PHASE719_STABLE_TASK_API_BASELINE_SEARCH.txt checkpoints/PHASE719_STABLE_TASK_API_BASELINE_SEARCH_NOTE.md

git commit -m "Phase 719: search for stable task API baseline"

git push origin phase719-artifact-visibility-ui

echo "===== BASELINE SEARCH COMPLETE ====="

