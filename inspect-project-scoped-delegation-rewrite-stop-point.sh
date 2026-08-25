#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT PROJECT-SCOPED DELEGATION REWRITE STOP POINT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY REWRITE HARNESS COMMIT ==="
git show --stat --oneline --decorate daab4c5b
git show --format= -- implement-project-scoped-delegation-reference.sh daab4c5b | sed -n '1,320p'

echo
echo "=== CURRENT IMPLEMENTATION HARNESS TARGET BLOCK ==="
grep -n -A220 -B12 \
  -E 'path = Path\("db/governance-runtime.ts"\)|replacements = \[|requiredDelegationTextFields|const canonicalPackage = sqlite.prepare|INSERT INTO governance_delegations' \
  implement-project-scoped-delegation-reference.sh | head -520

echo
echo "=== CURRENT WORKTREE ==="
git status --short

echo
echo "=== CLASSIFICATION ==="
echo "REWRITE_HARNESS_COMMIT=daab4c5b"
echo "REWRITE_HARNESS_PUSHED=YES"
echo "REPAIRED_IMPLEMENTATION_HARNESS_COMMIT=NOT_YET_ESTABLISHED_FROM_PROVIDED_OUTPUT"
echo "AUTHORIZED_IMPLEMENTATION_RERUN_RESULT=NOT_YET_ESTABLISHED_FROM_PROVIDED_OUTPUT"
echo "PRODUCTION_CHANGE=NONE_CONFIRMED_BY_AVAILABLE_OUTPUT"
echo "NEXT_ACTION=CONFIRM_EXACT_STOP_POINT_BEFORE_ANY_FURTHER_IMPLEMENTATION_ATTEMPT"
