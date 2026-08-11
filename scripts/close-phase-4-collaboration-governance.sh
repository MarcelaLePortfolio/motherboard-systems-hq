#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLOSE PHASE 4 COLLABORATION GOVERNANCE ==="

REQUIRED_ANCESTOR="722b033e"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 closure-readiness checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/close-phase-4-collaboration-governance\.sh$|^ M scripts/close-phase-4-collaboration-governance\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLOSURE_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 4 CLOSURE AUTHORIZATION ==="
grep -nE \
  'PHASE_4_GOVERNANCE_CLOSURE_READINESS_CLASSIFIED|PHASE_4_IMPLEMENTATION_REQUIRED=NO|PHASE_4_IMPLEMENTATION_PERFORMED=NO|PHASE_4_RESIDUAL_PRODUCTION_CAPABILITY_GAP=NONE_ESTABLISHED|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE|GENERIC_GOVERNANCE_ARTIFACT_REQUIRED=NO|PHASE_4_CLOSURE_READINESS=CONFIRMED|NEXT_ACTION=CLOSE_PHASE_4_COLLABORATION_GOVERNANCE' \
  scripts/classify-phase-4-governance-closure-readiness.sh

echo
echo "=== VERIFY PRIOR PHASE CLOSURES ==="
git merge-base --is-ancestor c0934a3b HEAD || {
  echo "STOP: Phase 2 closure checkpoint is not an ancestor of HEAD."
  exit 2
}

git merge-base --is-ancestor 3320b0ed HEAD || {
  echo "STOP: Phase 3 closure checkpoint is not an ancestor of HEAD."
  exit 2
}

git show -s --format='%h %s' c0934a3b
git show -s --format='%h %s' 3320b0ed

echo
echo "=== VERIFY NO PHASE 4 RUNTIME IMPLEMENTATION ==="
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
    --exclude='close-phase-4-collaboration-governance.sh' \
    'CollaborationGovernance|collaborationGovernance|collaboration_governance|MatildaGovernanceArtifact|MatildaCollaborationGovernance|governanceDetermination|governanceDecision|implementationAuthorized|collaborationAuthorized|userAuthorization' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$phase4_runtime_refs" ]]; then
  echo "STOP: possible Phase 4 runtime implementation exists:"
  printf '%s\n' "$phase4_runtime_refs"
  exit 2
fi

echo "NO_PHASE_4_RUNTIME_IMPLEMENTATION"

cat <<'CLOSURE'

Phase 4 — Collaboration Governance closure:

1. Phase 4 investigated whether the Matilda Conversation Engine required an
   additional collaboration-governance runtime responsibility.

2. Collaboration authorization was investigated as a candidate responsibility.

3. No dedicated production consumer, persistence requirement, or deterministic
   runtime behavior requiring a collaboration-authorization artifact was
   established.

4. User Intent Authority remains authoritative.

5. Matilda remains Interpretation Authority and may not self-authorize,
   self-approve, broaden authorization, or manufacture user authority.

6. User correction and challenge remain owned by current user intent and
   established interpretation behavior.

7. Historical authority and contamination protection remain owned by existing
   lifecycle, authority-evaluation, contamination-evaluation, and history-
   selection capabilities.

8. Living Draft remains non-authoritative.

9. Reconciled Intent remains reviewable and pre-authoritative.

10. Explicit approval remains required before authoritative Canonical Package
    creation.

11. Canonical Package creation remains separate from downstream execution
    authorization.

12. Delegation, Validation, Envelope, and Execution remain separate downstream
    governance domains.

13. No unowned Phase 4 semantic fact has been established.

14. No unowned deterministic Phase 4 invariant has been established.

15. No Phase 4 persistence requirement has been established.

16. No repository-supported residual Phase 4 production capability gap remains.

17. Phase 4 therefore requires no production implementation under the current
    bounded architecture.

18. Phase 4 is complete through validated architectural composition of existing
    authority boundaries.

19. Future contradictory evidence may reopen Phase 4 only through a new
    evidence-first investigation.

20. Phase 1 Response Composition remains closed.

21. Phase 2 Investigation Lifecycle remains closed.

22. Phase 3 Attention Management remains closed.

23. Phase 4 Collaboration Governance is now closed.

24. The currently defined four-phase Matilda Collaboration Runtime milestone is
    complete.

Preserve:

User
= Intent Authority

Matilda
= Interpretation Authority

Living Draft
= non-authoritative derived collaboration state

Approval
= explicit transition toward authoritative Package creation

Canonical Package
= authoritative approved package

downstream governance
= separate bounded organizational authority

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

CLOSURE

echo
echo "PHASE_4_COLLABORATION_GOVERNANCE_COMPLETE"
echo "PHASE_4_COLLABORATION_GOVERNANCE_STATUS=CLOSED"
echo "PHASE_4_IMPLEMENTATION_REQUIRED=NO"
echo "PHASE_4_IMPLEMENTATION_PERFORMED=NO"
echo "PHASE_4_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE"
echo "USER_INTENT_AUTHORITY=PRESERVED"
echo "MATILDA_INTERPRETATION_AUTHORITY=PRESERVED"
echo "MATILDA_SELF_AUTHORIZATION=FORBIDDEN"
echo "MATILDA_SELF_APPROVAL=FORBIDDEN"
echo "DOWNSTREAM_AUTHORITY_SEPARATION=PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "PHASE_4_COLLABORATION_GOVERNANCE=CLOSED"
echo "MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE"
echo "NEXT_ACTION=VALIDATE_MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE"

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
  echo "STOP: production runtime changed during Phase 4 closure."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLOSURE-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/close-phase-4-collaboration-governance\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 closure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLOSURE_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/close-phase-4-collaboration-governance.sh
git diff --cached --check
git commit -m "Close Phase 4 Collaboration Governance"
git push
