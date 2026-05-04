#!/usr/bin/env bash
set -euo pipefail

echo "Reverting Phase 667 runtime changes back to validated Phase 666 stable route..."
git checkout phase666-complete -- server/routes/operator-guidance.mjs phase666_validate_guidance.sh

if [ -f server/lib/guidance-priority.js ]; then
  rm server/lib/guidance-priority.js
fi

echo "Rebuild and validate after commit:"
echo "  docker compose up -d --build"
echo "  ./phase666_validate_guidance.sh"
