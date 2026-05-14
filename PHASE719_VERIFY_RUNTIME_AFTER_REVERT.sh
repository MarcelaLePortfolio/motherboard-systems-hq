
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VERIFY RUNTIME AFTER REVERT ====="

mkdir -p checkpoints

{

  echo "BRANCH"

  git branch --show-current

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "DOCKER PS"

  docker ps

  echo ""

  echo "ROOT ROUTE"

  curl -i -s http://localhost:3000/ || true

  echo ""

  echo "TASK API"

  curl -i -s http://localhost:3000/api/tasks || true

  echo ""

  echo "ARTIFACT TEST ROUTE"

  curl -i -s http://localhost:3000/api/artifacts/test || true

  echo ""

  echo "DASHBOARD LOG TAIL"

  docker logs --tail 80 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_RUNTIME_AFTER_REVERT_VERIFY.txt

git add checkpoints/PHASE719_RUNTIME_AFTER_REVERT_VERIFY.txt PHASE719_VERIFY_RUNTIME_AFTER_REVERT.sh

git commit -m "Phase 719: verify runtime after backend revert"

git push origin phase719-artifact-visibility-ui

echo "===== VERIFY COMPLETE ====="

