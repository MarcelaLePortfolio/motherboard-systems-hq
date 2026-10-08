#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

echo "=== IMPLEMENTATION PREFLIGHT DIAGNOSIS ==="
echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"
echo "EXPECTED_BASELINE_IN_IMPLEMENTATION_SCRIPT=db054b0e5"
echo "PREPARATION_COMMIT=f06302792"

if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
  echo "REMOTE_CONVERGENCE=PASS"
else
  echo "REMOTE_CONVERGENCE=FAIL"
  exit 1
fi

if [ "$(git rev-parse --short=9 HEAD)" = "db054b0e5" ]; then
  echo "STATIC_BASELINE_CHECK=PASS"
else
  echo "STATIC_BASELINE_CHECK=STALE_AFTER_PREPARATION_COMMIT"
fi

echo
echo "=== WORKTREE ==="
git status --short

echo
echo "=== IMPLEMENTATION ARTIFACTS ==="
for file in \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts
do
  if [ -e "$file" ]; then
    echo "EXISTS=$file"
  else
    echo "ABSENT=$file"
  fi
done

echo
echo "=== WORKFLOW MODIFICATION ==="
git diff -- server/matilda-chat-workflow.ts

echo
echo "=== DETERMINATION ==="
echo "IMPLEMENTATION_SCRIPT_BLOCKED_BY_STALE_HEAD=YES"
echo "IMPLEMENTATION_VALIDATION_EXECUTED=NO"
echo "DOGFOOD_EXECUTED=NO"
echo "SOURCE_REPAIR_REQUIRED=UPDATE_PREFLIGHT_ONLY"
echo "NEXT_ACTION=REPAIR_SCRIPT_PREFLIGHT_BEFORE_RETRY"
