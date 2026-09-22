#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="36da95efd"
OUTPUT="/tmp/executive-delegation-behavioral-test-result.txt"
DOC="docs/checkpoints/EXECUTIVE_DELEGATION_BEHAVIORAL_TEST_RESULT.md"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

if [ ! -f "$OUTPUT" ]; then
  echo "BEHAVIORAL_TEST_RESULT_CAPTURE_MISSING=YES"
  exit 1
fi

cat > "$DOC" << EOF2
# Executive Delegation Decision Adapter — Behavioral Test Result

Date: 2026-09-22

## Captured Result

\`\`\`text
$(cat "$OUTPUT")
\`\`\`

## Current Repository State

HEAD=$(git rev-parse --short=9 HEAD)

TARGET_TEST_SERVER=$(
  if [ -f db/canonical-package-read-repository.delegation.test.ts ]; then
    echo PRESENT
  else
    echo MISSING
  fi
)

TARGET_TEST_CLIENT=$(
  if [ -f client/src/approvals/governanceDelegationApi.test.ts ]; then
    echo PRESENT
  else
    echo MISSING
  fi
)

## Classification

RESULT_CAPTURED=YES
BEHAVIORAL_CERTIFICATION_STATUS=PENDING_REVIEW_OF_CAPTURED_RESULT
CORRIDOR_STATUS=OPEN
EOF2

cat "$DOC"

git diff --check -- "$DOC"
git add -- "$DOC"
git commit -m "Capture Executive Delegation behavioral test result"
git push origin "$BRANCH"
