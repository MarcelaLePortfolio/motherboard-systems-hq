
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REPLACE LIFECYCLE WITH PREVIEW EXACT ====="

mkdir -p checkpoints

TARGET="public/js/phase530_visible_panels_bridge.js"

BRANCH="$(git branch --show-current)"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_PREVIEW_EXACT.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '<div style="flex:0 0 auto;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">lifecycle</div>'

new = '${artifactRaw ? `<button type="button" data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" title="Preview completed artifact" style="flex:0 0 auto;cursor:pointer;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(30,64,175,.18);">Preview</button>` : ""}'

count = text.count(old)

if count != 1:

    raise SystemExit(f"Expected exactly 1 lifecycle pill, found {count}; refusing patch.")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_PREVIEW_EXACT.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "STATIC JS PREVIEW MARKER"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "data-phase719-preview-artifact|Preview|lifecycle" | head -n 20 || true

  echo ""

  echo "TASK API ARTIFACT PRESENCE"

  curl -s --max-time 10 http://localhost:3000/api/tasks | grep -o '"artifact"' | head || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_PREVIEW_EXACT_VERIFY.txt

git add "$TARGET"

git add PHASE719_REPLACE_LIFECYCLE_WITH_PREVIEW_EXACT.sh

git add checkpoints/PHASE719_PHASE530_PRE_PREVIEW_EXACT.js

git add checkpoints/PHASE719_PHASE530_POST_PREVIEW_EXACT.js

git add checkpoints/PHASE719_PREVIEW_EXACT_VERIFY.txt

git commit -m "Phase 719: replace lifecycle pill with conditional preview"

git push origin "$BRANCH"

echo "===== PREVIEW EXACT PATCH COMPLETE ====="

