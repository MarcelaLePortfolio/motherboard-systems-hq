#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE CROSS-TURN TRANSITION VALIDATION CURRENT STATE ==="

REQUIRED_ANCESTOR="5e21651b"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: cross-turn transition-validation investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$|^ M scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING INVESTIGATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE_INSPECTED|CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=NOT_STARTED|PRIOR_LIFECYCLE_CONTEXT_TRANSPORT_REMAINS_IMPLEMENTED|ONE_OLLAMA_INVOCATION_PRESERVED|NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE' \
  scripts/investigate-investigation-lifecycle-cross-turn-transition-validation-current-state.sh

echo
echo "=== VERIFY GENERAL IDENTITY STABILITY CONTRACT ==="
grep -nE \
  'investigationIdentity must remain stable across turns belonging to the same|CONTINUATION can be represented by the stable investigationIdentity|preserved governingQuestion' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

echo
echo "=== VERIFY DETERMINISTIC CONTINUITY AUTHORITY ==="
grep -nE \
  'For continuation or advancement, prior lifecycle context may supply the|Matilda must preserve that identity when the same investigation continues|Deterministic runtime may validate identity continuity|A continuity violation must fail closed|For continued or advanced lifecycle events, runtime may validate' \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh

echo
echo "=== VERIFY PREVIOUSLY DEFERRED CROSS-TURN SCOPE ==="
grep -nE \
  'Continuity validation for continued or advanced investigations requires|cross-turn investigationIdentity continuity validation must not be fabricated|Continuity validation remains a successor implementation corridor' \
  scripts/classify-investigation-lifecycle-structured-response-implementation-readiness.sh

echo
echo "=== VERIFY PRIOR-CONTEXT PREREQUISITE NOW IMPLEMENTED ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_IMPLEMENTED_AND_VALIDATED|PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED|SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED|CROSS_TURN_TRANSITION_VALIDATION=ABSENT' \
  scripts/classify-investigation-lifecycle-prior-context-transport-implementation.sh

echo
echo "=== VERIFY CURRENT SHARED VALIDATOR ROLE ==="
grep -nE \
  'export function validateMatildaInvestigationLifecycleArtifact|investigation lifecycle without investigation identity|investigation lifecycle without governing question|invalid investigation lifecycle event|without required determination' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY PRIOR AND CURRENT ARTIFACTS MEET AT OLLAMA BOUNDARY ==="
grep -nE \
  'priorInvestigationLifecycle|const result =|parseStructuredResponse|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 120

echo
echo "=== VERIFY WORKFLOW PERSISTS ONLY AFTER OLLAMA RESULT ==="
grep -nE \
  'const ollamaResult =|await ollamaChat|createInterpretationEvidenceLedgerEntry|investigation_lifecycle:' \
  server/matilda-chat-workflow.ts

cat <<'FINDINGS'

Cross-turn Investigation Lifecycle transition-validation classification:

Protected implemented baseline:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED
IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED
IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED
PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED

Repository-supported classification:

1. Cross-turn Investigation Lifecycle transition validation is not currently
   implemented.

2. The prerequisite prior-lifecycle semantic-context transport seam is now
   implemented and independently validated.

3. investigationIdentity is governed by the established invariant:

   investigationIdentity must remain stable across turns belonging to the same
   investigation.

4. CONTINUATION is explicitly defined using:

   - stable investigationIdentity;
   - preserved governingQuestion;
   - lifecycleEvent=continued.

5. The semantic representation contract explicitly states that for continuation
   or advancement prior lifecycle context may supply the existing
   investigationIdentity to Matilda.

6. Matilda must preserve that identity when the same investigation continues.

7. Deterministic runtime is explicitly authorized to validate identity
   continuity.

8. Runtime is not authorized to invent, rewrite, or repair a replacement
   investigationIdentity.

9. A continuity violation must fail closed rather than being silently repaired.

10. Existing implementation-readiness evidence specifically deferred cross-turn
    investigationIdentity continuity validation for continued and advanced.

11. That deferral existed because prior Investigation Lifecycle semantic context
    was not yet supplied.

12. The missing prerequisite is now satisfied by the implemented
    priorInvestigationLifecycle transport seam.

13. Therefore the smallest repository-supported deterministic validation scope
    is continued / advanced investigationIdentity continuity.

14. For lifecycleEvent=continued, preserved governingQuestion is explicitly part
    of the established semantic contract.

