#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1d464379d"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== CANONICAL PACKAGE SERVER READ PATH ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "canonical-packages|CanonicalPackageReadModel|matilda_canonical_packages" \
  server db | head -220 || true

echo
echo "=== GOVERNANCE DELEGATION READ / PERSISTENCE PATH ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "governance_delegations|authorization_state|delegation_id" \
  server db | head -260 || true

echo
echo "=== CANDIDATE SERVER FILES ==="
find server db -type f \
  \( -iname '*canonical*package*' -o -iname '*delegation*' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -print | sort

echo
echo "=== WORKTREE STATUS ==="
git status --short
