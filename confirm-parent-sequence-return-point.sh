#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="f99b310c9"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

test -f docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md
test -f docs/checkpoints/CANONICAL_PACKAGE_DESCRIPTION_DEFERRED_QUALITY_WORK.md

grep -q '^CORRIDOR_STATUS=CLOSED$' \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md

grep -q '^DEFERRED_CONTENT_QUALITY_WORK_DISCOVERABLE=YES$' \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md

echo "============================================================"
echo " PARENT DEVELOPMENT SEQUENCE — RETURN POINT"
echo "============================================================"
echo "CANONICAL_VISIBILITY_RESTORATION=CLOSED"
echo "RESTORATION_STATUS=VALIDATED"
echo "DEFERRED_QUALITY_WORK=RECORDED_AND_DISCOVERABLE"
echo "CURRENT_HEAD=$(git rev-parse --short=9 HEAD)"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=IDENTIFY_PARENT_DEVELOPMENT_SEQUENCE_RESUMPTION_POINT"
echo "CLEAR_STOPPING_POINT=YES"
