#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="17a33bbb8"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "PAUSE_CHECKPOINT_CONFIRMED=YES"
echo "LOCAL_REMOTE_CONVERGED=YES"
echo "CURRENT_HEAD=$(git rev-parse --short=9 HEAD)"
echo "GROUNDING_FUNCTIONAL_COMMIT_COMPLETE=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"
echo "ATTEMPT_3_STARTED=NO"
echo "RESUME_BOUNDARY=RECONCILE_ABANDONED_EMPTY_HISTORY_SCHEMA_BOUNDING_TEST"
