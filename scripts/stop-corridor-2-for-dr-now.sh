#!/usr/bin/env bash
set -euo pipefail

echo "=== STOP CORRIDOR 2 FOR DR NOW ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 95d9c3b5 HEAD
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
RUN_DR_NOW_AND_RETURN_CHECKPOINT
MAP
