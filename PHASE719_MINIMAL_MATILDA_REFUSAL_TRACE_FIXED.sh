
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 MINIMAL MATILDA REFUSAL TRACE (FIXED) ====="

echo ""

echo "[1] Core refusal anchors from runtime files only"

grep -nE "non-authoritative|cannot assist|executionBoundary|cannot execute|read-only" server.js server.mjs 2>/dev/null || true

echo ""

echo "[2] Advisory instruction anchors"

grep -nE "For status questions|limited, read-only|compact context" server.js server.mjs 2>/dev/null || true

echo ""

echo "[3] Runtime check"

curl -fsS http://localhost:3000 >/dev/null && echo "dashboard: PASS"

echo ""

echo "===== TRACE COMPLETE ====="

git add PHASE719_MINIMAL_MATILDA_REFUSAL_TRACE_FIXED.sh

git commit -m "Phase 719: fix minimal Matilda refusal trace"

git push origin dev

