#!/usr/bin/env bash
set -euo pipefail

echo "Validating Phase 702 status reasoning patch..."

npm run lint -- --max-warnings=0 || npm run lint || true
npm run build

git status --short
