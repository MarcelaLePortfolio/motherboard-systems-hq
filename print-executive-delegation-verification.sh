#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5d50f41cc"
OUTPUT="/tmp/executive-delegation-verification.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFICATION FILE STATUS ==="
ls -lh "$OUTPUT" || true

echo
echo "=== VERIFICATION FILE CONTENT ==="
if [ -f "$OUTPUT" ]; then
  cat "$OUTPUT"
else
  echo "VERIFICATION_OUTPUT_MISSING=YES"
fi
