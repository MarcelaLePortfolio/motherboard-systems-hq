#!/usr/bin/env bash
set -euo pipefail

echo "=== CONFIRM CORRIDOR 2 AWAITING DR ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 93776ed8 HEAD
test -z "$(git status --porcelain)"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION
CORRIDOR_2=
PRODUCTION_FAILURE_BASELINE
CORRIDOR_2_STATUS=
CLOSED_PENDING_DR_CHECKPOINT
DR_REQUIRED=
YES
NEXT_CORRIDOR_ENTRY_AUTHORIZED=
NO
NEXT_ACTION=
RUN_DR
MAP
