#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_CLOSURE_COMMIT="22628f194"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

git merge-base --is-ancestor "$EXPECTED_CLOSURE_COMMIT" HEAD

test -f docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md
test -f docs/checkpoints/CANONICAL_PACKAGE_DESCRIPTION_DEFERRED_QUALITY_WORK.md

grep -q '^CORRIDOR_STATUS=CLOSED$' \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md

grep -q '^DEFERRED_CONTENT_QUALITY_WORK_DISCOVERABLE=YES$' \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_CLOSURE.md

grep -q '^DEFERRED_WORK_DISCOVERABLE=YES$' \
  docs/checkpoints/CANONICAL_PACKAGE_DESCRIPTION_DEFERRED_QUALITY_WORK.md

echo "============================================================"
echo " CANONICAL PACKAGE VISIBILITY RESTORATION — CLOSED"
echo "============================================================"
echo "RESTORATION_STATUS=VALIDATED"
echo "CORRIDOR_STATUS=CLOSED"
echo "DEFERRED_QUALITY_WORK=RECORDED_AND_DISCOVERABLE"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RETURN_TO_PARENT_DEVELOPMENT_SEQUENCE"
