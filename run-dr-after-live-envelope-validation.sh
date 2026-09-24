#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="276196539"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "DR_BASELINE_BRANCH=$BRANCH"
echo "DR_BASELINE_HEAD=$(git rev-parse HEAD)"
echo "DR_CAPTURED_AT=$STAMP"
echo "DIRTY_WORKTREE_PRESERVATION_REQUIRED=YES"
echo "DO_NOT_CLEAN=YES"
echo "DO_NOT_STASH=YES"
echo "DO_NOT_RESET=YES"
echo "DO_NOT_DELETE=YES"

echo
echo "READY_FOR_EXISTING_DR_PROCEDURE=YES"
