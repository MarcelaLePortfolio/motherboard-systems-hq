#!/usr/bin/env bash
set -euo pipefail

echo "=== guidance engine exports/imports ==="
grep -R "export .*generateGuidance\|function generateGuidance\|export .*runGuidanceEngine\|function runGuidanceEngine" -n server/lib server/routes 2>/dev/null || true

echo
echo "=== active operator guidance route ==="
nl -ba server/routes/operator-guidance.mjs | sed -n '1,120p'

echo
echo "=== direct curl with timeout ==="
curl --max-time 5 -v http://localhost:3000/api/guidance || true

echo
echo "=== dashboard logs ==="
docker compose logs --tail=200 dashboard

echo
echo "=== git status ==="
git status --short
