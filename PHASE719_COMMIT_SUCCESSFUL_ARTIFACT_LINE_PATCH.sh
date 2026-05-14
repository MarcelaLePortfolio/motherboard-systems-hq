
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: COMMIT SUCCESSFUL ARTIFACT LINE PATCH ====="

mkdir -p checkpoints

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "STATIC JS ARTIFACT LINE PRESENCE"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "Artifact:" | head || true

  echo ""

  echo "TASK API ARTIFACT PRESENCE"

  curl -s --max-time 10 http://localhost:3000/api/tasks | grep -o '"artifact"' | head || true

  echo ""

  echo "GIT STATUS"

  git status --short

} > checkpoints/PHASE719_SUCCESSFUL_ARTIFACT_LINE_PATCH_VERIFY.txt

git add public/js/phase530_visible_panels_bridge.js

git add PHASE719_PATCH_PHASE530_ARTIFACT_LINE_V5.sh

git add PHASE719_COMMIT_SUCCESSFUL_ARTIFACT_LINE_PATCH.sh

git add checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V5.js

git add checkpoints/PHASE719_PHASE530_POST_ARTIFACT_LINE_V5.js

git add checkpoints/PHASE719_PHASE530_ARTIFACT_LINE_V5_VERIFY.txt

git add checkpoints/PHASE719_SUCCESSFUL_ARTIFACT_LINE_PATCH_VERIFY.txt

git commit -m "Phase 719: surface artifact metadata in recent tasks"

git push origin "$(git branch --show-current)"

echo "===== SUCCESSFUL ARTIFACT LINE PATCH COMMITTED ====="

