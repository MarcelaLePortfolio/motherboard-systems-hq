#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="988f7ecb8"
CAPTURE="/tmp/executive-delegation-behavioral-test-result.txt"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "============================================================"
echo " EXECUTIVE DELEGATION — BEHAVIORAL RUN STOP DIAGNOSIS"
echo "============================================================"

echo
echo "=== CAPTURE STATE ==="
if [ -f "$CAPTURE" ]; then
  echo "CAPTURE_FILE_PRESENT=YES"
  echo "CAPTURE_FILE_SIZE=$(wc -c < "$CAPTURE" | tr -d ' ')"
  cat "$CAPTURE"
else
  echo "CAPTURE_FILE_PRESENT=NO"
fi

echo
echo "=== FOCUSED TEST FILE STATE ==="
for file in \
  db/canonical-package-read-repository.delegation.test.ts \
  client/src/approvals/governanceDelegationApi.test.ts
do
  if [ -f "$file" ]; then
    echo "TEST_FILE_PRESENT=$file"
    git status --short -- "$file" || true
  else
    echo "TEST_FILE_MISSING=$file"
  fi
done

echo
echo "=== RESULT CHECKPOINT STATE ==="
DOC="docs/checkpoints/EXECUTIVE_DELEGATION_BEHAVIORAL_TEST_RESULT.md"
if [ -f "$DOC" ]; then
  echo "RESULT_CHECKPOINT_PRESENT=YES"
  sed -n '1,260p' "$DOC"
else
  echo "RESULT_CHECKPOINT_PRESENT=NO"
fi

echo
echo "=== RELEVANT PATH STATUS ONLY ==="
git status --short -- \
  db/canonical-package-read-repository.delegation.test.ts \
  client/src/approvals/governanceDelegationApi.test.ts \
  "$DOC" \
  implement-executive-delegation-focused-behavioral-tests.sh \
  run-executive-delegation-focused-behavioral-tests.sh \
  inspect-executive-delegation-behavioral-test-result.sh \
  print-executive-delegation-behavioral-test-result.sh \
  persist-executive-delegation-behavioral-result.sh \
  run-persisted-executive-delegation-behavioral-result.sh \
  || true

echo
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "BEHAVIORAL_CERTIFICATION_COMPLETE=NO"
echo "CORRIDOR_STATUS=OPEN"
echo "NEXT_ACTION=CLASSIFY_CAPTURE_AND_TEST_FILE_STATE_BEFORE_ANY_RETRY"
echo "CLEAR_STOPPING_POINT=YES"
