#!/usr/bin/env bash
set -euo pipefail

echo "=== MATILDA CONVERSATION ENGINE — RESUME FORMAL CLOSURE / RUN DR ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 68760b61 HEAD

test -f scripts/close-matilda-conversation-engine-program.sh
grep -Fq 'PROGRAM_STATUS=CLOSED_BOUNDED' scripts/close-matilda-conversation-engine-program.sh
grep -Fq 'PROGRAM_CLOSURE=COMPLETE_BOUNDED' scripts/close-matilda-conversation-engine-program.sh
grep -Fq 'DR_NOW=YES' scripts/close-matilda-conversation-engine-program.sh

echo "FORMAL_CLOSURE_SCRIPT=CONFIRMED"
echo "ACTION=COMMIT_CLOSURE_STATE_THEN_RUN_CANONICAL_DR"
