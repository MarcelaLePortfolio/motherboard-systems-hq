#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="44bc598300682180dd1bf58863dd5871530275cd"
CHECKPOINT="docs/approvals-executive-inbox-runtime-corridor-final-checkpoint.md"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
test -f "$CHECKPOINT"

grep -q '^CLOSED$' "$CHECKPOINT"
grep -q 'Approvals Executive Inbox runtime corridor: CLOSED' "$CHECKPOINT"
grep -q 'Persistent runtime validation: PASS' "$CHECKPOINT"
grep -q 'Approvals product fix required: NO' "$CHECKPOINT"
grep -q 'Atlas corridor reopened: NO' "$CHECKPOINT"

printf '\n=== FINAL APPROVALS CORRIDOR STATUS ===\n'
echo "HEAD=$EXPECTED_HEAD"
echo "LOCAL_REMOTE_CONVERGENCE=YES"
echo "APPROVALS_EXECUTIVE_INBOX_RUNTIME_CORRIDOR=CLOSED"
echo "PERSISTENT_RUNTIME_VALIDATION=PASS"
echo "APPROVALS_PRODUCT_FIX_REQUIRED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "FINAL_STOPPING_POINT=YES"
echo "NO_FURTHER_ACTION_REQUIRED_IN_THIS_CORRIDOR=YES"
