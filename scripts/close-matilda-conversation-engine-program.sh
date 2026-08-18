#!/usr/bin/env bash
set -euo pipefail

echo "=== MATILDA CONVERSATION ENGINE — FORMAL PROGRAM CLOSURE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 68760b61 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-matilda-conversation-engine-program\.sh$|^ M scripts/close-matilda-conversation-engine-program\.sh$' ||
  true
)"
test -z "$unexpected"

test -f scripts/classify-matilda-conversation-engine-program-closure-readiness.sh

grep -Fq 'FORMAL_PROGRAM_LEVEL_CLOSURE_READINESS=' scripts/classify-matilda-conversation-engine-program-closure-readiness.sh
grep -Fq 'READY_BOUNDED' scripts/classify-matilda-conversation-engine-program-closure-readiness.sh
grep -Fq 'CANONICAL_DR_REQUIRED_AT_FORMAL_PROGRAM_CLOSURE=' scripts/classify-matilda-conversation-engine-program-closure-readiness.sh
grep -Fq 'YES' scripts/classify-matilda-conversation-engine-program-closure-readiness.sh

cat <<'MAP'
PROGRAM=MATILDA_CONVERSATION_ENGINE
PROGRAM_STATUS=CLOSED_BOUNDED

RUNTIME_MILESTONE_SEQUENCE=
COMPLETE_ON_CURRENT_EVIDENCE_SUPPORTED_CAPABILITY_SURFACE

CURRENT_GENUINE_UNRESOLVED_RUNTIME_CAPABILITY_GAPS=
ZERO

CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=
NONE_ESTABLISHED

SEPARATELY_DEFERRED_NON_BLOCKING_WORK=
REASONING_STATUS_MODEL_BEHAVIORAL_RELIABILITY__KNOWN_PRODUCTION_GENERATION_INSTABILITY__OTHER_ITEMS_WITH_REQUIREMENT_OR_PRIORITY_NOT_ESTABLISHED

DEFERRED_WORK_PRESERVED=
YES

PHASE_3_REASONING_STATUS_PRODUCTION_BEHAVIOR=
CLOSED_BOUNDED

PHASE_3_CANONICAL_DR=
20260818_102518

GENERATION_STABILITY=
CLOSED

FULL_RESOLUTION_OF_DEFERRED_NON_BLOCKING_WORK=
NOT_CLAIMED

NEW_RUNTIME_MILESTONE=
NOT_ESTABLISHED

NON_RUNTIME_SUCCESSOR_PRIORITY=
NONE_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

PROGRAM_CLOSURE=
COMPLETE_BOUNDED

DR_NOW=
YES

NEXT_ACTION=
COMMIT_FORMAL_PROGRAM_CLOSURE_AND_RUN_SINGLE_CANONICAL_PROGRAM_CLOSURE_DR
MAP
