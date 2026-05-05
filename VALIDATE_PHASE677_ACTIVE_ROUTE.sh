#!/bin/bash
set -e

echo "=== Docker status ==="
docker compose ps

echo ""
echo "=== Validate coherence shadow route on active dashboard port ==="
curl -i -s http://localhost:3000/api/guidance/coherence-shadow | head -c 2000
printf '\n'

echo ""
echo "=== Confirm diff view markers ==="
grep -n "Raw vs Coherent Diff\|Collapsed signals\|Introduced coherent signals\|diffSummary" app/components/GuidancePanel.tsx
