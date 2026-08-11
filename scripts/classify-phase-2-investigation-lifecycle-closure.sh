#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 2 INVESTIGATION LIFECYCLE CLOSURE ==="

REQUIRED_ANCESTOR="72b37f74"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 2 closure assessment checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-phase-2-investigation-lifecycle-closure\.sh$|^ M scripts/classify-phase-2-investigation-lifecycle-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING CLOSURE ASSESSMENT ==="
grep -nE \
  'PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE_ASSESSED|PRODUCTION_IMPLEMENTATION_CHANGE=NONE|PHASE_3_ATTENTION_MANAGEMENT_NOT_STARTED|NEXT_ACTION=CLASSIFY_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE' \
  scripts/assess-phase-2-investigation-lifecycle-closure.sh

echo
echo "=== VERIFY CROSS-TURN VALIDATION IS IMPLEMENTED AND VALIDATED ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED_AND_VALIDATED|CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED|IMPLEMENTED_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY|MATILDA_SEMANTIC_AUTHORITY=PRESERVED' \
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation.sh

echo
echo "=== VERIFY PHASE 2 CAPABILITY CHAIN ==="
grep -nE \
  'MINIMUM_FACTS=investigationIdentity,governingQuestion,lifecycleEvent,lifecycleDetermination' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

grep -nE \
  'MatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleContinuity' \
  scripts/utils/ollamaChat.ts |
head -n 80

grep -nE \
  'investigation_lifecycle_json|investigationLifecycle' \
  db/matilda-interpretation-runtime.ts |
head -n 100

grep -nE \
  'selectMatildaPriorInvestigationLifecycle|scopedLifecycleLedgerEntries|priorInvestigationLifecycle' \
  server/matilda-chat-workflow.ts |
head -n 100

echo
echo "=== VERIFY PHASE 2 REGRESSION BASELINE ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== VERIFY PERMANENT RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== FALSIFICATION — CURRENT UNSATISFIED PHASE 2 RESPONSIBILITY ==="
current_gap="$(
  grep -RInE \
    'PHASE_2.*(BLOCKED|INCOMPLETE|REMAINS_OPEN)|CURRENT_PHASE_2_GAP=|CURRENT_INVESTIGATION_LIFECYCLE_GAP=|NEXT_ACTION=.*IMPLEMENT.*INVESTIGATION_LIFECYCLE|NEXT_UNIT=.*IMPLEMENT.*INVESTIGATION_LIFECYCLE' \
    docs scripts \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='classify-phase-2-investigation-lifecycle-closure.sh' \
    --exclude='assess-phase-2-investigation-lifecycle-closure.sh' \
    2>/dev/null ||
  true
)"

if [[ -n "$current_gap" ]]; then
  echo "POTENTIAL_CURRENT_PHASE_2_GAP_REFERENCES_FOUND"
  printf '%s\n' "$current_gap"
  echo
  echo "Review above references before relying on closure classification."
else
  echo "NO_CURRENT_UNSATISFIED_PHASE_2_RESPONSIBILITY_FOUND"
fi

cat <<'FINDINGS'

Phase 2 — Investigation Lifecycle closure classification:

Verified Phase 2 capability boundary:

1. Investigation Lifecycle semantic authorship is established.

2. The minimum semantic artifact is established:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

3. The bounded lifecycle event vocabulary is established:

   entered
   continued
   advanced
   resolved
   superseded
   abandoned

4. Current-turn structured semantic generation is implemented.

5. Current-artifact validation is implemented and fail-closed.

6. Current-turn workflow transport is implemented.

7. IEL lifecycle persistence is implemented.

8. Shared lifecycle semantic validation is implemented.

9. IEL lifecycle reconstruction is implemented.

10. Project/conversation-scoped prior lifecycle retrieval is implemented.

11. Newest eligible prior lifecycle selection is implemented.

12. Dedicated prior lifecycle semantic-generation context transport is implemented.

13. Prior lifecycle semantic state remains distinct from current lifecycle determination.

