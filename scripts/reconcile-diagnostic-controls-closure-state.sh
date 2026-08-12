#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE DIAGNOSTIC CONTROLS CLOSURE STATE ==="

expected_head="51b78b0c"
closure_readiness_checkpoint="d67ab828"
required_dr="20260812_005014"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches observed Diagnostic Controls closure commit $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-diagnostic-controls-closure-state\.sh$|^ M scripts/reconcile-diagnostic-controls-closure-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

git merge-base --is-ancestor "$closure_readiness_checkpoint" HEAD || {
  echo "STOP: closure-readiness checkpoint is not an ancestor of current HEAD."
  exit 2
}

[[ "$(git log -1 --format=%s)" == "Close diagnostic controls corridor" ]] || {
  echo "STOP: current HEAD is not the expected Diagnostic Controls closure commit."
  exit 2
}

echo "=== VERIFY EXISTING CLOSURE ==="

git show --format= --name-only HEAD |
grep -qx 'scripts/close-diagnostic-controls-corridor.sh'

git show HEAD:scripts/close-diagnostic-controls-corridor.sh |
grep -q 'DIAGNOSTIC_CONTROLS_CORRIDOR='

git show HEAD:scripts/close-diagnostic-controls-corridor.sh |
grep -q 'CLOSED'

git show HEAD:scripts/close-diagnostic-controls-corridor.sh |
grep -q "$required_dr"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED
GENERATION_VARIANCE=
COMPLETE
FAILURE_CHARACTERIZATION=
COMPLETE
DIAGNOSTIC_CONTROLS=
COMPLETE
DIAGNOSTIC_CONTROLS_CLOSURE_COMMIT=
51b78b0c
DIAGNOSTIC_CONTROLS_DR=
20260812_005014
CLOSURE_RETRY_REQUIRED=
NO
DIAGNOSTIC_CONTROLS_CORRIDOR=
CLOSED
NEXT_CORRIDOR=
STABILITY_DETERMINATION
STABILITY_DETERMINATION=
ACTIVE
CORRIDOR_MAP_CHANGE=
NONE
IMPLEMENTATION_AUTHORIZED=
NO
PRODUCTION_CHANGE=
NONE
NEXT_ACTION=
BEGIN_STABILITY_DETERMINATION_WITHOUT_CLOSING_IT
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-diagnostic-controls-closure-state\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
