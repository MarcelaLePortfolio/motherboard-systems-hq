#!/usr/bin/env bash
set -euo pipefail

echo "Committing validation helper scripts..."

git add PHASE702_STEP5D_VALIDATE_STATUS_REASONING.sh PHASE702_STEP5E_SAFE_VALIDATE.sh
git commit -m "Phase 702: add safe validation helpers"
git push

echo
echo "Running available verification script..."

npm run verify:replay

git status --short
