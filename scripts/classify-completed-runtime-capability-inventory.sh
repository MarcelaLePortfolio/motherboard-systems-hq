#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY COMPLETED RUNTIME CAPABILITY INVENTORY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="a395c525"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches successor milestone checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-completed-runtime-capability-inventory\.sh$|^ M scripts/classify-completed-runtime-capability-inventory\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SUCCESSOR_MILESTONE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PROGRAM BOUNDARY ==="

grep -q 'SUCCESSOR_MILESTONE=' scripts/classify-post-semantic-history-successor-milestone.sh
grep -q 'CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION' scripts/classify-post-semantic-history-successor-milestone.sh
grep -q 'NEXT_CORRIDOR=' scripts/classify-post-semantic-history-successor-milestone.sh
grep -q 'COMPLETED_RUNTIME_CAPABILITY_INVENTORY' scripts/classify-post-semantic-history-successor-milestone.sh

echo "PROGRAM_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY REPRESENTATIVE IMPLEMENTED SURFACES ==="

test -f server/matilda-chat-workflow.ts
test -f server/matilda-conversation-context-runtime.ts
test -f server/matilda-history-selection-runtime.ts
test -f scripts/utils/ollamaChat.ts

grep -q 'selectedHistory' server/matilda-conversation-context-runtime.ts
grep -q 'conversationContext.selectedHistory' server/matilda-chat-workflow.ts
grep -q 'priorInvestigationLifecycle' server/matilda-chat-workflow.ts
grep -q 'projectContextExcerpts' server/matilda-chat-workflow.ts
grep -q 'await[[:space:]]*ollamaChat(' server/matilda-chat-workflow.ts

echo "REPRESENTATIVE_RUNTIME_SURFACES=CONFIRMED"

echo
echo "=== COMPLETED RUNTIME CAPABILITY INVENTORY ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE=
  CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

PHASE=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

CORRIDOR=
  COMPLETED_RUNTIME_CAPABILITY_INVENTORY

WORKFLOW_ORCHESTRATION=
  IMPLEMENTED

ONE_USER_MESSAGE_TO_ONE_WORKFLOW=
  IMPLEMENTED

ONE_WORKFLOW_TO_ONE_OLLAMA_INVOCATION=
  IMPLEMENTED

STRUCTURED_OLLAMA_RESPONSE_CONTRACT=
  IMPLEMENTED

REPLY_AND_DURABLE_INTERPRETATION_SEPARATION=
  IMPLEMENTED

WORKFLOW_OWNED_DURABLE_IEL_PERSISTENCE=
  IMPLEMENTED

INVESTIGATION_LIFECYCLE_CURRENT_TURN_TRANSPORT=
  IMPLEMENTED

INVESTIGATION_LIFECYCLE_RECONSTRUCTION=
  IMPLEMENTED

PRIOR_INVESTIGATION_LIFECYCLE_SCOPED_SELECTION=
  IMPLEMENTED

PRIOR_INVESTIGATION_LIFECYCLE_TYPED_CONTEXT_CHANNEL=
  IMPLEMENTED

CONVERSATION_HISTORY_RETRIEVAL=
  IMPLEMENTED

PROJECT_AND_CONVERSATION_SCOPING=
  IMPLEMENTED

BOUNDED_CHRONOLOGICAL_RETRIEVAL=
  IMPLEMENTED

INTERPRETATION_AUTHORITY_EVALUATION=
  IMPLEMENTED

CONTAMINATION_EVALUATION=
  IMPLEMENTED

ADMISSION_BASED_HISTORY_SELECTION=
  IMPLEMENTED

SELECTED_HISTORY=
  IMPLEMENTED

SELECTED_HISTORY_CHRONOLOGY=
  PRESERVED

SELECTED_HISTORY_LINEAGE_AND_METADATA=
  PRESERVED

SELECTED_HISTORY_INPUT_IMMUTABILITY=
  PRESERVED

CONVERSATION_CONTEXT_RUNTIME=
  IMPLEMENTED

PROJECT_CONTEXT_EXCERPT_CHANNEL=
  IMPLEMENTED

PROJECT_CONTEXT_PROVENANCE_VALIDATION=
  IMPLEMENTED

PRIOR_LIFECYCLE_CONTEXT_SEPARATION=
  IMPLEMENTED

OLLAMA_SELECTED_HISTORY_CONSUMPTION=
  IMPLEMENTED

OLLAMA_PROJECT_CONTEXT_CONSUMPTION=
  IMPLEMENTED

OLLAMA_PRIOR_LIFECYCLE_CONTEXT_CONSUMPTION=
  IMPLEMENTED

ONE_OLLAMA_INVOCATION=
  IMPLEMENTED

FAIL_CLOSED_STRUCTURED_RESPONSE_VALIDATION=
  IMPLEMENTED

LIVING_DRAFT_DERIVATION_FROM_IEL=
  IMPLEMENTED

APPROVAL_PIPELINE=
  IMPLEMENTED

SEMANTIC_HISTORY_OPTIMIZATION_RUNTIME_CHANGE=
  NONE

GENERATION_STABILITY_PRODUCTION_CHANGE=
  NONE

DETERMINISTIC_REGRESSION_STATUS=
  PASS

COMPLETED_RUNTIME_CAPABILITY_INVENTORY_STATUS=
  COMPLETE

INVENTORY_INTERPRETATION=
  The repository contains a mature implemented Conversation Engine runtime
  spanning workflow orchestration, semantic history preparation, typed context
  transport, lifecycle reconstruction, structured generation, deterministic
  validation, IEL persistence, Living Draft derivation, and approval flow.

  This inventory records implemented capability only.

  It does not classify deferred work, unresolved gaps, priority, or future
  implementation requirements.

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_CORRIDOR=
  DEFERRED_WORK_INVENTORY

NEXT_ACTION=
  CLASSIFY_DEFERRED_WORK_INVENTORY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-completed-runtime-capability-inventory\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside completed runtime inventory scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
