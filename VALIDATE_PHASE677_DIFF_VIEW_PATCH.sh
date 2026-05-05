#!/bin/bash
set -e

echo "=== Available npm scripts ==="
npm run || true

echo ""
echo "=== TypeScript / build validation ==="
npm run build

echo ""
echo "=== Runtime container status ==="
docker compose ps

echo ""
echo "=== Current GuidancePanel diff markers ==="
grep -n "Raw vs Coherent Diff\|Collapsed signals\|Introduced coherent signals\|diffSummary" app/components/GuidancePanel.tsx

echo ""
echo "=== Git status ==="
git status --short