15. For lifecycleEvent=advanced, repository evidence authorizes correlation of
    the governing investigation with prior supplied lifecycle context, but does
    not establish exact governingQuestion string equality as a universal rule.

16. Runtime must not invent a stronger governing-question equality invariant.

17. Repository evidence does not establish a complete event-to-event transition
    matrix.

18. Repository evidence does not establish deterministic terminal-state
    enforcement for resolved, superseded, or abandoned.

19. Repository evidence does not establish that entered must always use an
    investigationIdentity different from the prior artifact.

20. Repository evidence does not explicitly authorize resolved-identity
    enforcement within the currently bounded validation scope.

21. Unrelated governance, execution, scheduler, task, telemetry, and evidence
    lifecycle state machines must not be imported into Matilda Investigation
    Lifecycle.

22. Matilda remains semantic author of whether the current turn enters,
    continues, advances, resolves, supersedes, abandons, or does not participate
    in an investigation.

23. Runtime may enforce only already-established deterministic continuity
    invariants.

24. The shared validateMatildaInvestigationLifecycleArtifact validator currently
    validates one artifact independently and should remain the single-artifact
    semantic-shape validator.

25. ollamaChat already owns both required comparison inputs:

    context.priorInvestigationLifecycle
    and
    the parsed current investigationLifecycle.

26. The smallest candidate ownership boundary for a dedicated deterministic
    cross-turn continuity validator is after current structured-response parsing
    inside ollamaChat and before the result returns to workflow persistence.

27. This placement requires no additional model invocation, workflow semantic
    authorship, IEL change, or prior-context transport change.

28. Automatic repair, lifecycle-only discard, retries, or correction invocations
    are not supported.

29. A supported continuity violation should fail closed.

Classification:

INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE_CLASSIFIED

CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=ABSENT

PRIOR_LIFECYCLE_CONTEXT_PREREQUISITE=SATISFIED

SUPPORTED_DETERMINISTIC_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_IDENTITY

CONTINUED_GOVERNING_QUESTION_PRESERVATION=ESTABLISHED

ADVANCED_GOVERNING_INVESTIGATION_CORRELATION=ESTABLISHED

FULL_EVENT_TRANSITION_MATRIX=NOT_ESTABLISHED

TERMINAL_STATE_ENFORCEMENT=NOT_ESTABLISHED

RESOLVED_IDENTITY_ENFORCEMENT=NOT_YET_ESTABLISHED

ENTERED_NEW_IDENTITY_REQUIREMENT=NOT_ESTABLISHED

AUTOMATIC_LIFECYCLE_REPAIR=NOT_AUTHORIZED

CONTINUITY_VIOLATION_BEHAVIOR=FAIL_CLOSED

CANDIDATE_VALIDATION_OWNER=OLLAMA_POST_PARSE_PRE_WORKFLOW_RETURN

MATILDA_SEMANTIC_AUTHORITY=PRESERVED

ONE_OLLAMA_INVOCATION_PRESERVED

PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED

Next canonical unit:

CLASSIFY_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS

Do not implement transition validation during this classification.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE_CLASSIFIED"
echo "CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=ABSENT"
echo "PRIOR_LIFECYCLE_CONTEXT_PREREQUISITE=SATISFIED"
echo "SUPPORTED_DETERMINISTIC_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_IDENTITY"
echo "CONTINUED_GOVERNING_QUESTION_PRESERVATION=ESTABLISHED"
echo "ADVANCED_GOVERNING_INVESTIGATION_CORRELATION=ESTABLISHED"
echo "FULL_EVENT_TRANSITION_MATRIX=NOT_ESTABLISHED"
echo "TERMINAL_STATE_ENFORCEMENT=NOT_ESTABLISHED"
echo "RESOLVED_IDENTITY_ENFORCEMENT=NOT_YET_ESTABLISHED"
echo "ENTERED_NEW_IDENTITY_REQUIREMENT=NOT_ESTABLISHED"
echo "AUTOMATIC_LIFECYCLE_REPAIR=NOT_AUTHORIZED"
echo "CONTINUITY_VIOLATION_BEHAVIOR=FAIL_CLOSED"
echo "CANDIDATE_VALIDATION_OWNER=OLLAMA_POST_PARSE_PRE_WORKFLOW_RETURN"
echo "MATILDA_SEMANTIC_AUTHORITY=PRESERVED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during cross-turn transition classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$' ||
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

git add scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle cross-turn transition validation"
git push
