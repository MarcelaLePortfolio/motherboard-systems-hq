#!/usr/bin/env bash
set -euo pipefail

echo "Committing resume helper scripts..."

git add PHASE702_FINALIZE_STOP.sh PHASE702_RESUME_CHECK.sh
git commit -m "Phase 702: add resume + finalize helpers"
git push

echo "Searching for ambiguous KPI placeholders..."

grep -RIn "\"--\"\\|'--'" app components 2>/dev/null || echo "No KPI placeholders found"

git status --short
