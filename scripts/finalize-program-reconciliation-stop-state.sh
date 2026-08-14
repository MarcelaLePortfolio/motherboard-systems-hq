#!/usr/bin/env bash
set -euo pipefail

echo "=== FINALIZE PROGRAM RECONCILIATION STOP STATE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 773da1f9 HEAD

record="scripts/confirm-no-automatic-continuation.sh"
test -f "$record"

grep -q 'PROGRAM_STATE=' "$record"
grep -q 'STABLE_TERMINAL_CHECKPOINT' "$record"
grep -q 'ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=' "$record"
grep -q '^NONE$' <(awk '/ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=/{getline; print}' "$record")
grep -q 'AUTOMATIC_CONTINUATION=' "$record"
grep -q '^NO$' <(awk '/AUTOMATIC_CONTINUATION=/{getline; print}' "$record")
grep -q 'NEXT_ACTION=' "$record"
grep -q '^STOP$' <(awk '/NEXT_ACTION=/{getline; print}' "$record")

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

FINAL_VERIFIED_COMMIT=
773da1f9

FINAL_DR=
20260813_194322

PROGRAM_RECONCILIATION_MILESTONE=
CLOSED_AND_DR_PROTECTED

PROGRAM_STATE=
STABLE_TERMINAL_CHECKPOINT

ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=
NONE

AUTOMATIC_CONTINUATION=
NO

NEW_RUNTIME_WORK_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

CONTINUATION_BOUNDARY=
NEW_EVIDENCE_OR_EXPLICIT_NEW_PROGRAM_OBJECTIVE_REQUIRED

FINAL_ACTION=
STOP
MAP
