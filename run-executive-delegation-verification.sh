#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e009f6f34"
OUTPUT="/tmp/executive-delegation-verification.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

bash verify-executive-delegation-decision-adapter.sh > "$OUTPUT" 2>&1

cat "$OUTPUT"

echo
echo "=== VERIFICATION COMPLETE ==="
echo "OUTPUT=$OUTPUT"
