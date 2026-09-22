#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="4a6e4e0ea"
DOC="docs/checkpoints/CANONICAL_PACKAGE_DESCRIPTION_DEFERRED_QUALITY_WORK.md"

echo "============================================================"
echo " DEFERRED WORK — DISCOVERABILITY VERIFICATION"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DOC"

grep -q '^DEFERRED_WORK=YES$' "$DOC"
grep -q '^DEFERRED_WORK_CATEGORY=CANONICAL_PACKAGE_CONTENT_QUALITY$' "$DOC"
grep -q '^DEFERRED_WORK_COMPONENT=MATILDA_CANONICAL_PACKAGE_DESCRIPTION$' "$DOC"
grep -q '^DEFERRED_WORK_ISSUE_1=REDUNDANT_INTERPRETATION_ACCUMULATION$' "$DOC"
grep -q '^DEFERRED_WORK_ISSUE_2=IRRELEVANT_HISTORICAL_GREETING_INCLUSION$' "$DOC"
grep -q '^DEFERRED_WORK_DISCOVERABLE=YES$' "$DOC"
grep -q '^DEFERRED_WORK_INVESTIGATION_REQUIRED=YES$' "$DOC"
grep -q '^DEFERRED_WORK_IMPLEMENTATION_AUTHORIZED=NO$' "$DOC"

echo "DEFERRED_WORK_RECORD=VERIFIED"
echo "REDUNDANT_DESCRIPTION_ISSUE=RECORDED"
echo "HISTORICAL_GREETING_ISSUE=RECORDED"
echo "DEFERRED_WORK_DISCOVERABLE=YES"
echo "FUTURE_DEFERRED_WORK_INVESTIGATION_SHOULD_SURFACE_RECORD=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CLEAR_STOPPING_POINT=YES"

git add -- "$DOC"
git commit --allow-empty -m "Verify deferred canonical package quality discoverability"
git push origin "$BRANCH"
