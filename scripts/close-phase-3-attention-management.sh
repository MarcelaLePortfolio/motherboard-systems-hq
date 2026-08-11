#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLOSE PHASE 3 ATTENTION MANAGEMENT ==="

REQUIRED_ANCESTOR="623544a0"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 closure-readiness checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
echo "=== VERIFY CLOSURE-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-phase-3-attention-management\.sh$|^ M scripts/close-phase-3-attention-management\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLOSURE_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 3 CLOSURE AUTHORIZATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_CLOSURE_READINESS_CLASSIFIED|PHASE_3_IMPLEMENTATION_REQUIRED=NO|PHASE_3_IMPLEMENTATION_PERFORMED=NO|PHASE_3_RESIDUAL_SEMANTIC_GAP=NONE_ESTABLISHED|ATTENTION_MANAGEMENT_REPRESENTATION=RELATIONAL_EXISTING_SEMANTICS|PHASE_3_CLOSURE_READINESS=CONFIRMED|NEXT_ACTION=CLOSE_PHASE_3_ATTENTION_MANAGEMENT' \
  scripts/classify-phase-3-attention-management-closure-readiness.sh

echo
echo "=== VERIFY MINIMUM ATTENTION CLASSIFICATION ==="
grep -nE \
  'MINIMUM_ATTENTION_SEMANTIC_DISTINCTION_CLASSIFIED|CURRENTLY_GOVERNING_REPRESENTATION=GOVERNING_INVESTIGATION_LIFECYCLE|PRESERVED_NON_GOVERNING_REPRESENTATION=DURABLE_UNRESOLVED_SEMANTIC_MATERIAL|NEW_ATTENTION_SEMANTIC_FACT_REQUIRED=NO|PHASE_3_IMPLEMENTATION_REQUIRED=NO' \
  scripts/classify-minimum-attention-semantic-distinction.sh

echo
echo "=== VERIFY PHASE 2 CLOSURE ==="
git merge-base --is-ancestor c0934a3b HEAD || {
  echo "STOP: verified Phase 2 closure checkpoint c0934a3b is not an ancestor of HEAD."
  exit 2
}

git show -s --format='%h %s' c0934a3b

echo
echo "=== VERIFY NO PHASE 3 RUNTIME IMPLEMENTATION WAS INTRODUCED ==="
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
    --exclude='close-phase-3-attention-management.sh' \
    'attentionLifecycle|attentionState|attentionStatus|attentionPriority|currentAttention|attentionDetermination' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$attention_runtime_refs" ]]; then
  echo "STOP: Phase 3 runtime implementation surface exists:"
  printf '%s\n' "$attention_runtime_refs"
  exit 2
fi

echo "NO_PHASE_3_RUNTIME_IMPLEMENTATION"

cat <<'FINDINGS'

Phase 3 — Attention Management closure:

1. Phase 3 current-state reconciliation established that implementation had not
   started.

2. Responsibility-boundary investigation established that the current bounded
   architecture does not require multiple simultaneously active investigations.

3. Investigation Lifecycle already provides the positive Matilda-authored
   semantic representation of the investigation governing current attention.

4. Existing durable semantic representations preserve unresolved questions,
   uncertainty, observations, evidence lineage, and other valid material that
   need not currently govern collaboration.

5. Minimum Attention semantic-distinction investigation tested whether a
   separate semantic representation was required to distinguish governing from
   preserved non-governing material.

6. Classification established that this distinction is already represented
   relationally by existing semantics.

7. No separate Attention semantic fact is required.

8. No Attention structured-response field is required.

9. No Attention persistence is required.

10. No Attention workflow behavior is required.

11. No Attention Conversation Context Runtime state is required.

12. No Attention prompt behavior is required.

13. No Attention deterministic validation responsibility is required.

14. No additional model invocation is required.

15. No repository-supported residual semantic gap remains in Phase 3.

16. Therefore Phase 3 requires no production implementation under the current
    bounded architecture.

17. Phase 3 is complete through validated architectural composition rather than
    through introduction of a new runtime subsystem.

18. This closure preserves the single-governing-investigation constraint.

19. This closure preserves Matilda as semantic Interpretation Authority.

20. This closure preserves Investigation Lifecycle as the semantic owner of
    governing investigative continuity.

21. This closure preserves durable unresolved semantic material without
    requiring it to carry a separate Attention status.

22. This closure does not authorize priority, suspension, deferral, resumption,
    or concurrent-investigation semantics.

23. A future contradictory use case may reopen Attention Management only through
    a new evidence-first investigation.

24. Phase 1 Response Composition remains closed.

25. Phase 2 Investigation Lifecycle remains closed.

26. Phase 3 Attention Management is now closed.

Preserve:

Matilda
= semantic Interpretation Authority

Investigation Lifecycle
= positive semantic ownership of the governing investigation

durably preserved unresolved material
= valid semantic material that may remain available without currently governing

Attention Management
= satisfied by relational composition of established capabilities

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_COMPLETE"
echo "PHASE_3_ATTENTION_MANAGEMENT_STATUS=CLOSED"
echo "PHASE_3_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_3_IMPLEMENTATION_PERFORMED=NO"
echo "PHASE_3_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE"
echo "ATTENTION_MANAGEMENT_REPRESENTATION=RELATIONAL_EXISTING_SEMANTICS"
echo "GOVERNING_ATTENTION_OWNER=INVESTIGATION_LIFECYCLE"
echo "NON_GOVERNING_VALID_MATERIAL=PRESERVED_DURABLE_SEMANTIC_MATERIAL"
echo "MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT=CLOSED"
echo "NEXT_ACTION=RECONCILE_PHASE_4_GOVERNANCE_CURRENT_STATE"

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
  echo "STOP: production runtime changed during Phase 3 closure."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLOSURE-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-phase-3-attention-management\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 3 closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLOSURE_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/close-phase-3-attention-management.sh
git diff --cached --check
git commit -m "Close Phase 3 Attention Management"
git push
