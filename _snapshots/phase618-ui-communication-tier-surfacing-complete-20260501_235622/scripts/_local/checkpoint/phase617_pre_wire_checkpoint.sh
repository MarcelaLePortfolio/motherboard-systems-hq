#!/bin/bash
set -euo pipefail

PHASE_TAG="phase617-pre-result-surfacing-wire-stable"
SNAPSHOT_DIR="_snapshots/phase617-pre-result-surfacing-wire-stable-$(date +%Y%m%d_%H%M%S)"

echo "🔍 Checking git status..."
git status --short

if [ -n "$(git status --short)" ]; then
  echo "❌ Working tree is not clean. Commit or revert changes before checkpointing."
  exit 1
fi

echo ""
echo "🏷️ Creating git tag: ${PHASE_TAG}"
git tag -a "${PHASE_TAG}" -m "Phase 617 pre-wire stable checkpoint" || echo "Tag already exists."

echo ""
echo "📤 Pushing branch and tags..."
git push
git push origin "${PHASE_TAG}" || true

echo ""
echo "📦 Creating filesystem snapshot: ${SNAPSHOT_DIR}"
mkdir -p "${SNAPSHOT_DIR}"
rsync -a \
  --exclude node_modules \
  --exclude .git \
  --exclude .next \
  --exclude _snapshots \
  ./ "${SNAPSHOT_DIR}/"

echo ""
echo "🐳 Rebuilding and starting containers..."
docker compose up -d --build

echo ""
echo "🩺 Container status..."
docker compose ps

echo ""
echo "✅ Phase 617 pre-wire checkpoint complete."
