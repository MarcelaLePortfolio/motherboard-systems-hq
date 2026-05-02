#!/bin/bash
set -euo pipefail

PHASE_TAG="phase618-ui-communication-tier-surfacing-complete"
SNAPSHOT_DIR="_snapshots/phase618-ui-communication-tier-surfacing-complete-$(date +%Y%m%d_%H%M%S)"

echo "🔍 Checking git status..."
git status --short

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
echo "🏷️ Creating git tag: ${PHASE_TAG}"
git tag -a "${PHASE_TAG}" -m "Phase 618 UI communication tier surfacing complete" || echo "Tag already exists."

echo ""
echo "📤 Pushing branch and tag..."
git push
git push origin "${PHASE_TAG}" || true

echo ""
echo "🐳 Rebuilding and starting containers..."
docker compose up -d --build

echo ""
echo "🩺 Container status..."
docker compose ps

echo ""
echo "✅ Phase 618 checkpoint complete."
