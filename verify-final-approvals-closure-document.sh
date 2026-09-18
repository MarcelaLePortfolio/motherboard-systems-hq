#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="15b9fdf6100adfe7ec3a9b22692c5d33a5344863"
CLOSURE_DOC="docs/approvals-executive-inbox-runtime-corridor-closure.md"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$CLOSURE_DOC"
test -z "$(git diff --cached --name-only)"

grep -q '^CLOSED$' "$CLOSURE_DOC"
grep -q 'Executive Inbox runtime corridor: CLOSED' "$CLOSURE_DOC"
grep -q 'Approvals product fix required: NO' "$CLOSURE_DOC"
grep -q 'Atlas corridor reopened: NO' "$CLOSURE_DOC"

printf '\n=== FINAL VERIFIED STATE ===\n'
echo "HEAD=$EXPECTED_HEAD"
echo "APPROVALS_EXECUTIVE_INBOX_RUNTIME_CORRIDOR=CLOSED"
echo "APPROVALS_PRODUCT_FIX_REQUIRED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO_FURTHER_ACTION_REQUIRED=YES"
