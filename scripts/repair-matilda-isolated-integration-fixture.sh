#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="9aafe70c9"
TARGET="server/matilda-chat-workflow.explicit-target.integration.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" scripts/utils/ollamaChat.ts)"
test -f "$TARGET"

python3 - << 'PY'
from pathlib import Path

target = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
source = target.read_text()

old = '''              expectedOutcome:
                "Preserve the reviewed intent with the requested correction.",
              proposedWork:'''

new = '''              expectedOutcome:
                "Preserve the reviewed intent with the requested correction.",
              successCriteria: null,
              proposedWork:'''

if source.count(old) != 1:
    raise SystemExit(
        "FAIL_CLOSED: Expected exactly one known integration fixture."
    )

target.write_text(source.replace(old, new, 1))
PY

echo "=== VERIFY NARROW FIX ==="
git diff --check
git diff -- "$TARGET"

echo
echo "=== ISOLATED WORKFLOW INTEGRATION ==="
npx tsx --test "$TARGET"

echo
echo "=== WORKFLOW POLICY REGRESSION ==="
npx tsx --test \
  server/matilda-chat-workflow.package-semantics-policy.test.ts \
  server/matilda-concrete-operation-package-semantics.test.ts \
  server/matilda-current-request-package-semantics-fidelity.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== CLASSIFICATION ==="
echo "FIXTURE_CONTRACT=REPAIRED"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "RECONCILED_PERSISTENCE=NOT_YET_PROVEN"
echo "FAILED_RECONCILIATION_DURABILITY=NOT_YET_PROVEN"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
echo "CORRIDOR=OPEN"
