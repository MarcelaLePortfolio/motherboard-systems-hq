#!/usr/bin/env bash
set -euo pipefail

echo "Searching for Health status UI surfaces..."

grep -RInE "Health|health|Critical|Degraded|status" app components 2>/dev/null || true

git add PHASE702_STEP4_KPI_CLARITY.sh PHASE702_STEP5_FIND_HEALTH_STATUS.sh
git commit -m "Phase 702: locate health status UI surfaces"
git push

git status --short
