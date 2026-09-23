#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="2c702c7b0"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== SUCCESS CRITERIA CLOSURE CHECKPOINT VERIFIED ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== CLOSURE RECORD ====="
grep -E \
  'SUCCESS_CRITERIA_LINEAGE|PACKAGE_SEMANTICS|LIVING_DRAFT|DRAFT_REVISION|RECONCILED_SUMMARY|APPROVAL_READ_MODEL|CANONICAL_PACKAGE|CANONICAL_READ|GOVERNANCE_PROJECTION|AUTHORITY_EXPANSION' \
  scripts/record-success-criteria-lineage-closed-state.sh

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
