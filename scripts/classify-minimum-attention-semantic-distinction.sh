#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY MINIMUM ATTENTION SEMANTIC DISTINCTION ==="

REQUIRED_ANCESTOR="0f8c4917"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: minimum Attention semantic-distinction investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-minimum-attention-semantic-distinction\.sh$|^ M scripts/classify-minimum-attention-semantic-distinction\.sh$' ||
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
  'MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_INVESTIGATED|GOVERNING_INVESTIGATION_POSITIVELY_REPRESENTED=YES|NON_GOVERNING_UNRESOLVED_MATERIAL_DURABLY_PRESERVABLE=YES|MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO|ATTENTION_DISTINCTION_CANDIDATE=RELATIONAL_EXISTING_SEMANTICS|NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NOT_ESTABLISHED|ACTUAL_CONTINUITY_FAILURE_REQUIRED_BEFORE_NEW_SEMANTIC_FACT=YES|NEXT_ACTION=CLASSIFY_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION' \
  scripts/investigate-minimum-attention-semantic-distinction.sh

echo
echo "=== VERIFY GOVERNING INVESTIGATION REPRESENTATION ==="
grep -nE -C 8 \
  'investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination' \
  scripts/utils/ollamaChat.ts |
head -n 900

echo
echo "=== VERIFY GOVERNING SEMANTIC CONTRACT ==="
grep -nE -C 8 \
  'governing investigation|governing question|one active investigation|at most one active investigation|concurrent active investigations' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts.sh |
head -n 1200

echo
echo "=== VERIFY DURABLE NON-GOVERNING PRESERVATION ==="
grep -RInE -C 6 \
  'unresolved_questions|unresolved questions|Preserve uncertainty|Preserve unresolved|current best understanding' \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_RUNTIME_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_VALIDATED_2026-07-05.md |
head -n 1500

echo
echo "=== VERIFY DEFERRED RECONCILIATION EVIDENCE ==="
grep -nE -C 10 \
  'Preservation mechanisms were established|deferred reconciliation|open questions|corridor artifacts' \
  docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md |
head -n 800 || true

echo
echo "=== VERIFY NO ESTABLISHED ATTENTION ARTIFACT ==="
attention_runtime_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='classify-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='investigate-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='investigate-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-minimum-attention-semantic-distinction.sh' \
    'attentionLifecycle|attentionState|attentionStatus|attentionPriority|currentAttention|attentionDetermination' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$attention_runtime_refs" ]]; then
  echo "STOP: repository contains a possible established Attention runtime artifact requiring reclassification:"
  printf '%s\n' "$attention_runtime_refs"
  exit 2
fi

echo "NO_ESTABLISHED_ATTENTION_RUNTIME_ARTIFACT"

echo
echo "=== VERIFY NO EVIDENCED ATTENTION CONTINUITY FAILURE ==="
failure_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='investigate-minimum-attention-semantic-distinction.sh' \
    --exclude='classify-minimum-attention-semantic-distinction.sh' \
    --exclude='investigate-phase-3-attention-management-responsibility-boundary.sh' \
    --exclude='classify-phase-3-attention-management-responsibility-boundary.sh' \
    'lost concern|lost question|dropped concern|dropped question|failed to resume|unable to resume|cannot resume.*unresolved|attention continuity failure' \
    docs server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$failure_refs" ]]; then
  echo "STOP: repository contains possible evidence of an actual Attention continuity failure:"
  printf '%s\n' "$failure_refs"
  exit 2
fi

echo "NO_EVIDENCED_ATTENTION_CONTINUITY_FAILURE"

cat <<'FINDINGS'

Phase 3 — Minimum Attention Semantic Distinction classification:

1. The governing Investigation Lifecycle artifact already provides the positive
   semantic representation required to identify the investigation currently
   governing collaboration.

2. That representation is Matilda-authored and includes investigationIdentity,
   governingQuestion, lifecycleEvent, and lifecycleDetermination.

3. The current bounded architecture permits at most one active investigation
   per conversation.

4. Therefore there is no unresolved choice among multiple simultaneously active
   Investigation Lifecycle artifacts requiring an additional Attention
   selection mechanism.

5. IEL-derived durable representations already preserve unresolved questions,
   uncertainty, observations, evidence lineage, and other semantic material
   that may remain valid beyond the immediate conversational moment.

6. Living Draft and reconciled representations likewise preserve unresolved
   questions without requiring those questions to govern the immediate
   collaboration.

7. Collaboration evidence establishes that preservation makes deferred
   reconciliation viable.

8. Repository evidence does not establish that every preserved unresolved
   concern must carry an explicit attention state.

9. Repository evidence does not establish that preserved unresolved concerns
   must remain active Investigation Lifecycle artifacts.

10. Repository evidence does not establish a need for priority, suspension,
    deferral, or resumption states attached to each preserved concern.

11. Repository evidence does not establish a deterministic runtime
    responsibility to choose among preserved unresolved concerns.

