#!/usr/bin/env bash
set -euo pipefail

echo "=== CONFIRM FINAL PROGRAM STOP ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 8653da4e HEAD

record="scripts/finalize-program-reconciliation-stop-state.sh"
test -f "$record"

grep -q 'PROGRAM_STATE=' "$record"
grep -q 'STABLE_TERMINAL_CHECKPOINT' "$record"
grep -q 'ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=' "$record"
grep -q '^NONE$' <(awk '/ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=/{getline; print}' "$record")
grep -q 'FINAL_ACTION=' "$record"
grep -q '^STOP$' <(awk '/FINAL_ACTION=/{getline; print}' "$record")

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

FINAL_STOP_BASE=
8653da4e

FINAL_DR=
20260813_194322

PROGRAM_RECONCILIATION_MILESTONE=
CLOSED

PROGRAM_STATE=
STABLE_TERMINAL_CHECKPOINT

ACTIVE_RUNTIME_SUCCESSOR_MILESTONE=
NONE

NEW_RUNTIME_WORK_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

FINAL_ACTION=
STOP
MAP
