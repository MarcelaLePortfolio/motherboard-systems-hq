#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 — RESUME BOUNDED CLOSURE CANONICAL DR ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor fd60f5f3 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/resume-phase-3-bounded-closure-canonical-dr\.sh$|^ M scripts/resume-phase-3-bounded-closure-canonical-dr\.sh$' ||
  true
)"
test -z "$unexpected"

echo "PHASE_3_STATUS=CLOSED_BOUNDED"
echo "PHASE_3_CLOSURE_COMMIT=fd60f5f3"
echo "CORRIDOR_2_BEHAVIORAL_RELIABILITY_LIMIT=CARRIED_FORWARD"
echo "ACTION=RERUN_CANONICAL_DR_ONLY"

./scripts/dr-launcher.sh

echo "CANONICAL_DR=COMPLETE"
echo "NEXT_ACTION=RECORD_PHASE_3_DR_PROTECTION_AND_RECONCILE_SUCCESSOR_SCOPE"
