#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 4 RESIDUAL GOVERNANCE RESPONSIBILITY ==="

REQUIRED_ANCESTOR="a637dfa7"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 residual-governance investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-phase-4-residual-governance-responsibility\.sh$|^ M scripts/classify-phase-4-residual-governance-responsibility\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING RESIDUAL-GOVERNANCE INVESTIGATION ==="
grep -nE \
  'PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY_INVESTIGATED|COLLABORATION_AUTHORIZATION_CANDIDATE=NO_RUNTIME_REQUIREMENT_ESTABLISHED|GENERIC_GOVERNANCE_ARTIFACT=NOT_JUSTIFIED|NEW_GOVERNANCE_SEMANTIC_FACT=NOT_ESTABLISHED|NEW_GOVERNANCE_RUNTIME_CONSUMER=NOT_ESTABLISHED|NEW_GOVERNANCE_PERSISTENCE=NOT_ESTABLISHED|PHASE_4_IMPLEMENTATION=NOT_AUTHORIZED|NEXT_ACTION=CLASSIFY_PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY' \
  scripts/investigate-phase-4-residual-governance-responsibility.sh

echo
echo "=== VERIFY COLLABORATION-AUTHORIZATION CANDIDATE REMAINS ELIMINATED ==="
grep -nE \
  'PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_CLASSIFIED|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE|DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=ABSENT|DEDICATED_COLLABORATION_AUTHORIZATION_PERSISTENCE=NOT_JUSTIFIED|SCOPE_AND_IMPLEMENTATION_AUTHORIZATION=REMAIN_DISTINCT|DOWNSTREAM_EXECUTION_GOVERNANCE=REMAINS_SEPARATE' \
  scripts/classify-phase-4-collaboration-authorization-boundary.sh

echo
echo "=== VERIFY USER CORRECTION / HISTORY AUTHORITY OWNERSHIP ==="
grep -RInE -C 6 \
  'Preserve user corrections and explicit reversals|ineligible_superseded|detected_superseded_context|eligible|contamination|supersession' \
  docs/governance/CANDIDATE_CONVERSATION_CONTEXT_RUNTIME.md \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  2>/dev/null |
head -n 1800 || true

echo
echo "=== VERIFY LIVING DRAFT / APPROVAL AUTHORITY BOUNDARY ==="
grep -RInE -C 6 \
  'Living Draft|non-authoritative|explicit approval|Matilda may not self-approve|Matilda may not create a Package without explicit approval|Creation of a Canonical Package does not itself authorize downstream execution' \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_SCOPE_2026-07-04.md \
  docs/governance/MATILDA_CANONICAL_PACKAGE_APPROVAL_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_RUNTIME_VALIDATED_2026-07-05.md \
  2>/dev/null |
head -n 1800 || true

echo
echo "=== VERIFY DOWNSTREAM AUTHORITY SEPARATION ==="
grep -RInE -C 6 \
  'delegation_authorized|validation_authorized|envelope_authorized|execution_authorized|new_authority_introduced|Implicit approval is forbidden|Standing approval is forbidden|Approval reuse is forbidden' \
  server/delegation \
  server/envelope \
  server/gate \
  server/execution \
  docs/contracts/CANONICAL_EXECUTION_DOCTRINE_V1.md \
  db/governance-runtime.ts \
  db/governance-lifecycle-persistence.ts \
  2>/dev/null |
head -n 2200 || true

echo
echo "=== FALSIFICATION — SEARCH FOR UNOWNED PHASE 4 PRODUCTION RESPONSIBILITY ==="
unowned_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    --exclude='classify-phase-4-governance-current-state.sh' \
    --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='classify-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='investigate-phase-4-residual-governance-responsibility.sh' \
    --exclude='classify-phase-4-residual-governance-responsibility.sh' \
    'CollaborationGovernance|collaborationGovernance|collaboration_governance|MatildaGovernanceArtifact|MatildaCollaborationGovernance|governanceDetermination|governanceDecision|implementation_authorized|implementationAuthorized|collaboration_authorized|collaborationAuthorized|userAuthorization|user_authorization' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$unowned_refs" ]]; then
  echo "STOP: possible unowned Phase 4 production governance responsibility found:"
  printf '%s\n' "$unowned_refs"
  exit 2
fi

echo "NO_UNOWNED_PHASE_4_PRODUCTION_GOVERNANCE_RUNTIME_FOUND"

cat <<'CLASSIFICATION'

Phase 4 — Residual Governance Responsibility classification:

1. The collaboration-authorization candidate has been investigated and
   classified.

2. No current repository evidence establishes a dedicated production consumer
   for collaboration-authorization state.

3. Therefore that candidate does not justify a new Phase 4 runtime artifact,
   persistence surface, prompt extension, workflow extension, or structured
   response field.

4. User correction and challenge authority remain grounded in current user
   intent.

