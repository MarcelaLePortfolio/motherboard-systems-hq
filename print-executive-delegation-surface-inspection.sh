#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="026cf9f4d"
OUTPUT="/tmp/executive-delegation-surface-inspection.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== CAPTURE FILE STATUS ==="
ls -lh "$OUTPUT" || true

echo
echo "=== CAPTURE FILE CONTENT ==="
if [ -f "$OUTPUT" ]; then
  sed -n '1,1200p' "$OUTPUT"
else
  echo "CAPTURE_FILE_MISSING=YES"
fi
