#!/usr/bin/env bash
set -euo pipefail

echo "=== INSPECT PROMPT DIAGNOSTIC RUNNER CURRENT SHAPE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 762143a6 HEAD

runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"

test -f "$runner"

echo "=== CURRENT WORKTREE ==="
git status --short

echo "=== RUNNER RELEVANT REGION ==="
nl -ba "$runner" | sed -n '90,150p'

echo "=== AWAIT LOCATIONS ==="
grep -n 'await run' "$runner" || true

echo "=== MAIN WRAPPER MARKERS ==="
grep -n 'async function main\|void main' "$runner" || true

cat <<'MAP'
OBSERVED_FAILURE=
EXPECTED_TEXT_REPLACEMENT_DID_NOT_MATCH_CURRENT_UNCOMMITTED_RUNNER_SHAPE

FAILED_REPAIR_HYPOTHESIS_COUNT=
2

PRODUCTION_CHANGE=
NONE

ROLLBACK_REQUIRED=
NO

NEXT_ACTION=
PATCH_EXACT_CURRENT_RUNNER_SHAPE_FROM_THIS_OUTPUT
MAP
