#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
CURRENT_HEAD="0f92f776f"
REVERT_SCRIPT="scripts/execute-authorized-package-semantics-grounding-revert.sh"

echo "=== AUTHORIZED REVERT PREFLIGHT DIAGNOSIS ==="
echo "AUTHORIZATION_PRESENT=YES"
echo "REVERT_EXECUTED=NO"
echo "SOURCE_MUTATION_EXPECTED=NO"

echo
echo "BRANCH_ACTUAL=$(git rev-parse --abbrev-ref HEAD)"
echo "BRANCH_EXPECTED=$BRANCH"
echo "HEAD_ACTUAL=$(git rev-parse --short=9 HEAD)"
echo "CURRENT_EXPECTED_HEAD=$CURRENT_HEAD"

git fetch origin "$BRANCH"

echo "LOCAL_HEAD=$(git rev-parse HEAD)"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"

echo
echo "=== EMBEDDED PREFLIGHT BINDING ==="
grep -nE 'EXPECTED_HEAD|git rev-parse --short=9 HEAD|AUTHORIZED TARGETED REVERT' "$REVERT_SCRIPT"

echo
echo "=== TARGET SOURCE MUTATION CHECK ==="
git diff -- \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts \
  scripts/utils/ollamaChat.package-semantics-current-request-grounding.test.ts

echo
echo "=== PREFLIGHT TRACE ==="
bash -x "$REVERT_SCRIPT" </dev/null 2>&1 || true

echo
echo "=== CLASSIFICATION ==="
echo "AUTHORIZED_REVERT_RETRY_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=REMOVE_SELF_INVALIDATING_HEAD_PIN_IF_CONFIRMED"
