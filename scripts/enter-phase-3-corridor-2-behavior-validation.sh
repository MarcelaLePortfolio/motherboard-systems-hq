#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — BEHAVIOR VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor a2410ab2 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/enter-phase-3-corridor-2-behavior-validation\.sh$|^ M scripts/enter-phase-3-corridor-2-behavior-validation\.sh$' ||
  true
)"
test -z "$unexpected"

echo "PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR"
echo "CORRIDOR_1=CLASSIFICATION_RULE"
echo "CORRIDOR_1_STATUS=DR_PROTECTED_CLOSED"
echo "CORRIDOR_1_DR=20260817_144648"
echo "CORRIDOR_2=BEHAVIOR_VALIDATION"
echo "CORRIDOR_2_STATUS=ACTIVE"
echo "VALIDATION_TARGET=OPTIONAL_DEFAULT_AND_RECOMMENDED_ONLY_AT_MATERIAL_DECISION_IMPACT_THRESHOLD"
echo "VALIDATE_OPTIONAL_CASES=YES"
echo "VALIDATE_RECOMMENDED_CASES=YES"
echo "VALIDATE_FALSE_POSITIVE_RECOMMENDED_CASES=YES"
echo "PRODUCTION_CHANGE_AUTHORIZED=NO"
echo "DR_NOW=NO"
echo "NEXT_ACTION=INSPECT_EXISTING_LIVE_AND_FIXED_SEED_VALIDATION_SURFACES"
