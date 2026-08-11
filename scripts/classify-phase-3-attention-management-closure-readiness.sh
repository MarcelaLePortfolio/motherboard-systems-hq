#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 3 ATTENTION MANAGEMENT CLOSURE READINESS ==="

REQUIRED_ANCESTOR="7c35edfe"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: minimum Attention semantic-distinction classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "ORIGIN: $(git rev-parse --short=8 origin/feature/support-source-references-runtime)"

echo
echo "=== VERIFY CLOSURE-CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-attention-management-closure-readiness\.sh$|^ M scripts/classify-phase-3-attention-management-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLOSURE_CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 3 CURRENT-STATE LINEAGE ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE_RECONCILED|PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED|PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED' \
  scripts/reconcile-phase-3-attention-management-current-state.sh

echo
echo "=== VERIFY RESPONSIBILITY-BOUNDARY CLASSIFICATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY_CLASSIFIED|MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO|ONE_ACTIVE_INVESTIGATION_PER_CONVERSATION_ASSUMPTION=PRESERVED|UNRESOLVED_SEMANTIC_MATERIAL_DURABLY_PRESERVABLE=YES|RESIDUAL_CANDIDATE_DISTINCTION=PRESERVED_VALID_VS_CURRENTLY_GOVERNING_SEMANTIC_MATERIAL|NEXT_UNIT=INVESTIGATE_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION' \
  scripts/classify-phase-3-attention-management-responsibility-boundary.sh

echo
echo "=== VERIFY MINIMUM SEMANTIC DISTINCTION INVESTIGATION ==="
grep -nE \
  'MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_INVESTIGATED|GOVERNING_INVESTIGATION_POSITIVELY_REPRESENTED=YES|NON_GOVERNING_UNRESOLVED_MATERIAL_DURABLY_PRESERVABLE=YES|MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO|ATTENTION_DISTINCTION_CANDIDATE=RELATIONAL_EXISTING_SEMANTICS|NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NOT_ESTABLISHED|ACTUAL_CONTINUITY_FAILURE_REQUIRED_BEFORE_NEW_SEMANTIC_FACT=YES' \
  scripts/investigate-minimum-attention-semantic-distinction.sh

echo
echo "=== VERIFY MINIMUM SEMANTIC DISTINCTION CLASSIFICATION ==="
grep -nE \
  'MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_CLASSIFIED|CURRENTLY_GOVERNING_REPRESENTATION=GOVERNING_INVESTIGATION_LIFECYCLE|PRESERVED_NON_GOVERNING_REPRESENTATION=DURABLE_UNRESOLVED_SEMANTIC_MATERIAL|ATTENTION_DISTINCTION=RELATIONAL_EXISTING_SEMANTICS|NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NO|NEW_ATTENTION_STRUCTURED_RESPONSE_FIELD_REQUIRED=NO|NEW_ATTENTION_PERSISTENCE_REQUIRED=NO|NEW_ATTENTION_WORKFLOW_REQUIRED=NO|NEW_ATTENTION_CONTEXT_RUNTIME_REQUIRED=NO|NEW_ATTENTION_PROMPT_REQUIRED=NO|NEW_ATTENTION_DETERMINISTIC_VALIDATION_REQUIRED=NO|MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO|PHASE_3_IMPLEMENTATION_REQUIRED=NO|PHASE_3_CLOSURE_READINESS=READY_FOR_CLASSIFICATION' \
  scripts/classify-minimum-attention-semantic-distinction.sh

echo
echo "=== VERIFY PHASE 1 CLOSURE REMAINS ESTABLISHED ==="
git log --oneline --all --grep='Close Phase 1 Response Composition' |
head -n 20 || true

echo
echo "=== VERIFY PHASE 2 CLOSURE REMAINS ESTABLISHED ==="
git log --oneline --all --grep='Close Phase 2 Investigation Lifecycle' |
head -n 20 || true

echo
echo "=== VERIFY NO PHASE 3 PRODUCTION IMPLEMENTATION SURFACE ==="
attention_runtime_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-3-attention-management-current-state.sh' \
    --exclude='investigate-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='classify-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='investigate-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-phase-3-attention-management-closure-readiness.sh' \
    'attentionLifecycle|attentionState|attentionStatus|attentionPriority|currentAttention|attentionDetermination' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$attention_runtime_refs" ]]; then
  echo "STOP: possible Phase 3 production implementation surface exists:"
  printf '%s\n' "$attention_runtime_refs"
  exit 2
fi

echo "NO_PHASE_3_PRODUCTION_IMPLEMENTATION_SURFACE"

echo
echo "=== VERIFY NO CONTRADICTORY CONTINUITY FAILURE EVIDENCE ==="
failure_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='investigate-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='classify-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='investigate-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-phase-3-attention-management-closure-readiness.sh' \
    'lost concern|lost question|dropped concern|dropped question|failed to resume|unable to resume|attention continuity failure' \
    docs server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$failure_refs" ]]; then
  echo "STOP: contradictory Attention continuity-failure evidence requires investigation before closure:"
  printf '%s\n' "$failure_refs"
  exit 2
fi

