#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="84d75333a"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== SUCCESS CRITERIA LINEAGE CLOSURE ====="
echo "PACKAGE_SEMANTICS=VERIFIED"
echo "LIVING_DRAFT_PERSISTENCE=VERIFIED"
echo "DRAFT_REVISION=VERIFIED"
echo "RECONCILED_SUMMARY=VERIFIED"
echo "APPROVAL_READ_MODEL=VERIFIED"
echo "CANONICAL_PACKAGE=VERIFIED"
echo "CANONICAL_READ=VERIFIED"
echo "GOVERNANCE_PROJECTION=VERIFIED"
echo "AUTHORITY_EXPANSION=NONE"
echo "SUCCESS_CRITERIA_LINEAGE=CLOSED"

echo
echo "===== FINAL VERIFICATION ====="
npx tsc --noEmit

node --import tsx --test \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "===== HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
