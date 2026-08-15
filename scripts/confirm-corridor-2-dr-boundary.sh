#!/usr/bin/env bash
set -euo pipefail

echo "=== CONFIRM CORRIDOR 2 DR BOUNDARY ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor ca40149f HEAD
test -z "$(git status --porcelain)"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION
CORRIDOR_2=
PRODUCTION_FAILURE_BASELINE
CORRIDOR_2_STATUS=
CLOSED_PENDING_DR_CHECKPOINT
CORRIDOR_2_CLOSURE_COMMIT=
ca40149f
DR_REQUIRED_BEFORE_NEXT_CORRIDOR=
YES
NEXT_ACTION=
RUN_DR_AND_RETURN_CHECKPOINT
MAP
