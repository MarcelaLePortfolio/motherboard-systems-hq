
#!/usr/bin/env bash

set -euo pipefail

echo "=== Cade CI Enforcement Wrapper ==="

FAIL=0

echo ""

echo "Running switch integrity check..."

./scripts/verify-cade-execution-switch-integrity.sh || FAIL=1

echo ""

echo "Running runtime coherence check..."

./scripts/verify-cade-execution-runtime-coherence.sh || FAIL=1

echo ""

echo "Evaluating enforcement result..."

if [ "$FAIL" -ne 0 ]; then

  echo "❌ Cade Execution Integrity FAILED"

  echo "Build blocked: execution safety invariants violated"

  exit 1

fi

echo "✅ Cade Execution Integrity PASSED"

exit 0

