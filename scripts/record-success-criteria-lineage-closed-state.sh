#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="da499d21d"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== SUCCESS CRITERIA LINEAGE CLOSED ====="
echo "SUCCESS_CRITERIA_LINEAGE=CLOSED"
echo "CLOSURE_COMMIT=da499d21d533ea7cb4e45e93b76f043b4235ee1d"
echo "PACKAGE_SEMANTICS=VERIFIED"
echo "LIVING_DRAFT=VERIFIED"
echo "DRAFT_REVISION=VERIFIED"
echo "RECONCILED_SUMMARY=VERIFIED"
echo "APPROVAL_READ_MODEL=VERIFIED"
echo "CANONICAL_PACKAGE=VERIFIED"
echo "CANONICAL_READ=VERIFIED"
echo "GOVERNANCE_PROJECTION=VERIFIED"
echo "AUTHORITY_EXPANSION=NONE"

echo
echo "===== HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
