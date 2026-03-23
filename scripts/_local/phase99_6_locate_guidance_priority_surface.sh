#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

rm -f scripts/_local/phase99_6_apply_guidance_confidence_weight.py

echo "=== operatorGuidanceReducer.ts ==="
sed -n '1,260p' src/cognition/operatorGuidanceReducer.ts

echo
echo "=== priority matches in cognition ==="
grep -RIn --exclude='*.map' --exclude-dir='confidence' -E 'priority|severity|rank|score' src/cognition || true