12. Repository evidence does not establish an actual continuity failure caused
    by the absence of a separate Attention semantic artifact.

13. The candidate distinction can therefore be represented relationally:

       CURRENTLY_GOVERNING
       = the Matilda-authored governing Investigation Lifecycle artifact

       PRESERVED_BUT_NOT_CURRENTLY_GOVERNING
       = valid unresolved semantic material that remains durably preserved but
         is not represented as the governing Investigation Lifecycle artifact

14. This relational distinction does not require a second semantic status.

15. Explicit negative attention state for every preserved concern would
    duplicate information already implied by the single-governing-investigation
    boundary.

16. Adding an Attention artifact without a demonstrated semantic ambiguity would
    increase state complexity without adding established semantic information.

17. Absence of a convenience representation is not a missing capability.

18. Absence of a "deferred" lifecycle event is not a missing capability.

19. resolved, superseded, and abandoned remain Investigation Lifecycle events
    and must not be repurposed as generic Attention states.

20. selectedHistory remains conversation-history eligibility selection.

21. selectedContextSegments remains project-context semantic admission.

22. Adaptive Detail Selection remains response-detail composition.

23. Investigation Lifecycle remains semantic investigation continuity.

24. No separate Phase 3 Attention Management semantic fact is currently
    required by repository evidence.

25. No Phase 3 structured-response extension is required.

26. No Phase 3 persistence extension is required.

27. No Phase 3 workflow extension is required.

28. No Phase 3 Conversation Context Runtime extension is required.

29. No Phase 3 prompt extension is required.

30. No Phase 3 deterministic validation responsibility is required.

31. No additional model invocation is required.

32. Phase 3 therefore has no remaining repository-supported implementation
    surface under the currently established bounded architecture.

33. A future contradictory use case may reopen Attention Management only if
    concrete evidence establishes at least one of:

       - multiple simultaneously active investigations are required;
       - preserved unresolved material cannot be recovered when needed;
       - governing Investigation Lifecycle state cannot identify current
         semantic attention;
       - preserved concerns require independently meaningful semantic
         suspension, deferral, priority, or resumption state;
       - an actual continuity failure cannot be represented or repaired through
         the existing Investigation Lifecycle and durable preservation model.

34. Such a future case must begin as a new investigation rather than silently
    expanding the current Phase 3 scope.

35. Under current evidence, Phase 3 Attention Management is satisfied by the
    composition of already-established capabilities rather than a new runtime.

36. Phase 1 Response Composition remains closed.

37. Phase 2 Investigation Lifecycle remains closed.

38. Phase 3 is ready for closure classification without implementation.

Do not implement an Attention artifact.

Do not add an Attention schema.

Do not add an Attention vocabulary.

Do not add persistence.

Do not add prompt instructions.

Do not alter Investigation Lifecycle.

Do not alter selectedHistory.

Do not alter selectedContextSegments.

Do not alter Conversation Context Runtime.

Do not introduce concurrent investigations.

Do not infer priority from chronology or retrieval ordering.

Do not add model invocations.

Preserve:

Matilda
= semantic Interpretation Authority

governing Investigation Lifecycle
= positive representation of current semantic governance

durably preserved unresolved material
= valid semantic material that may remain available without currently governing

Phase 3 Attention Management
= satisfied under current evidence by the relational composition of existing
  capabilities

Runtime
= no new Phase 3 responsibility currently justified

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_CLASSIFIED"
echo "CURRENTLY_GOVERNING_REPRESENTATION=GOVERNING_INVESTIGATION_LIFECYCLE"
echo "PRESERVED_NON_GOVERNING_REPRESENTATION=DURABLE_UNRESOLVED_SEMANTIC_MATERIAL"
echo "ATTENTION_DISTINCTION=RELATIONAL_EXISTING_SEMANTICS"
echo "NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NO"
echo "NEW_ATTENTION_STRUCTURED_RESPONSE_FIELD_REQUIRED=NO"
echo "NEW_ATTENTION_PERSISTENCE_REQUIRED=NO"
echo "NEW_ATTENTION_WORKFLOW_REQUIRED=NO"
echo "NEW_ATTENTION_CONTEXT_RUNTIME_REQUIRED=NO"
echo "NEW_ATTENTION_PROMPT_REQUIRED=NO"
echo "NEW_ATTENTION_DETERMINISTIC_VALIDATION_REQUIRED=NO"
echo "MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO"
echo "PHASE_3_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_3_CLOSURE_READINESS=READY_FOR_CLASSIFICATION"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_3_ATTENTION_MANAGEMENT_CLOSURE_READINESS"

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
  echo "STOP: production runtime changed during minimum Attention semantic-distinction classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-minimum-attention-semantic-distinction\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside minimum Attention semantic-distinction classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-minimum-attention-semantic-distinction.sh
git diff --cached --check
git commit -m "Classify minimum Attention Management semantic distinction"
git push
