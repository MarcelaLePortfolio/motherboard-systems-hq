
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT PHASE530 RENDER BLOCK EXACT ====="

mkdir -p checkpoints

{

  echo "STATUS"

  git status --short

  echo ""

  echo "SYNTAX"

  node --check public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "RENDER BLOCK LINES 178-240"

  nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '178,240p'

  echo ""

  echo "ARTIFACT VAR PRESENCE"

  grep -nE "artifactRaw|artifactName|artifactType|artifactSize|task_id:|status:" public/js/phase530_visible_panels_bridge.js || true

} | tee checkpoints/PHASE719_PHASE530_RENDER_BLOCK_EXACT.txt

git add PHASE719_PATCH_PHASE530_ARTIFACT_LINE.sh PHASE719_INSPECT_PHASE530_RENDER_BLOCK_EXACT.sh checkpoints/PHASE719_PHASE530_RENDER_BLOCK_EXACT.txt checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE.js || true

git commit -m "Phase 719: inspect exact phase530 render block after artifact patch refusal"

git push origin "$(git branch --show-current)"

