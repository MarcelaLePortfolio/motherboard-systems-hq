#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE CROSS-TURN TRANSITION VALIDATION IMPLEMENTATION ==="

REQUIRED_ANCESTOR="b903aca8"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: transition-validation implementation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation\.sh$|^ M scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY IMPLEMENTATION-READINESS AUTHORIZATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READY|IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY|VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER|VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING|FAILURE_BEHAVIOR=FAIL_CLOSED|FULL_TRANSITION_MATRIX=NOT_AUTHORIZED|TERMINAL_STATE_VALIDATION=NOT_AUTHORIZED' \
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh

echo
echo "=== VERIFY IMPLEMENTATION SIGNALS ==="
grep -nE \
  'BOUNDED_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED|IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY|VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING|FAILURE_BEHAVIOR=FAIL_CLOSED|GOVERNING_QUESTION_EXACT_EQUALITY=NOT_IMPLEMENTED|FULL_TRANSITION_MATRIX=NOT_IMPLEMENTED|TERMINAL_STATE_VALIDATION=NOT_IMPLEMENTED|AUTOMATIC_REPAIR=NOT_IMPLEMENTED|SECOND_MODEL_INVOCATION=NONE|WORKFLOW_CHANGE=NONE|IEL_CHANGE=NONE|CONVERSATION_CONTEXT_RUNTIME_CHANGE=NONE|NEXT_ACTION=VALIDATE_AND_CLASSIFY_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION' \
  scripts/implement-investigation-lifecycle-cross-turn-transition-validation.sh

echo
echo "=== VERIFY DEDICATED CROSS-TURN VALIDATOR ==="
grep -nE -A45 -B5 \
  'export function validateMatildaInvestigationLifecycleContinuity' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY POST-PARSE VALIDATION SEAM ==="
grep -nE -A12 -B5 \
  'validateMatildaInvestigationLifecycleContinuity' \
  scripts/utils/ollamaChat.ts |
tail -n 30

echo
echo "=== VERIFY NO UNAUTHORIZED GOVERNING-QUESTION EQUALITY ==="
if grep -nE \
  'currentInvestigationLifecycle\.governingQuestion.*priorInvestigationLifecycle\.governingQuestion|priorInvestigationLifecycle\.governingQuestion.*currentInvestigationLifecycle\.governingQuestion' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: unauthorized governingQuestion equality validation exists."
  exit 2
fi
echo "GOVERNING_QUESTION_EXACT_EQUALITY_NOT_IMPLEMENTED"

echo
echo "=== VERIFY NO FULL TRANSITION MATRIX ==="
if grep -nE \
  'allowedTransitions|transitionMatrix|validTransitions|terminalEvents|terminalStates' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: unauthorized transition-matrix or terminal-state machinery exists."
  exit 2
fi
echo "FULL_TRANSITION_MATRIX_NOT_IMPLEMENTED"

echo
echo "=== TARGETED LIFECYCLE CONTRACT TEST ==="
npx tsx --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== PRIOR CONTEXT TRANSPORT REGRESSION ==="
npx tsx --test scripts/validate-investigation-lifecycle-prior-context-transport.test.ts

echo
echo "=== SCOPED IEL RETRIEVAL REGRESSION ==="
npx tsx --test scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts

echo
echo "=== IEL RECONSTRUCTION REGRESSION ==="
npx tsx --test scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

echo
echo "=== TYPED IEL WORKFLOW TRANSPORT REGRESSION ==="
npx tsx --test scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== PERMANENT RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY UNAUTHORIZED SURFACES UNCHANGED ==="
if ! git diff --quiet -- \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production surfaces outside the authorized implementation remain changed."
  exit 2
fi

echo "UNAUTHORIZED_SURFACES_UNCHANGED"

cat <<'FINDINGS'

Cross-turn Investigation Lifecycle transition-validation implementation classification:

Verified implemented capability:

1. A dedicated deterministic cross-turn Investigation Lifecycle continuity
   validator exists in the Ollama adapter.

2. It compares priorInvestigationLifecycle with the current Matilda-authored
   investigationLifecycle after structured-response parsing and before
   downstream processing.

3. It enforces investigationIdentity continuity only for current lifecycleEvent:

   continued
   advanced

4. A continued or advanced artifact whose investigationIdentity differs from
   prior lifecycle context fails closed.

5. Null prior state and null current state remain valid.

6. entered, resolved, superseded, and abandoned do not inherit unsupported
   deterministic identity-transition rules.

7. Exact governingQuestion equality is not implemented.

8. No full transition matrix is implemented.

9. No terminal-state enforcement is implemented.

10. No automatic lifecycle repair is implemented.

11. No retry or second model invocation is introduced.

12. Workflow transport, IEL persistence, IEL reconstruction, scoped prior-state
    retrieval, Conversation Context Runtime, selectedHistory, and
    conversation-turn persistence remain unchanged.

13. Matilda remains Investigation Lifecycle semantic author.

14. Phase 1 Response Composition remains closed.

Validation:

15. Investigation Lifecycle contract tests pass.

16. Prior-context transport regressions pass.

17. Scoped IEL retrieval regressions pass.

18. IEL reconstruction regressions pass.

19. Typed IEL workflow transport regressions pass.

20. Permanent Ollama response-contract guard passes.

Classification:

INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED_AND_VALIDATED

CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED

IMPLEMENTED_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY

VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER

VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING

CONTINUITY_VIOLATION_BEHAVIOR=FAIL_CLOSED

MATILDA_SEMANTIC_AUTHORITY=PRESERVED

GOVERNING_QUESTION_EXACT_EQUALITY=NOT_IMPLEMENTED

FULL_TRANSITION_MATRIX=NOT_IMPLEMENTED

TERMINAL_STATE_VALIDATION=NOT_IMPLEMENTED

AUTOMATIC_REPAIR=NOT_IMPLEMENTED

SECOND_MODEL_INVOCATION=NONE

PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED

The bounded Cross-Turn Transition Validation capability established by repository
evidence is implemented and validated.

Next canonical action:

ASSESS_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE

Do not begin Phase 3 automatically.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED_AND_VALIDATED"
echo "CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED"
echo "IMPLEMENTED_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY"
echo "VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER"
echo "VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING"
echo "CONTINUITY_VIOLATION_BEHAVIOR=FAIL_CLOSED"
echo "MATILDA_SEMANTIC_AUTHORITY=PRESERVED"
echo "GOVERNING_QUESTION_EXACT_EQUALITY=NOT_IMPLEMENTED"
echo "FULL_TRANSITION_MATRIX=NOT_IMPLEMENTED"
echo "TERMINAL_STATE_VALIDATION=NOT_IMPLEMENTED"
echo "AUTOMATIC_REPAIR=NOT_IMPLEMENTED"
echo "SECOND_MODEL_INVOCATION=NONE"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=ASSESS_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING CLASSIFICATION ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during implementation classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED_DURING_CLASSIFICATION"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle transition validation implementation"
git push
