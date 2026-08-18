#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — RESUME CANONICAL DR ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 60e970dd HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/resume-phase-3-corridor-3-canonical-dr\.sh$|^ M scripts/resume-phase-3-corridor-3-canonical-dr\.sh$' ||
  true
)"
test -z "$unexpected"

echo "CORRIDOR_3_STATUS=CLOSED"
echo "CLOSURE_COMMIT=64fb2ef0"
echo "DR_BLOCK_RECORD_COMMIT=60e970dd"
echo "ACTION=RERUN_CANONICAL_DR_ONLY"

./scripts/dr-launcher.sh

echo "CANONICAL_DR=COMPLETE"
echo "NEXT_ACTION=RECORD_CORRIDOR_3_DR_PROTECTION_AND_ENTER_CORRIDOR_4"
