#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="deaaf9c36"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== SERVER CANDIDATES ==="
find server db -type f \
  \( -iname '*canonical*package*' -o -iname '*delegation*' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -print | sort

echo
echo "=== CANONICAL PACKAGE ROUTE REFERENCES ==="
grep -Rnil \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "canonical-packages|matilda_canonical_packages" \
  server db || true

echo
echo "=== DELEGATION REFERENCES ==="
grep -Rnil \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E "governance_delegations|createGovernanceDelegationRouter" \
  server db || true
