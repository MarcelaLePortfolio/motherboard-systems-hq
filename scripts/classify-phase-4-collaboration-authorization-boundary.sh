#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 4 COLLABORATION AUTHORIZATION BOUNDARY ==="

REQUIRED_ANCESTOR="f13c7e35"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: collaboration-authorization investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-4-collaboration-authorization-boundary\.sh$|^ M scripts/classify-phase-4-collaboration-authorization-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PRIOR INVESTIGATION ==="
grep -nE \
  'PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_INVESTIGATED|USER_REMAINS_AUTHORIZATION_AUTHORITY|MATILDA_SELF_AUTHORIZATION=FORBIDDEN|DOWNSTREAM_EXECUTION_AUTHORIZATION_REMAINS_SEPARATE|DEDICATED_COLLABORATION_AUTHORIZATION_RUNTIME=NOT_ESTABLISHED|DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=NOT_ESTABLISHED|AUTHORIZATION_PERSISTENCE_REQUIREMENT=NOT_ESTABLISHED|STANDING_COLLABORATION_AUTHORIZATION=NOT_ESTABLISHED|PHASE_4_IMPLEMENTATION=NOT_AUTHORIZED|NEXT_ACTION=CLASSIFY_PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY' \
  scripts/investigate-phase-4-collaboration-authorization-boundary.sh

echo
echo "=== VERIFY REPOSITORY AUTHORITY EVIDENCE ==="

grep -RInE \
  'Matilda may interpret and summarize intent|Matilda may not treat a summary as approval|Matilda may not create a Package without explicit approval|Preserve explicit approval before Package creation' \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_SCOPE_2026-07-04.md

grep -RInE \
  'Matilda may present approval candidates|Matilda may not self-approve|Creation of a Canonical Package does not itself authorize downstream execution' \
  docs/governance/MATILDA_CANONICAL_PACKAGE_APPROVAL_SCOPE_2026-07-05.md

grep -RInE \
  'Execution Authorization records that the operator has explicitly authorized mutation-capable execution consideration|Execution Authorization does not itself execute Cade' \
  docs/governance/MATILDA_EXECUTION_AUTHORIZATION_SCOPE_2026-07-06.md

grep -RInE \
  'Implicit approval is forbidden|Standing approval is forbidden|Approval reuse is forbidden' \
  docs/contracts/CANONICAL_EXECUTION_DOCTRINE_V1.md

echo
echo "=== VERIFY NO DEDICATED COLLABORATION AUTHORIZATION RUNTIME ==="
matches="$(
  grep -RIlE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='classify-phase-4-collaboration-authorization-boundary.sh' \
    --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
    'implementation_authorized|implementationAuthorized|implementation_permission|implementationPermission|collaboration_authorized|collaborationAuthorized|execution_mode_authorized|executionModeAuthorized|user_authorization|userAuthorization' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$matches" ]]; then
  echo "STOP: candidate dedicated collaboration-authorization runtime fields were found:"
  printf '%s\n' "$matches"
  exit 2
fi

echo "DEDICATED_COLLABORATION_AUTHORIZATION_RUNTIME_ABSENT"

cat <<'CLASSIFICATION'

Phase 4 — Collaboration Authorization Boundary classification:

1. The user remains the source and authority for implementation authorization.

2. Matilda remains Interpretation Authority.

3. Matilda may interpret user intent and identify whether explicit authorization
   appears to have been expressed.

4. Matilda may not manufacture, broaden, infer from silence, or self-grant
   authorization.

5. No dedicated collaboration-authorization artifact, runtime field,
   persistence model, or deterministic production consumer is established by
   current repository evidence.

6. Introducing persistent collaboration-authorization state now would therefore
   create semantic state without a demonstrated production consumer.

7. Explicit implementation authorization remains an operating boundary between
   the user and the engineering collaborator.

8. Current repository evidence does not establish that this operating boundary
   must become a Matilda Conversation Engine semantic runtime artifact.

