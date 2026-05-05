#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 702 Resume Check ==="
echo

echo "Branch + status:"
git status --short
echo

echo "Recent commits:"
git log --oneline -n 5
echo

echo "Key Phase 702 artifacts:"
ls -1 docs | grep phase702 || true
echo

echo "Demo UI label check:"
grep -n "DEMO_RUNTIME_NOTICE" app/demo-runtime/page.tsx || echo "Label not found"
echo

echo "=== Resume point: UI Trust & Clarity Refinement ==="
