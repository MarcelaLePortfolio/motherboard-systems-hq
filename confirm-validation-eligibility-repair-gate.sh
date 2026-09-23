#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="fa800393f"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== AUTHORIZATION STATUS ===\n'
echo "VALIDATION_ELIGIBILITY_REPAIR=READY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "NEXT_REQUIRED_USER_REPLY=I authorize the bounded Validation eligibility repair."

printf '\n=== SCOPE REMAINS LOCKED ===\n'
echo "SERVER_SIDE_ELIGIBILITY_REPAIR_ONLY=YES"
echo "OPERATOR_TRIGGER_UI=EXCLUDED"
echo "LIVE_GOVERNANCE_DATA_MUTATION=EXCLUDED"
echo "LEGACY_RUNTIME_REVIVAL=PROHIBITED"
echo "LIFECYCLE_AUTO_ADVANCE=PROHIBITED"
echo "EXECUTION_AUTHORITY=EXCLUDED"
echo "NEW_AUTHORITY=PROHIBITED"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short
