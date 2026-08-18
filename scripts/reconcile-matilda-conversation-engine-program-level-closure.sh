#!/usr/bin/env bash
set -euo pipefail

echo "=== MATILDA CONVERSATION ENGINE — PROGRAM LEVEL CLOSURE RECONCILIATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 71bfeba6 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-matilda-conversation-engine-program-level-closure\.sh$|^ M scripts/reconcile-matilda-conversation-engine-program-level-closure\.sh$' ||
  true
)"
test -z "$unexpected"

test -f scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
test -f scripts/classify-post-phase-3-deferred-work-disposition.sh
test -f scripts/record-phase-3-dr-protection-and-reconcile-successor-scope.sh

grep -Fq 'COMPLETE_ON_CURRENT_EVIDENCE_SUPPORTED_CAPABILITY_SURFACE' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'CURRENT_GENUINE_UNRESOLVED_RUNTIME_CAPABILITY_GAPS=' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'ZERO' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh
grep -Fq 'NONE_ESTABLISHED' scripts/classify-matilda-conversation-engine-runtime-sequence-completion.sh

cat <<'MAP'
PROGRAM=MATILDA_CONVERSATION_ENGINE
STATUS=PROGRAM_LEVEL_CLOSURE_BOUNDARY_RECONCILED

RUNTIME_MILESTONE_SEQUENCE=
COMPLETE_ON_CURRENT_EVIDENCE_SUPPORTED_CAPABILITY_SURFACE

CURRENT_GENUINE_UNRESOLVED_RUNTIME_CAPABILITY_GAPS=
ZERO

CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=
NONE_ESTABLISHED

PHASE_3_REASONING_STATUS_PRODUCTION_BEHAVIOR=
CLOSED_BOUNDED

PHASE_3_CANONICAL_DR=
20260818_102518

GENERATION_STABILITY=
CLOSED

SEPARATELY_DEFERRED_NON_BLOCKING_WORK=
REASONING_STATUS_MODEL_BEHAVIORAL_RELIABILITY__KNOWN_PRODUCTION_GENERATION_INSTABILITY__OTHER_ITEMS_WITH_REQUIREMENT_OR_PRIORITY_NOT_ESTABLISHED

PROGRAM_LEVEL_CLOSURE_ELIGIBILITY=
SUPPORTED_ON_CURRENT_RUNTIME_CAPABILITY_SURFACE

PROGRAM_LEVEL_CLOSURE_MEANING=
CURRENT_REQUIRED_RUNTIME_CAPABILITY_SEQUENCE_IS_COMPLETE__SEPARATELY_DEFERRED_NON_BLOCKING_WORK_REMAINS_EXPLICIT_AND_MAY_BE_REVISITED_ONLY_BY_NEW_EVIDENCE_OR_EXPLICIT_PROGRAM_PRIORITY

NON_RUNTIME_SUCCESSOR_PRIORITY=
NONE_ESTABLISHED_FROM_CURRENT_REPOSITORY_EVIDENCE

NEW_MILESTONE=
NOT_ESTABLISHED

NEW_CORRIDOR=
NOT_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

DR_NOW=
NO

NEXT_ACTION=
CLASSIFY_FORMAL_PROGRAM_LEVEL_CLOSURE_READINESS_AND_CANONICAL_DR_REQUIREMENT
MAP