echo "NO_CONTRADICTORY_CONTINUITY_FAILURE_EVIDENCE"

cat <<'FINDINGS'

Phase 3 — Attention Management closure-readiness classification:

1. Phase 3 began as an architectural responsibility question rather than an
   authorized implementation corridor.

2. Current-state reconciliation established that Phase 3 implementation had
   not started and that neither Phase 1 nor Phase 2 should be reopened.

3. Responsibility-boundary investigation found no repository-supported need
   for multiple simultaneously active investigations.

4. The bounded architecture continues to permit at most one active
   investigation per conversation.

5. Investigation Lifecycle already provides Matilda-authored positive semantic
   representation of the currently governing investigation.

6. Durable IEL-derived and Living Draft representations already preserve
   unresolved questions, uncertainty, evidence lineage, observations, and
   other semantic material that may remain valid without governing the
   immediate collaboration.

7. The only residual Attention candidate was therefore the distinction between
   currently-governing semantic material and preserved-but-not-currently-
   governing semantic material.

8. The minimum semantic-distinction investigation found no demonstrated
   continuity failure caused by the absence of a separate Attention state.

9. The subsequent classification established that the residual distinction is
   relationally represented by existing semantics:

       CURRENTLY_GOVERNING
       = governing Investigation Lifecycle

       PRESERVED_BUT_NOT_CURRENTLY_GOVERNING
       = durably preserved unresolved semantic material that is not the
         governing Investigation Lifecycle

10. No additional semantic fact is required to represent that distinction.

11. No structured-response extension is required.

12. No persistence or database extension is required.

13. No workflow extension is required.

14. No Conversation Context Runtime extension is required.

15. No prompt extension is required.

16. No deterministic validation extension is required.

17. No additional model invocation is required.

18. No production runtime implementation surface remains justified for Phase 3
    under current repository evidence.

19. Implementing a separate Attention artifact now would duplicate established
    semantic ownership rather than close a demonstrated capability gap.

20. Phase 3 therefore satisfies its intended bounded responsibility through the
    composition of already-established capabilities.

21. Closure does not claim that every conceivable future Attention Management
    use case is impossible.

22. Closure means only that no unresolved repository-supported Phase 3
    responsibility remains under the current architecture.

23. A future contradictory use case must reopen Attention Management through a
    new evidence-first investigation.

24. Valid reopening evidence includes:
       - a requirement for multiple simultaneously active investigations;
       - demonstrated loss of preserved non-governing semantic material;
       - inability to recover a still-valid concern when it becomes relevant;
       - independently meaningful suspension, deferral, priority, or resumption
         semantics not representable relationally;
       - a demonstrated ambiguity about which investigation currently governs.

25. Hypothetical future convenience is not sufficient reopening evidence.

26. Phase 1 Response Composition remains closed.

27. Phase 2 Investigation Lifecycle remains closed.

28. Phase 3 Attention Management is ready to close without implementation.

Closure boundary:

Do not implement an Attention artifact.

Do not add Attention fields to the structured response.

Do not add Attention persistence.

Do not add Attention workflow behavior.

Do not add Attention state to Conversation Context Runtime.

Do not add Attention prompt behavior.

Do not introduce concurrent active investigations.

Do not infer priority from chronology, retrieval order, selectedHistory order,
evidence order, or persistence order.

Do not reopen Phase 1.

Do not reopen Phase 2.

Preserve:

Matilda
= semantic Interpretation Authority

Investigation Lifecycle
= positive semantic ownership of the governing investigation

durable unresolved semantic material
= preservation of valid meaning that need not currently govern

Attention Management
= relational composition of existing semantic capabilities under the current
  bounded architecture

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_CLOSURE_READINESS_CLASSIFIED"
echo "PHASE_3_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_3_IMPLEMENTATION_PERFORMED=NO"
echo "PHASE_3_RESIDUAL_SEMANTIC_GAP=NONE_ESTABLISHED"
echo "ATTENTION_MANAGEMENT_REPRESENTATION=RELATIONAL_EXISTING_SEMANTICS"
echo "GOVERNING_ATTENTION_OWNER=INVESTIGATION_LIFECYCLE"
echo "NON_GOVERNING_VALID_MATERIAL=PRESERVED_DURABLE_SEMANTIC_MATERIAL"
echo "NEW_STRUCTURED_RESPONSE_CONTRACT=NONE"
echo "NEW_PERSISTENCE=NONE"
echo "NEW_WORKFLOW_BEHAVIOR=NONE"
echo "NEW_CONTEXT_RUNTIME_STATE=NONE"
echo "NEW_PROMPT_BEHAVIOR=NONE"
echo "NEW_MODEL_INVOCATION=NONE"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_CLOSURE_READINESS=CONFIRMED"
echo "NEXT_ACTION=CLOSE_PHASE_3_ATTENTION_MANAGEMENT"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts
then
  echo "STOP: production runtime changed during Phase 3 closure-readiness classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-attention-management-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 3 closure-readiness classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-3-attention-management-closure-readiness.sh
git diff --cached --check
git commit -m "Classify Phase 3 Attention Management closure readiness"
git push
