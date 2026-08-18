#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — DR BLOCK CLASSIFICATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 64fb2ef0 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/record-phase-3-corridor-3-dr-blocked-by-external-drive\.sh$|^ M scripts/record-phase-3-corridor-3-dr-blocked-by-external-drive\.sh$' ||
  true
)"
test -z "$unexpected"

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_3=SURFACING_CONTRACT
CORRIDOR_3_STATUS=CLOSED
CLOSURE_COMMIT=64fb2ef0

CANONICAL_DR_ATTEMPTED=YES
DR_LAUNCHER_RESULT=BLOCKED
BLOCK_REASON=EXTERNAL_DRIVE_NOT_MOUNTED
DR_CREATED=NO

CORRIDOR_3_IMPLEMENTATION_VALIDATED=YES
CORRIDOR_3_CLOSURE_INVALIDATED_BY_DR_FAILURE=NO
CORRIDOR_2_BEHAVIORAL_RELIABILITY_LIMIT=PRESERVED

NEXT_ACTION=MOUNT_EXTERNAL_DRIVE_THEN_RERUN_CANONICAL_DR_LAUNCHER_ONLY
PRODUCTION_CHANGE=NONE
ADDITIONAL_CORRIDOR_3_IMPLEMENTATION=NONE
MAP
