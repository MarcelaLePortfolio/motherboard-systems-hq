#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_LOCAL_HEAD="d11cdf257"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4 — PUSH RECOVERY\n'
printf '============================================================\n'

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_LOCAL_HEAD"

echo "LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"

git fetch origin "$BRANCH"

REMOTE_HEAD="$(git rev-parse --short=9 "origin/$BRANCH")"
echo "REMOTE_HEAD=$REMOTE_HEAD"

test "$REMOTE_HEAD" != "$EXPECTED_LOCAL_HEAD"

printf '\n=== VERIFY COMMIT CONTENT ===\n'
git show --stat --oneline --decorate HEAD
git diff-tree --no-commit-id --name-only -r HEAD

printf '\n=== PUSH EXACT LOCAL HEAD ===\n'
git push origin "HEAD:$BRANCH"

git fetch origin "$BRANCH"

test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_LOCAL_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4 — RECOVERY COMPLETE\n'
printf '============================================================\n'
echo "POINT_4_HELPER_COMMIT_PUSHED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=REVIEW_POINT_4_INVESTIGATION_OUTPUT"
echo "CLEAR_STOPPING_POINT=YES"