5. Superseded or contaminated historical semantic material is already governed
   by interpretation lifecycle, authority evaluation, contamination evaluation,
   and history selection.

6. Therefore Phase 4 does not need a second user-correction or historical
   authority subsystem.

7. Living Draft remains explicitly non-authoritative.

8. Reconciled Intent remains reviewable and non-authoritative until explicit
   approval.

9. Canonical Package creation remains gated by explicit approval.

10. Matilda self-approval is already prohibited.

11. Canonical Package creation does not itself authorize downstream execution.

12. Delegation, Validation, Envelope, and Execution remain separate downstream
    governance domains with bounded authority and fail-closed behavior.

13. Existing downstream entry points repeatedly preserve false authority flags
    and new_authority_introduced=false where authority is not explicitly granted.

14. Therefore Phase 4 does not need to duplicate downstream organizational
    governance inside the Conversation Engine.

15. Current repository evidence does not identify any production behavior in
    which Matilda exercises authority reserved exclusively to the user.

16. Current repository evidence does not identify any required governance fact
    that is lost between:

       user message
       -> durable interpretation
       -> IEL
       -> conversation turn
       -> Living Draft
       -> Reconciled Intent
       -> Approval Request
       -> Canonical Package

17. No missing Phase 4 semantic fact with a concrete production consumer has
    been identified.

18. No missing Phase 4 deterministic validator with an explicit unowned
    invariant has been identified.

19. No missing Phase 4 persistence field preserving otherwise-lost authority has
    been identified.

20. A generic Collaboration Governance artifact would therefore duplicate
    existing authority boundaries rather than close a demonstrated capability
    gap.

21. The repository-supported collaboration-governance responsibilities are
    already distributed across established owners:

       User
       = Intent Authority

       Matilda
       = Interpretation Authority

       Interpretation Lifecycle / History Authority / Contamination
       = historical semantic validity protection

       Living Draft
       = non-authoritative derived collaboration state

       Reconciled Intent
       = reviewable pre-approval intent representation

       Approval
       = explicit transition toward authoritative Package creation

       Canonical Package
       = authoritative approved package

       Delegation / Validation / Envelope / Execution
       = separate downstream governance authorities

22. Phase 4 therefore does not require a new centralized governance runtime
    merely to restate those existing authority boundaries.

23. No repository-supported residual Phase 4 production capability gap remains
    established after falsification.

24. Phase 4 implementation is therefore not required under the current bounded
    architecture.

25. This classification does not prohibit a future governance capability.

26. Phase 4 may be reopened only if contradictory repository or runtime evidence
    demonstrates an unowned governance responsibility with:

       - a concrete semantic or deterministic consumer;
       - an authority fact not already preserved;
       - an explicit invariant not already enforced;
       - or an actual collaboration-governance failure not representable by
         existing architecture.

27. Hypothetical convenience, centralized representation, or naming symmetry is
    insufficient reopening evidence.

28. Phase 1 Response Composition remains closed.

29. Phase 2 Investigation Lifecycle remains closed.

30. Phase 3 Attention Management remains closed.

31. Phase 4 Collaboration Governance has no established implementation surface
    remaining.

32. Phase 4 is ready for closure-readiness classification.

CLASSIFICATION

echo
echo "PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY_CLASSIFIED"
echo "USER_CORRECTION_AUTHORITY=ALREADY_OWNED"
echo "HISTORICAL_AUTHORITY_AND_CONTAMINATION=ALREADY_OWNED"
echo "LIVING_DRAFT_NON_AUTHORITY=ALREADY_OWNED"
echo "EXPLICIT_PACKAGE_APPROVAL_BOUNDARY=ALREADY_OWNED"
echo "MATILDA_SELF_APPROVAL_PROHIBITION=ALREADY_ESTABLISHED"
echo "DOWNSTREAM_AUTHORITY_SEPARATION=ALREADY_OWNED"
echo "COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE"
echo "GENERIC_GOVERNANCE_ARTIFACT_REQUIRED=NO"
echo "NEW_GOVERNANCE_SEMANTIC_FACT_REQUIRED=NO_CURRENT_EVIDENCE"
echo "NEW_GOVERNANCE_RUNTIME_CONSUMER=NONE_ESTABLISHED"
echo "NEW_GOVERNANCE_PERSISTENCE_REQUIRED=NO_CURRENT_EVIDENCE"
echo "PHASE_4_RESIDUAL_PRODUCTION_CAPABILITY_GAP=NONE_ESTABLISHED"
echo "PHASE_4_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_4_CLOSURE_READINESS=READY_FOR_CLASSIFICATION"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_4_GOVERNANCE_CLOSURE_READINESS"

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
  echo "STOP: production runtime changed during Phase 4 residual-governance classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-4-residual-governance-responsibility\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 residual-governance classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-4-residual-governance-responsibility.sh
git diff --cached --check
git commit -m "Classify Phase 4 residual governance responsibility"
git push
