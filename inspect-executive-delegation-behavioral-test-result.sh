#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5e14d99e1"
OUTPUT="/tmp/executive-delegation-behavioral-test-result.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

set +e
bash implement-executive-delegation-focused-behavioral-tests.sh > "$OUTPUT" 2>&1
STATUS=$?
set -e

echo "=== BEHAVIORAL TEST SCRIPT EXIT STATUS ==="
echo "$STATUS"

echo
echo "=== BEHAVIORAL TEST OUTPUT ==="
cat "$OUTPUT"

echo
echo "=== CURRENT HEAD ==="
git rev-parse --short=9 HEAD

echo
echo "=== RECENT COMMITS ==="
git log -5 --oneline

echo
echo "=== TARGET TEST FILES ==="
for file in \
  db/canonical-package-read-repository.delegation.test.ts \
  client/src/approvals/governanceDelegationApi.test.ts
do
  if [ -f "$file" ]; then
    echo "PRESENT=$file"
  else
    echo "MISSING=$file"
  fi
done

echo
echo "=== WORKTREE STATUS ==="
git status --short

exit "$STATUS"
