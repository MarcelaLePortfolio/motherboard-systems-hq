#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== operatorGuidanceMapping.ts ==="
sed -n '1,260p' src/cognition/operatorGuidanceMapping.ts

echo
echo "=== operatorGuidanceConfidence.ts ==="
sed -n '1,260p' src/cognition/operatorGuidanceConfidence.ts

echo
echo "=== operatorGuidance.ts ==="
sed -n '1,260p' src/cognition/operatorGuidance.ts

echo
echo "=== reducer status check ==="
sed -n '1,120p' src/cognition/operatorGuidanceReducer.ts
