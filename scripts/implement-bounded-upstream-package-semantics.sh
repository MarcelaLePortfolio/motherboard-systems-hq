#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="d7380e1bb"
TARGET="scripts/utils/ollamaChat.ts"

echo "=== AUTHORIZATION AND BASELINE ==="
test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET")"

echo "IMPLEMENTATION=AUTHORIZED"
echo "TARGETED_TESTS=AUTHORIZED"
echo "LIVE_DOGFOOD=PROHIBITED"

echo
echo "=== VERIFY EXACT UPSTREAM INSERTION POINT ==="

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

anchor = """    const result =
      parseStructuredResponse(rawResponse);

    if (
      context.requirePackageSemantics === true"""

if source.count(anchor) != 1:
    raise SystemExit(
        "STOP: upstream validation anchor differs from reviewed baseline"
    )

print("UPSTREAM_INSERTION_POINT=VERIFIED")
print("SOURCE_MODIFICATION=NOT_YET_PERFORMED")
PY

echo
echo "=== VERIFY EXISTING FIDELITY TESTS ==="

npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo
echo "=== VERIFY TYPES ==="
npx tsc --noEmit

echo
echo "=== CHECKPOINT ==="
echo "BASELINE=$BASELINE"
echo "INSERTION_POINT=VERIFIED"
echo "EXISTING_FIDELITY_TESTS=PASS"
echo "TYPECHECK=PASS"
echo "FUNCTIONAL_SOURCE_MODIFIED=NO"
echo "LIVE_DOGFOOD=NO"
echo "NEXT_ACTION=IMPLEMENT_BOUNDED_RECONCILIATION_WITH_RUNTIME_REGRESSION_TESTS"
