#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== ATTEMPT 3 CLASSIFICATION ===\n'
echo "ATTEMPT_3_EXECUTION_RESULT=TOOLING_ANCHOR_MISMATCH"
echo "IMPLEMENTATION_MUTATION_APPLIED=NO"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "THREE_FAILED_HYPOTHESIS_LIMIT_REACHED=NO"
echo "ATTEMPT_3_REMAINS_AUTHORIZED_WITHIN_ORIGINAL_SCOPE=YES"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"

printf '\n=== EXACT CURRENT WORKFLOW REQUIRE REGION ===\n'
grep -n -A20 -B8 \
  'matilda-chat-workflow' \
  "$TEST" || true

printf '\n=== RAW WHITESPACE / PUNCTUATION AROUND REQUIRE ===\n'
python3 - <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
lines = path.read_text().splitlines()

for i, line in enumerate(lines, start=1):
    if "matilda-chat-workflow" in line:
        start = max(1, i - 8)
        end = min(len(lines), i + 8)
        for n in range(start, end + 1):
            print(f"{n:04d}: {lines[n-1]!r}")
        print("---")
PY

printf '\n=== VERIFY TOP-LEVEL ATLAS IMPORTS STILL PRESENT ===\n'
grep -n -A12 -B2 \
  'readAtlasHistoricalObservations' \
  "$TEST" || true

printf '\n=== VERIFY ATTEMPT 2 IEL INITIALIZATION STILL PRESENT ===\n'
grep -n -A18 -B3 \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  "$TEST" || true

printf '\n=== VERIFY AUTHORIZED TEST DIFF ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "NEXT_ACTION=RETRY_ATTEMPT_3_WITH_EXACT_CURRENT_REQUIRE_SHAPE"
echo "NO_NEW_AUTHORIZATION_REQUIRED=YES"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
