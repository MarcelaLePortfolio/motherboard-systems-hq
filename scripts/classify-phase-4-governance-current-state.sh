#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 4 GOVERNANCE CURRENT STATE ==="

REQUIRED_ANCESTOR="22cf3bca"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 current-state reconciliation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-phase-4-governance-current-state\.sh$|^ M scripts/classify-phase-4-governance-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING RECONCILIATION ==="
grep -nE \
  'PHASE_4_GOVERNANCE_CURRENT_STATE_RECONCILED|PHASE_4_GOVERNANCE_IMPLEMENTATION=NOT_STARTED|PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED|PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED|NEXT_ACTION=CLASSIFY_PHASE_4_GOVERNANCE_CURRENT_STATE' \
  scripts/reconcile-phase-4-governance-current-state.sh

echo
echo "=== VERIFY NO DEDICATED COLLABORATION GOVERNANCE RUNTIME ==="
collaboration_governance_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    --exclude='classify-phase-4-governance-current-state.sh' \
    'CollaborationGovernance|collaborationGovernance|collaboration_governance|MatildaGovernanceArtifact|MatildaCollaborationGovernance|governanceDetermination|governanceDecision' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$collaboration_governance_refs" ]]; then
  echo "STOP: possible dedicated Collaboration Governance runtime evidence requires reclassification:"
  printf '%s\n' "$collaboration_governance_refs"
  exit 2
fi

echo "DEDICATED_COLLABORATION_GOVERNANCE_RUNTIME_ABSENT"

echo
echo "=== VERIFY EXISTING GOVERNANCE IS DOWNSTREAM / ORGANIZATIONAL ==="
grep -RInE -C 5 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'governance_packages|governance_delegations|governance_validation_results|governance_envelope_gates|governance_envelopes|execution_authorized|delegation_authorized|validation_authorized|envelope_authorized' \
  db/governance-runtime.ts \
  db/governance-lifecycle-persistence.ts \
  server/delegation \
  server/envelope \
  server/gate \
  server/execution \
  2>/dev/null |
head -n 2200 || true

echo
echo "=== VERIFY CONVERSATION WORKFLOW DOES NOT AUTHORIZE DOWNSTREAM GOVERNANCE ==="
grep -nE -C 8 \
  'canonical_package_created|delegation_authorized|validation_authorized|envelope_authorized|execution_authorized|approval_required' \
  server/matilda-chat-workflow.ts |
head -n 700 || true

echo
echo "=== VERIFY USER / MATILDA AUTHORITY DOCTRINE ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Intent Authority|Interpretation Authority|Living Draft.*non-authoritative|Approval.*authoritative Package|Approval Request|Canonical Package' \
  docs/governance scripts 2>/dev/null |
head -n 1800 || true

echo
echo "=== SEARCH FOR COLLABORATION AUTHORIZATION SEMANTICS ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='classify-phase-4-governance-current-state.sh' \
  --exclude='reconcile-phase-4-governance-current-state.sh' \
  'explicit user authorization|implementation authorization|implementation permission|execution authorization|user authorizes|user authorized|authorization gate|execution gate|collaboration mode|execution mode|Do not begin implementation automatically|implementation explicitly requested' \
  docs scripts server db 2>/dev/null |
head -n 2200 || true

echo
echo "=== SEARCH FOR RUNTIME REPRESENTATION OF USER IMPLEMENTATION AUTHORIZATION ==="
authorization_runtime_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='classify-phase-4-governance-current-state.sh' \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    'implementation_authorized|implementationAuthorized|collaboration_authorized|collaborationAuthorized|execution_mode_authorized|user_authorization|userAuthorization' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$authorization_runtime_refs" ]]; then
  echo "POSSIBLE_COLLABORATION_AUTHORIZATION_RUNTIME_REFERENCES"
  printf '%s\n' "$authorization_runtime_refs"
else
  echo "DEDICATED_COLLABORATION_AUTHORIZATION_RUNTIME_NOT_FOUND"
fi

cat <<'FINDINGS'

Phase 4 — Collaboration Governance current-state classification:

1. No dedicated Collaboration Governance semantic artifact is established by
   current repository evidence.

2. No dedicated Collaboration Governance runtime is established by current
   repository evidence.

3. No dedicated Collaboration Governance persistence is established by current
   repository evidence.

4. The repository contains substantial governance machinery, but that machinery
   belongs to downstream organizational governance:

   - Canonical Package;
   - Delegation;
   - Validation;
   - Envelope Gate;
   - Envelope;
   - Execution.

5. Those downstream systems contain their own bounded authority flags and
   fail-closed behavior.

6. They must not be reclassified as Phase 4 Collaboration Governance merely
   because they use governance terminology.

7. The Conversation Engine remains upstream of those organizational governance
   systems.

