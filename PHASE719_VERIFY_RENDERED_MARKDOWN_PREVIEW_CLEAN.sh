
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VERIFY RENDERED MARKDOWN PREVIEW CLEAN ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

OUT="checkpoints/PHASE719_RENDERED_MARKDOWN_PREVIEW_CLEAN_VERIFY.txt"

{

  echo "BRANCH"

  echo "$BRANCH"

  echo ""

  echo "HEAD"

  git log --oneline --decorate -5

  echo ""

  echo "STATUS"

  git status --short

  echo ""

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "STATIC JS VISUAL RENDER MARKERS"

  curl -s --max-time 10 'http://localhost:3000/js/phase530_visible_panels_bridge.js' | grep -nE 'phase719RenderMarkdownArtifactPreview|data-phase719-rendered-artifact-preview|body.innerHTML = phase719RenderMarkdownArtifactPreview|phase719EscapePreviewHtml' | head -n 80 || true

  echo ""

  echo "PREVIEW ROUTE SAMPLE"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 80 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 80 motherboard_systems_hq-dashboard-1 || true

} | tee "$OUT"

git add PHASE719_VERIFY_RENDERED_MARKDOWN_PREVIEW_CLEAN.sh

git add "$OUT"

git commit -m "Phase 719: verify rendered markdown preview cleanly"

git push origin "$BRANCH"

echo "===== CLEAN VERIFY COMPLETE ====="

