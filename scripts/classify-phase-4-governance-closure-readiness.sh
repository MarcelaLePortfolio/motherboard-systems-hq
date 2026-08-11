#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 4 GOVERNANCE CLOSURE READINESS ==="

REQUIRED_ANCESTOR="246e665b"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 residual-governance classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-4-governance-closure-readiness\.sh$|^ M scripts/classify-phase-4-governance-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY RESIDUAL GOVERNANCE CLASSIFICATION ==="
grep -nE \
  'PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY_CLASSIFIED|USER_CORRECTION_AUTHORITY=ALREADY_OWNED|HISTORICAL_AUTHORITY_AND_CONTAMINATION=ALREADY_OWNED|LIVING_DRAFT_NON_AUTHORITY=ALREADY_OWNED|EXPLICIT_PACKAGE_APPROVAL_BOUNDARY=ALREADY_OWNED|MATILDA_SELF_APPROVAL_PROHIBITION=ALREADY_ESTABLISHED|DOWNSTREAM_AUTHORITY_SEPARATION=ALREADY_OWNED|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE|GENERIC_GOVERNANCE_ARTIFACT_REQUIRED=NO|PHASE_4_RESIDUAL_PRODUCTION_CAPABILITY_GAP=NONE_ESTABLISHED|PHASE_4_IMPLEMENTATION_REQUIRED=NO|PHASE_4_CLOSURE_READINESS=READY_FOR_CLASSIFICATION|NEXT_ACTION=CLASSIFY_PHASE_4_GOVERNANCE_CLOSURE_READINESS' \
  scripts/classify-phase-4-residual-governance-responsibility.sh

echo
echo "=== VERIFY COLLABORATION AUTHORIZATION CLASSIFICATION ==="
grep -nE \
  'PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_CLASSIFIED|USER_AUTHORIZATION_AUTHORITY=PRESERVED|MATILDA_SELF_AUTHORIZATION=FORBIDDEN|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE|DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=ABSENT|DEDICATED_COLLABORATION_AUTHORIZATION_PERSISTENCE=NOT_JUSTIFIED|SCOPE_AND_IMPLEMENTATION_AUTHORIZATION=REMAIN_DISTINCT|DOWNSTREAM_EXECUTION_GOVERNANCE=REMAINS_SEPARATE' \
  scripts/classify-phase-4-collaboration-authorization-boundary.sh

echo
echo "=== VERIFY PHASE 1-3 CLOSURE LINEAGE ==="
git merge-base --is-ancestor c0934a3b HEAD || {
  echo "STOP: Phase 2 closure checkpoint c0934a3b is not an ancestor of HEAD."
  exit 2
}

git merge-base --is-ancestor 3320b0ed HEAD || {
  echo "STOP: Phase 3 closure checkpoint 3320b0ed is not an ancestor of HEAD."
  exit 2
}

git show -s --format='%h %s' c0934a3b
git show -s --format='%h %s' 3320b0ed

echo
echo "=== FALSIFICATION — SEARCH FOR UNRESOLVED PHASE 4 IMPLEMENTATION REQUIREMENT ==="
phase4_gap_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    --exclude='classify-phase-4-governance-current-state.sh' \
    --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='classify-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='investigate-phase-4-residual-governance-responsibility.sh' \
    --exclude='classify-phase-4-residual-governance-responsibility.sh' \
    --exclude='classify-phase-4-governance-closure-readiness.sh' \
    'PHASE_4.*(BLOCKED|INCOMPLETE)|PHASE_4_.*GAP=|NEXT_(ACTION|UNIT)=.*IMPLEMENT.*GOVERNANCE|COLLABORATION_GOVERNANCE.*IMPLEMENTATION_REQUIRED=YES|GENERIC_GOVERNANCE_ARTIFACT_REQUIRED=YES' \
    docs scripts server db 2>/dev/null ||
  true
)"

if [[ -n "$phase4_gap_refs" ]]; then
  echo "STOP: possible unresolved Phase 4 implementation requirement found:"
  printf '%s\n' "$phase4_gap_refs"
  exit 2
fi

echo "NO_UNRESOLVED_PHASE_4_IMPLEMENTATION_REQUIREMENT_FOUND"

echo
echo "=== VERIFY NO DEDICATED PHASE 4 RUNTIME WAS INTRODUCED ==="
phase4_runtime_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    --exclude='classify-phase-4-governance-current-state.sh' \
    --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='classify-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='investigate-phase-4-residual-governance-responsibility.sh' \
    --exclude='classify-phase-4-residual-governance-responsibility.sh' \
    --exclude='classify-phase-4-governance-closure-readiness.sh' \
    'CollaborationGovernance|collaborationGovernance|collaboration_governance|MatildaGovernanceArtifact|MatildaCollaborationGovernance|governanceDetermination|governanceDecision|implementationAuthorized|collaborationAuthorized|userAuthorization' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$phase4_runtime_refs" ]]; then
  echo "STOP: possible dedicated Phase 4 runtime surface exists:"
  printf '%s\n' "$phase4_runtime_refs"
  exit 2
fi

echo "NO_DEDICATED_PHASE_4_RUNTIME_SURFACE"

cat <<'CLASSIFICATION'

Phase 4 — Collaboration Governance closure-readiness classification:

