#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d79d6041a"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

bash inspect-executive-delegation-implementation-surface.sh | tee /tmp/executive-delegation-surface-inspection.txt

echo
echo "=== INSPECTION COMPLETE ==="
echo "OUTPUT=/tmp/executive-delegation-surface-inspection.txt"
