#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e049bdb89"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== CANONICAL PACKAGE READ MODEL ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "CanonicalPackageReadModel|fetchCanonicalPackages|canonical-packages" \
  client server db | head -120 || true

echo
echo "=== APPROVAL / EXECUTIVE INBOX SURFACE ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "Canonical Package|canonical package|ApprovalRequestProvider|Executive Inbox|ApprovalsWorkspace" \
  client/src | head -160 || true

echo
echo "=== GOVERNANCE DELEGATION ROUTE + TYPES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "governance/delegation|delegation_id|authorization_state|createGovernanceDelegationRouter" \
  server db client/src | head -180 || true

echo
echo "=== RELEVANT FILE CONTENTS ==="
for f in \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx
do
  if [ -f "$f" ]; then
    echo
    echo "----- $f -----"
    sed -n '1,320p' "$f"
  fi
done

echo
echo "=== CANONICAL PACKAGE ROUTE / READ FILES ==="
find server db client/src -type f \
  \( -iname '*canonical*package*' -o -iname '*delegation*' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -print | sort

echo
echo "=== WORKTREE STATUS ==="
git status --short