9. User language remains authoritative source evidence for whether
   implementation was explicitly requested.

10. Readiness, recommendation, prior cooperation, silence, phase progression,
    corridor progression, or prior authorization must not silently become new
    authorization.

11. Standing collaboration authorization is not supported.

12. Prior conversational authorization is not reusable authority by default.

13. Scope determination and implementation authorization remain distinct.

14. A bounded implementation scope may exist without permission to execute it.

15. Authorization cannot make undefined or ambiguous scope safe.

16. Collaboration authorization remains distinct from Canonical Package
    approval, Delegation Authority, Validation Authority, Envelope Authority,
    Execution Authority, mutation authority, shell authority, and autonomous
    execution authority.

17. Downstream governance demonstrates that approval and authorization are
    explicit, bounded, non-implicit, and may not silently broaden across
    authority domains.

18. Those downstream constraints inform any future collaboration-authorization
    design but do not prove that a new Conversation Engine artifact is required.

19. Challenge and correction remain ordinary user intent and conversational
    authority unless future repository evidence establishes a distinct
    deterministic governance consumer.

20. No evidence currently establishes a need for database schema changes,
    structured-response changes, prompt changes, IEL changes,
    conversation-turn changes, workflow changes, or additional model
    invocations.

21. Current evidence-based classification:

    COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE

22. This is not a permanent prohibition against a future runtime capability.

23. A future implementation would require repository evidence establishing:

    - a concrete production consumer;
    - deterministic behavior dependent on authorization;
    - a capability gap not already satisfied by authoritative user intent;
    - bounded authority scope;
    - fail-closed behavior when authorization is absent or ambiguous;
    - stale-authorization protection;
    - non-broadening semantics;
    - preservation of user authority;
    - preservation of Matilda non-self-authorization;
    - continued separation from downstream execution governance.

24. Until those conditions exist, collaboration-authorization runtime state
    would be speculative architecture.

25. Phase 1 Response Composition remains closed.

26. Phase 2 Investigation Lifecycle remains closed.

27. Phase 3 Attention Management remains closed.

28. The collaboration-authorization candidate does not currently justify a
    Phase 4 production implementation.

29. The next bounded question is whether any other repository-supported Phase 4
    governance responsibility remains after this candidate is eliminated.

CLASSIFICATION

echo
echo "PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_CLASSIFIED"
echo "USER_AUTHORIZATION_AUTHORITY=PRESERVED"
echo "MATILDA_INTERPRETATION_AUTHORITY=PRESERVED"
echo "MATILDA_SELF_AUTHORIZATION=FORBIDDEN"
echo "COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE"
echo "DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=ABSENT"
echo "DEDICATED_COLLABORATION_AUTHORIZATION_PERSISTENCE=NOT_JUSTIFIED"
echo "STANDING_COLLABORATION_AUTHORIZATION=NOT_SUPPORTED"
echo "PRIOR_CONVERSATIONAL_AUTHORIZATION_REUSE=NOT_AUTHORIZED"
echo "SCOPE_AND_IMPLEMENTATION_AUTHORIZATION=REMAIN_DISTINCT"
echo "DOWNSTREAM_EXECUTION_GOVERNANCE=REMAINS_SEPARATE"
echo "SCHEMA_CHANGE=NONE"
echo "PROMPT_CHANGE=NONE"
echo "STRUCTURED_RESPONSE_CHANGE=NONE"
echo "IEL_CHANGE=NONE"
echo "CONVERSATION_TURN_CHANGE=NONE"
echo "MODEL_INVOCATION_CHANGE=NONE"
echo "PHASE_4_IMPLEMENTATION=NOT_JUSTIFIED_BY_COLLABORATION_AUTHORIZATION"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_UNIT=INVESTIGATE_PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY"

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
  echo "STOP: production runtime changed during classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-4-collaboration-authorization-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-4-collaboration-authorization-boundary.sh
git diff --cached --check
git commit -m "Classify Phase 4 collaboration authorization boundary"
git push
