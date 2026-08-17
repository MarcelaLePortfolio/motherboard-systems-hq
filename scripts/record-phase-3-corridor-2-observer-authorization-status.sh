#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — OBSERVER AUTHORIZATION STATUS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 0dd827d7 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/record-phase-3-corridor-2-observer-authorization-status\.sh$|^ M scripts/record-phase-3-corridor-2-observer-authorization-status\.sh$' ||
  true
)"
test -z "$unexpected"

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_2=BEHAVIOR_VALIDATION
STATUS=ACTIVE
CURRENT_GATE=EXPLICIT_USER_IMPLEMENTATION_AUTHORIZATION_REQUIRED
DIAGNOSTIC_OBSERVER_SURFACE=CLASSIFIED
IMPLEMENTATION_READINESS=READY
IMPLEMENTATION_AUTHORIZED=NO
THIRD_BEHAVIOR_VALIDATION_ATTEMPT=NOT_AUTHORIZED
PRODUCTION_SEMANTIC_CHANGE=NONE
FAIL_CLOSED_VALIDATION_CHANGE=NONE
DR_NOW=NO
NEXT_ACTION=WAIT_FOR_EXPLICIT_USER_AUTHORIZATION_BEFORE_IMPLEMENTING_VALIDATION_ONLY_OBSERVER
MAP
