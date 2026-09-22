#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1d0b6a4d0"
OUTPUT="/tmp/executive-delegation-behavioral-test-result.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== CAPTURE FILE ==="
if [ -f "$OUTPUT" ]; then
  cat "$OUTPUT"
else
  echo "CAPTURE_FILE_MISSING=YES"
fi

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
echo "=== CURRENT HEAD ==="
git rev-parse --short=9 HEAD

echo
echo "=== WORKTREE STATUS ==="
git status --short