8. User remains Intent Authority.

9. Matilda remains Interpretation Authority.

10. Living Draft remains non-authoritative.

11. Approval remains the transition into authoritative Package creation.

12. Matilda must not grant herself implementation, mutation, execution,
    delegation, validation, envelope, or downstream governance authority.

13. Existing collaboration doctrine establishes a meaningful governance
    distinction between:

       collaboration / investigation / planning

    and

       explicitly authorized implementation / execution.

14. That distinction currently exists as operating doctrine and collaboration
    protocol.

15. Current repository evidence does not yet establish a dedicated production
    runtime artifact representing user authorization to cross that boundary.

16. Existing downstream approval_required or execution_authorized fields cannot
    automatically substitute for user–Matilda collaboration authorization
    because they govern different authority domains and occur at different
    architectural stages.

17. Therefore the smallest unresolved Phase 4 question is not organizational
    approval or execution governance.

18. The residual candidate responsibility is:

    USER_AUTHORED_COLLABORATION_AUTHORIZATION

    specifically, whether the Conversation Engine needs a bounded semantic or
    deterministic representation that distinguishes:

       collaboration-only authority

    from

       explicit authorization to begin a bounded implementation action.

19. Such a representation, if required, must remain user-authored in authority.

20. Matilda may interpret whether authorization was expressed, but must not
    manufacture, broaden, or self-grant that authorization.

21. The repository does not yet establish whether conversational intent alone
    is sufficient representation or whether an explicit runtime artifact is
    required.

22. The repository does not yet establish whether authorization must persist
    across turns.

23. The repository does not yet establish whether authorization should be
    single-turn, bounded to an implementation unit, revocable, or represented
    another way.

24. The repository does not yet establish whether scope authorization and
    implementation authorization are one fact or separate facts.

25. The repository does not yet establish whether challenge/correction state
    belongs to Phase 4.

26. No Phase 4 implementation is authorized by this classification.

27. Phase 1 Response Composition remains closed.

28. Phase 2 Investigation Lifecycle remains closed.

29. Phase 3 Attention Management remains closed.

Smallest next unit:

INVESTIGATE_PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY

Determine from repository evidence:

1. Whether explicit user authorization to begin implementation is already
   represented anywhere in production Conversation Engine state.

2. Whether ordinary user intent can safely carry implementation authorization
   without a distinct semantic boundary.

3. Whether authorization must be explicit rather than inferred.

4. Whether authorization is scoped to:

   - one implementation unit;
   - one corridor;
   - one phase;
   - one workflow turn;
   - or another bounded unit.

5. Whether authorization survives across turns.

6. Whether authorization may be revoked or superseded.

7. Whether Matilda may interpret authorization while runtime validates only
   explicit bounded facts.

8. Whether implementation authorization is distinct from downstream approval,
   package authority, delegation authority, and execution authority.

9. Whether a dedicated runtime representation is actually required.

10. What concrete collaboration failure would occur without such a
    representation.

11. What evidence would falsify the need for any new Phase 4 runtime.

Do not implement.

Do not add schema.

Do not add persistence.

Do not change prompts.

Do not alter workflow behavior.

Do not move downstream approval or execution authority upstream.

Do not allow Matilda to self-authorize.

Do not reopen Phases 1–3.

Preserve:

User
= Intent Authority and source of implementation authorization

Matilda
= Interpretation Authority only

downstream governance
= separate organizational authority domain

Phase 4 candidate residual responsibility
= explicit collaboration authorization boundary only if repository evidence
  establishes that existing intent representation is insufficient

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_4_GOVERNANCE_CURRENT_STATE_CLASSIFIED"
echo "DEDICATED_COLLABORATION_GOVERNANCE_ARTIFACT=ABSENT"
echo "DEDICATED_COLLABORATION_GOVERNANCE_RUNTIME=ABSENT"
echo "DEDICATED_COLLABORATION_GOVERNANCE_PERSISTENCE=ABSENT"
echo "DOWNSTREAM_ORGANIZATIONAL_GOVERNANCE=EXISTS_AND_REMAINS_SEPARATE"
echo "USER_INTENT_AUTHORITY=PRESERVED"
echo "MATILDA_INTERPRETATION_AUTHORITY=PRESERVED"
echo "RESIDUAL_CANDIDATE_RESPONSIBILITY=USER_AUTHORED_COLLABORATION_AUTHORIZATION"
echo "COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=UNDETERMINED"
echo "PHASE_4_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_UNIT=INVESTIGATE_PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY"

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
  echo "STOP: production runtime changed during Phase 4 current-state classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-4-governance-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-4-governance-current-state.sh
git diff --cached --check
git commit -m "Classify Phase 4 Collaboration Governance current state"
git push
