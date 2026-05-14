
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: QUARANTINE FAILED HELPERS V2 ====="

mkdir -p checkpoints/phase719_quarantined_failed_helpers

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_QUARANTINE_FAILED_HELPERS_V2.txt"

QDIR="checkpoints/phase719_quarantined_failed_helpers"

{

  echo "PHASE 719 QUARANTINE FAILED HELPERS V2"

  echo ""

  echo "Branch:"

  echo "$BRANCH"

  echo ""

  echo "HEAD:"

  git log --oneline --decorate -8

  echo ""

  echo "Purpose:"

  echo "- Preserve failed helper scripts and pre-patch checkpoints as evidence."

  echo "- Remove clutter from root git status."

  echo "- Do not delete historical evidence."

  echo "- Do not modify runtime code."

  echo ""

  echo "Status before quarantine:"

  git status --short

} | tee "$OUT"

root_files=(

  "PHASE719_ADD_ARTIFACT_INSPECTION_ENDPOINT.sh"

  "PHASE719_ADD_HTML_ARTIFACT_AND_RENDER_DIRECTLY_V2.sh"

  "PHASE719_ADD_HTML_ARTIFACT_AND_RENDER_DIRECTLY_V3.sh"

  "PHASE719_ADD_HTML_ARTIFACT_HELPER_MINIMAL.sh"

  "PHASE719_ARTIFACT_VISIBILITY_INSPECT.sh"

  "PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_EXACT.sh"

  "PHASE719_ATTACH_WORKER_ARTIFACT_VOLUME_EXACT_V2.sh"

  "PHASE719_BACKEND_DIFF_AND_RUNTIME_INSPECT.sh"

  "PHASE719_COMPARE_ROUTE_BASELINES.sh"

  "PHASE719_FIND_STABLE_TASK_API_BASELINE.sh"

  "PHASE719_FIX_WORKER_ARTIFACT_VOLUME_AND_VALIDATE.sh"

  "PHASE719_PATCH_PHASE530_ARTIFACT_LINE_V2.sh"

  "PHASE719_PATCH_PHASE530_ARTIFACT_LINE_V3.sh"

  "PHASE719_PATCH_PHASE530_ARTIFACT_LINE_V4.sh"

  "PHASE719_PATCH_RECENT_TASKS_ARTIFACT_METADATA.sh"

  "PHASE719_REMOVE_MALFORMED_INLINE_ARTIFACT_ENDPOINT.sh"

  "PHASE719_REPAIR_ARTIFACT_HELPER_AND_VERIFY.sh"

  "PHASE719_REPAIR_INLINE_ARTIFACT_HELPER_AND_VERIFY.sh"

  "PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK.sh"

  "PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK_V2.sh"

  "PHASE719_VALIDATE_SHARED_ARTIFACT_VOLUME_WITH_NEW_TASK_V3.sh"

  "PHASE719_VERIFY_AND_COMMIT_ARTIFACT_PATCH.sh"

  "PHASE719_VERIFY_EXISTING_ARTIFACT_AND_COMMIT.sh"

)

checkpoint_files=(

  "checkpoints/PHASE719_BACKEND_DIFF_BEFORE_UI.patch"

  "checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME.yml"

  "checkpoints/PHASE719_DOCKER_COMPOSE_PRE_ATTACH_WORKER_ARTIFACT_VOLUME_V2.yml"

  "checkpoints/PHASE719_DOCKER_COMPOSE_PRE_WORKER_ARTIFACT_VOLUME_FIX.yml"

  "checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION.txt"

  "checkpoints/PHASE719_FRONTEND_ARTIFACT_UI_INSPECTION_NOTE.md"

  "checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V2.js"

  "checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V3.js"

  "checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V4.js"

  "checkpoints/PHASE719_PHASE530_PRE_HTML_ARTIFACT_DIRECT_RENDER.js"

  "checkpoints/PHASE719_PHASE530_PRE_HTML_ARTIFACT_DIRECT_RENDER_V2.js"

  "checkpoints/PHASE719_PHASE530_PRE_HTML_ARTIFACT_DIRECT_RENDER_V3.js"

  "checkpoints/PHASE719_PHASE530_PRE_HTML_HELPER_MINIMAL.js"

  "checkpoints/PHASE719_PHASE530_PRE_PREVIEW_MODAL_CONTENT_FETCH.js"

  "checkpoints/PHASE719_PRE_PREVIEW_PILL_CHECKPOINT.txt"

  "checkpoints/PHASE719_ROUTE_BASELINE_COMPARISON.txt"

  "checkpoints/PHASE719_ROUTE_PRE_HTML_ARTIFACT_DIRECT_RENDER.mjs"

  "checkpoints/PHASE719_ROUTE_PRE_HTML_ARTIFACT_DIRECT_RENDER_V2.mjs"

  "checkpoints/PHASE719_ROUTE_PRE_HTML_ARTIFACT_DIRECT_RENDER_V3.mjs"

  "checkpoints/PHASE719_ROUTE_PRE_HTML_HELPER_MINIMAL.mjs"

  "checkpoints/PHASE719_SHARED_ARTIFACT_VOLUME_NEW_TASK_BODY.json"

  "checkpoints/PHASE719_STABLE_TASK_API_BASELINE_SEARCH.txt"

  "checkpoints/PHASE719_WORKER_PRE_HTML_ARTIFACT_DIRECT_RENDER.mjs"

  "checkpoints/PHASE719_WORKER_PRE_HTML_ARTIFACT_DIRECT_RENDER_V2.mjs"

  "checkpoints/PHASE719_WORKER_PRE_HTML_ARTIFACT_DIRECT_RENDER_V3.mjs"

  "checkpoints/PHASE719_WORKER_PRE_HTML_HELPER_MINIMAL.mjs"

  "checkpoints/PHASE719_phase530_visible_panels_bridge_PRE_ARTIFACT_METADATA.js"

)

for f in "${root_files[@]}"; do

  if [ -e "$f" ]; then

    mv "$f" "$QDIR/$f"

  fi

done

for f in "${checkpoint_files[@]}"; do

  if [ -e "$f" ]; then

    mv "$f" "$QDIR/$(basename "$f")"

  fi

done

{

  echo ""

  echo "Quarantined files:"

  find "$QDIR" -maxdepth 1 -type f | sort

  echo ""

  echo "Status after quarantine:"

  git status --short

  echo ""

  echo "Runtime health after quarantine:"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

} >> "$OUT"

git add PHASE719_QUARANTINE_FAILED_HELPERS.sh || true

git add PHASE719_QUARANTINE_FAILED_HELPERS_V2.sh

git add "$OUT"

git add "$QDIR"

git commit -m "Phase 719: quarantine failed helper artifacts"

git push origin "$BRANCH"

echo "===== FAILED HELPERS QUARANTINED V2 ====="