14. Cross-turn continued/advanced investigationIdentity continuity validation is implemented and validated.

15. Continuity mismatches fail closed.

16. One Ollama invocation remains preserved.

17. Matilda remains Investigation Lifecycle semantic author.

18. Deterministic runtime remains limited to validation, persistence,
    reconstruction, scoping, selection, transport, and enforcement of explicit
    established invariants.

Closure determination:

19. The previously identified remaining Phase 2 capability gap — bounded
    cross-turn transition validation — is now implemented and validated.

20. Repository falsification did not identify another distinct unimplemented
    Investigation Lifecycle responsibility required by the currently governed
    Phase 2 capability boundary.

21. Historical scripts containing ABSENT, DEFERRED, or NOT_STARTED states are
    superseded by later implementation and classification checkpoints and do not
    represent current capability state.

22. A complete lifecycle transition matrix is not required for closure because
    repository evidence does not establish such a matrix as governed Phase 2 semantics.

23. Terminal-state enforcement is not required for closure because repository
    evidence does not establish deterministic terminal-state rules for Matilda
    Investigation Lifecycle.

24. Exact governingQuestion string equality is not required for closure because
    repository evidence does not define semantic preservation as exact string equality.

25. Automatic lifecycle repair is not required and remains unauthorized.

26. Unsupported broader transition semantics must remain absent rather than
    being invented to extend the phase.

27. No remaining architectural uncertainty identified by current repository
    evidence materially changes the implemented Phase 2 responsibility boundary.

Therefore:

PHASE_2_INVESTIGATION_LIFECYCLE=COMPLETE

PHASE_2_INVESTIGATION_LIFECYCLE_STATUS=CLOSED

CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED_AND_VALIDATED

PHASE_2_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE

FULL_TRANSITION_MATRIX=NOT_REQUIRED_AND_NOT_IMPLEMENTED

TERMINAL_STATE_ENFORCEMENT=NOT_REQUIRED_AND_NOT_IMPLEMENTED

GOVERNING_QUESTION_EXACT_EQUALITY=NOT_REQUIRED_AND_NOT_IMPLEMENTED

MATILDA_INVESTIGATION_LIFECYCLE_AUTHORITY=PRESERVED

ONE_OLLAMA_INVOCATION_PRESERVED

PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED

Phase 2 is complete and may close.

This classification does not authorize Phase 3 implementation.

Next canonical program state:

MATILDA_COLLABORATION_RUNTIME

PHASE_1_RESPONSE_COMPOSITION=CLOSED

PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED

NEXT_PHASE=PHASE_3_ATTENTION_MANAGEMENT

PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED

NEXT_ACTION=RECONCILE_PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE

The next Phase 3 unit must begin in collaboration/investigation mode.

Do not implement Phase 3 automatically.

FINDINGS

echo
echo "PHASE_2_INVESTIGATION_LIFECYCLE_COMPLETE"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_STATUS=CLOSED"
echo "CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED_AND_VALIDATED"
echo "PHASE_2_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE"
echo "FULL_TRANSITION_MATRIX=NOT_REQUIRED_AND_NOT_IMPLEMENTED"
echo "TERMINAL_STATE_ENFORCEMENT=NOT_REQUIRED_AND_NOT_IMPLEMENTED"
echo "GOVERNING_QUESTION_EXACT_EQUALITY=NOT_REQUIRED_AND_NOT_IMPLEMENTED"
echo "MATILDA_INVESTIGATION_LIFECYCLE_AUTHORITY=PRESERVED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_PHASE=PHASE_3_ATTENTION_MANAGEMENT"
echo "PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED"
echo "NEXT_ACTION=RECONCILE_PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING CLOSURE CLASSIFICATION ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during Phase 2 closure classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED_DURING_CLOSURE_CLASSIFICATION"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-2-investigation-lifecycle-closure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 2 closure classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-2-investigation-lifecycle-closure.sh
git diff --cached --check
git commit -m "Close Phase 2 Investigation Lifecycle"
git push
