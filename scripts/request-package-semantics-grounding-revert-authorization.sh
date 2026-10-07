#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== PACKAGE SEMANTICS GROUNDING REVERT GATE ==="
echo "GROUNDING_HYPOTHESIS_LIMIT_REACHED=YES"
echo "LIVE_RETRY_AUTHORIZED=NO"
echo "NEW_LAYERED_FIX_AUTHORIZED=NO"
echo
echo "TARGETED_REVERT:"
echo "  restore scripts/utils/ollamaChat.ts before Attempt 2/3 grounding additions"
echo "  remove Attempt 2 generation-grounding test"
echo "  remove Attempt 3 current-request-grounding test"
echo
echo "PRESERVE:"
echo "  authorized stale schema-bounding test deletion"
echo "  conditional conversation-support behavior"
echo "  unrelated worktree changes"
echo "  governance and authority boundaries"
echo "  historical commits/evidence"
echo
echo "REVERT_METHOD=TARGETED_CONTENT_RESTORATION"
echo "HISTORY_REWRITE=NO"
echo "FORCE_PUSH=NO"
echo "REVERT_EXECUTED=NO"
echo
echo "AUTHORIZATION_REQUIRED=YES"
echo "Reply exactly:"
echo "I authorize the targeted Package Semantics grounding revert."
