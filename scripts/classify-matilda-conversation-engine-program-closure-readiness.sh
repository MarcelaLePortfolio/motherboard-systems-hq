#!/usr/bin/env bash
set -euo pipefail

echo "=== MATILDA CONVERSATION ENGINE — FORMAL PROGRAM CLOSURE READINESS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 7064bdf7 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-matilda-conversation-engine-program-closure-readiness\.sh$|^ M scripts/classify-matilda-conversation-engine-program-closure-readiness\.sh$' ||
  true
)"
test -z "$unexpected"

test -f scripts/reconcile-matilda-conversation-engine-program-level-closure.sh
test -f scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
test -f scripts/classify-post-phase-3-deferred-work-disposition.sh

grep -Fq 'PROGRAM_LEVEL_CLOSURE_ELIGIBILITY=' scripts/reconcile-matilda-conversation-engine-program-level-closure.sh
grep -Fq 'SUPPORTED_ON_CURRENT_RUNTIME_CAPABILITY_SURFACE' scripts/reconcile-matilda-conversation-engine-program-level-closure.sh
grep -Fq 'CURRENT_GENUINE_UNRESOLVED_RUNTIME_CAPABILITY_GAPS=' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'ZERO' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'NONE_ESTABLISHED' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh

cat <<'MAP'
PROGRAM=MATILDA_CONVERSATION_ENGINE
STATUS=FORMAL_PROGRAM_LEVEL_CLOSURE_READINESS_CLASSIFIED

RUNTIME_MILESTONE_SEQUENCE=
COMPLETE_ON_CURRENT_EVIDENCE_SUPPORTED_CAPABILITY_SURFACE

CURRENT_GENUINE_UNRESOLVED_RUNTIME_CAPABILITY_GAPS=
ZERO

CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=
NONE_ESTABLISHED

PROGRAM_LEVEL_CLOSURE_ELIGIBILITY=
SUPPORTED

FORMAL_PROGRAM_LEVEL_CLOSURE_READINESS=
READY_BOUNDED

CLOSURE_BOUNDARY=
CLOSE_THE_CURRENT_MATILDA_CONVERSATION_ENGINE_RUNTIME_CAPABILITY_PROGRAM_WITHOUT_CLAIMING_SEPARATELY_DEFERRED_NON_BLOCKING_CONDITIONS_ARE_RESOLVED

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

NEW_RUNTIME_MILESTONE=
NOT_ESTABLISHED

NON_RUNTIME_SUCCESSOR_PRIORITY=
NONE_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

CANONICAL_DR_REQUIRED_AT_FORMAL_PROGRAM_CLOSURE=
YES

DR_NOW=
NO

NEXT_ACTION=
FORMALLY_CLOSE_MATILDA_CONVERSATION_ENGINE_PROGRAM_ON_THIS_BOUNDED_BASIS_AND_RUN_ONE_CANONICAL_PROGRAM_CLOSURE_DR
MAP
