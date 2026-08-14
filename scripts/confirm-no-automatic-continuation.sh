#!/usr/bin/env bash
set -euo pipefail

echo "=== CONFIRM NO AUTOMATIC CONTINUATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 3a442995 HEAD

record="scripts/verify-program-reconciliation-terminal-state.sh"
test -f "$record"

grep -q 'PROGRAM_STATE=' "$record"
grep -q 'STABLE_TERMINAL_CHECKPOINT' "$record"
grep -q 'ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=' "$record"
grep -q '^NONE$' <(awk '/ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=/{getline; print}' "$record")
grep -q 'AUTOMATIC_CONTINUATION=' "$record"
grep -q '^NO$' <(awk '/AUTOMATIC_CONTINUATION=/{getline; print}' "$record")

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

VERIFIED_TERMINAL_STATE_COMMIT=
3a442995

FINAL_DR=
20260813_194322

PROGRAM_STATE=
STABLE_TERMINAL_CHECKPOINT

ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=
NONE

AUTOMATIC_CONTINUATION=
NO

NEW_RUNTIME_WORK_AUTHORIZED=
NO

CONTINUATION_REQUIREMENT=
NEW_EVIDENCE_OR_EXPLICIT_NEW_PROGRAM_OBJECTIVE

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
STOP
MAP
