#!/bin/bash
set -euo pipefail

echo "🔍 Checking Phase 619 audit output..."

if [ -f PHASE619_EXECUTION_GUIDANCE_CANDIDATES.txt ]; then
  echo "✅ Audit report exists:"
  ls -lh PHASE619_EXECUTION_GUIDANCE_CANDIDATES.txt
  echo ""
  echo "=== Report tail ==="
  tail -n 40 PHASE619_EXECUTION_GUIDANCE_CANDIDATES.txt
else
  echo "❌ Audit report not found."
fi

echo ""
echo "=== Git status ==="
git status --short