1. Phase 4 began as an investigation into whether the Matilda Conversation
   Engine required an additional collaboration-governance responsibility.

2. Current-state reconciliation established that substantial governance already
   exists downstream, but belongs to separate organizational authority domains.

3. Phase 4 therefore correctly avoided treating existing Package, Delegation,
   Validation, Envelope, and Execution governance as missing Conversation
   Engine capability.

4. The first residual candidate was user-authored collaboration authorization.

5. Investigation and classification established that no dedicated production
   consumer, persistence requirement, or deterministic Conversation Engine
   behavior currently requires a collaboration-authorization artifact.

6. Explicit user authorization remains authoritative conversational evidence and
   an engineering operating boundary.

7. Matilda may interpret that evidence but may not manufacture, broaden, reuse,
   or self-grant authorization.

8. Collaboration authorization remains separate from downstream organizational
   execution authorization.

9. The residual-governance investigation then tested whether another unowned
   Phase 4 responsibility remained.

10. User correction and challenge remain owned by current user Intent Authority
    and established conversation / interpretation behavior.

11. Superseded or contaminated historical semantic material is already governed
    by Interpretation Lifecycle, History Authority, Contamination Evaluation,
    and History Selection.

12. Living Draft non-authority is already explicitly established.

13. Reconciled Intent remains reviewable and pre-authoritative.

14. Explicit approval already gates Canonical Package creation.

15. Matilda self-approval is already prohibited.

16. Canonical Package creation does not authorize downstream execution.

17. Delegation, Validation, Envelope, and Execution preserve separate bounded
    authority domains and repeatedly fail closed against unauthorized authority
    broadening.

18. No required governance fact has been shown to disappear across the
    established pipeline:

       user message
       -> durable interpretation
       -> IEL
       -> conversation turn
       -> Living Draft
       -> Reconciled Intent
       -> Approval Request
       -> Canonical Package
       -> downstream governance

19. No unowned Phase 4 semantic fact with a concrete production consumer has
    been identified.

20. No unowned deterministic Phase 4 invariant requiring a new validator has
    been identified.

21. No Phase 4 persistence requirement preserving otherwise-lost authority has
    been identified.

22. No repository-supported residual Phase 4 production capability gap remains
    after falsification.

23. A generic Collaboration Governance artifact would duplicate established
    authority boundaries rather than close a demonstrated gap.

24. Phase 4 therefore requires no new production implementation under the
    current bounded architecture.

25. Closure does not claim that all future governance use cases are already
    solved.

26. Phase 4 may be reopened if future contradictory evidence establishes an
    unowned governance authority fact, concrete production consumer,
    deterministic invariant not already enforced, authority loss across an
    established boundary, unauthorized authority broadening, or an actual
    collaboration-governance failure existing owners cannot represent.

27. Naming symmetry, centralized convenience, or hypothetical future need is
    not sufficient reopening evidence.

28. Phase 1 Response Composition remains closed.

29. Phase 2 Investigation Lifecycle remains closed.

30. Phase 3 Attention Management remains closed.

31. Phase 4 Collaboration Governance is ready to close without implementation.

32. Closing Phase 4 will complete the currently defined Matilda Collaboration
    Runtime four-phase milestone unless contradictory repository evidence
    establishes another governed phase or successor milestone.

CLASSIFICATION

echo
echo "PHASE_4_GOVERNANCE_CLOSURE_READINESS_CLASSIFIED"
echo "PHASE_4_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_4_IMPLEMENTATION_PERFORMED=NO"
echo "PHASE_4_RESIDUAL_PRODUCTION_CAPABILITY_GAP=NONE_ESTABLISHED"
echo "COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE"
echo "GENERIC_GOVERNANCE_ARTIFACT_REQUIRED=NO"
echo "USER_INTENT_AUTHORITY=PRESERVED"
echo "MATILDA_INTERPRETATION_AUTHORITY=PRESERVED"
echo "MATILDA_SELF_AUTHORIZATION=FORBIDDEN"
echo "HISTORICAL_AUTHORITY_PROTECTION=ALREADY_IMPLEMENTED"
echo "LIVING_DRAFT_NON_AUTHORITY=ALREADY_ESTABLISHED"
echo "EXPLICIT_PACKAGE_APPROVAL_BOUNDARY=ALREADY_ESTABLISHED"
echo "DOWNSTREAM_AUTHORITY_SEPARATION=ALREADY_ESTABLISHED"
echo "NEW_SCHEMA=NONE"
echo "NEW_PERSISTENCE=NONE"
echo "NEW_STRUCTURED_RESPONSE_FIELD=NONE"
echo "NEW_PROMPT_BEHAVIOR=NONE"
echo "NEW_WORKFLOW_BEHAVIOR=NONE"
echo "NEW_MODEL_INVOCATION=NONE"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "PHASE_4_CLOSURE_READINESS=CONFIRMED"
echo "NEXT_ACTION=CLOSE_PHASE_4_COLLABORATION_GOVERNANCE"

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
  echo "STOP: production runtime changed during Phase 4 closure-readiness classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-4-governance-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 closure-readiness classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-4-governance-closure-readiness.sh
git diff --cached --check
git commit -m "Classify Phase 4 Collaboration Governance closure readiness"
git push
