#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0c80bc4cf"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== EXECUTIVE INBOX FILTER ==="
grep -n -B 4 -A 10 \
  -E 'const approvedPackages|delegation\.state !== "delegated"' \
  client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== LIVE DELEGATION STATE ==="
curl -sS \
  "http://localhost:3000/api/canonical-packages?project_id=hq"

echo
echo
echo "EXPECTED_BROWSER_RESULT=DELEGATED_PACKAGE_ABSENT_FROM_EXECUTIVE_INBOX"
echo "UNDERLYING_CANONICAL_PACKAGE_REMAINS_PERSISTED=YES"
echo "UNDERLYING_DELEGATION_REMAINS_PERSISTED=YES"
echo "NEXT_ACTION=HARD_REFRESH_BROWSER_AND_CONFIRM_ITEM_IS_GONE"
