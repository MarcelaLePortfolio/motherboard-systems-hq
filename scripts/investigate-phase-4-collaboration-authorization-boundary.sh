#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE PHASE 4 COLLABORATION AUTHORIZATION BOUNDARY ==="

REQUIRED_ANCESTOR="dd4f876c"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 current-state classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
echo "=== VERIFY INVESTIGATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-phase-4-collaboration-authorization-boundary\.sh$|^ M scripts/investigate-phase-4-collaboration-authorization-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING PHASE 4 CLASSIFICATION ==="
grep -nE \
  'PHASE_4_GOVERNANCE_CURRENT_STATE_CLASSIFIED|DEDICATED_COLLABORATION_GOVERNANCE_ARTIFACT=ABSENT|DEDICATED_COLLABORATION_GOVERNANCE_RUNTIME=ABSENT|DOWNSTREAM_ORGANIZATIONAL_GOVERNANCE=EXISTS_AND_REMAINS_SEPARATE|USER_INTENT_AUTHORITY=PRESERVED|MATILDA_INTERPRETATION_AUTHORITY=PRESERVED|RESIDUAL_CANDIDATE_RESPONSIBILITY=USER_AUTHORED_COLLABORATION_AUTHORIZATION|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=UNDETERMINED|NEXT_UNIT=INVESTIGATE_PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY' \
  scripts/classify-phase-4-governance-current-state.sh

echo
echo "=== INVENTORY COLLABORATION / EXECUTION MODE DOCTRINE ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
  'collaboration by default|execution only when explicitly authorized|implementation explicitly requested|explicit user authorization|collaboration mode|execution mode|Do not begin implementation automatically|implementation authorization|execution gate' \
  docs scripts 2>/dev/null |
head -n 2400 || true

echo
echo "=== INVENTORY USER INTENT REPRESENTATION ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Intent Authority|user intent|durableInterpretation|reconciled intent|Reconciled Intent|approval request|approval_required' \
  docs/architecture \
  docs/governance \
  server \
  db \
  scripts/utils 2>/dev/null |
head -n 2400 || true

echo
echo "=== INVENTORY CURRENT CONVERSATION TURN STORAGE ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'conversation.*message|user_message|userMessage|message_text|role.*user|conversation turn|createMatildaConversationTurn|insert.*conversation' \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts 2>/dev/null |
head -n 1800 || true

echo
echo "=== INVENTORY STRUCTURED MATILDA RESPONSE CONTRACT ==="
grep -nE -C 10 \
  'reply|durableInterpretation|investigationLifecycle|explanationStatus|selectedContextSegments|supportSourceReferences' \
  scripts/utils/ollamaChat.ts |
head -n 1800 || true

echo
echo "=== SEARCH FOR EXISTING COLLABORATION AUTHORIZATION FIELDS ==="
grep -RInE -C 5 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-phase-4-collaboration-authorization-boundary.sh' \
  'implementation_authorized|implementationAuthorized|implementation_permission|implementationPermission|collaboration_authorized|collaborationAuthorized|execution_mode_authorized|executionModeAuthorized|user_authorization|userAuthorization|authorization_scope|authorizationScope' \
  server db scripts/utils 2>/dev/null ||
true

echo
echo "=== SEARCH FOR AUTHORIZATION SCOPE / LIFETIME DOCTRINE ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'standing approval|approval reuse|single-turn|one turn|one implementation|bounded implementation|bounded unit|corridor authorization|phase authorization|revok|supersed.*authorization|authorization.*scope|authorization.*expires|explicit approval|implicit approval' \
  docs scripts server db 2>/dev/null |
head -n 2200 || true

echo
echo "=== SEARCH FOR ACTUAL COLLABORATION AUTHORIZATION FAILURES ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'implemented without authorization|implementation without authorization|began implementation automatically|execution without authorization|unauthorized implementation|authorization lost|authorization persisted too long|authorization reused|standing authorization|self-authorized|self authorized' \
  docs scripts server db 2>/dev/null |
head -n 1800 || true

echo
echo "=== VERIFY DOWNSTREAM EXECUTION AUTHORIZATION REMAINS SEPARATE ==="
grep -RInE -C 8 \
  'Execution Authorization records that the operator has explicitly authorized|Implicit approval is forbidden|Standing approval is forbidden|Approval reuse is forbidden|execution_authorized|shell_execution_authorized|autonomous_execution_authorized' \
  docs/governance/MATILDA_EXECUTION_AUTHORIZATION_SCOPE_2026-07-06.md \
  docs/contracts/CANONICAL_EXECUTION_DOCTRINE_V1.md \
  server/execution 2>/dev/null |
head -n 2000 || true

cat <<'FINDINGS'

Phase 4 — Collaboration Authorization Boundary investigation:

Established starting state:

PHASE_1_RESPONSE_COMPOSITION=CLOSED
PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED
PHASE_3_ATTENTION_MANAGEMENT=CLOSED
PHASE_4_GOVERNANCE=ACTIVE_INVESTIGATION

DEDICATED_COLLABORATION_GOVERNANCE_ARTIFACT=ABSENT
DEDICATED_COLLABORATION_GOVERNANCE_RUNTIME=ABSENT
DEDICATED_COLLABORATION_GOVERNANCE_PERSISTENCE=ABSENT

RESIDUAL_CANDIDATE_RESPONSIBILITY=
USER_AUTHORED_COLLABORATION_AUTHORIZATION

The purpose of this investigation is to determine whether the existing
conversation and intent architecture already carries sufficient evidence of
explicit user authorization to begin implementation, or whether a distinct
bounded collaboration-authorization representation is required.

Required distinctions:

1. User remains Intent Authority.

2. Matilda remains Interpretation Authority.

3. Matilda may interpret user language but must not manufacture authorization.

4. Collaboration authorization is not downstream execution authorization.

5. Approval Request, Canonical Package, Delegation, Validation, Envelope, and
   Execution remain separate downstream authority domains.

6. An explicit request such as "go ahead" may constitute conversational evidence
   of authorization, but this investigation must determine whether raw
   conversational evidence alone is sufficient as a governed runtime boundary.

Questions requiring repository-backed determination:

A. Is the user's source message durably persisted such that explicit
   authorization can always be reconstructed from authoritative conversation
   evidence?

B. Does the workflow already receive the current user message directly at the
   only point where implementation authorization would matter?

C. Would adding a separate authorization artifact duplicate the source user
   message rather than preserve otherwise-lost authority?

D. Is authorization required only for the external engineering collaborator
   operating on the repository, rather than for Matilda's production
   Conversation Engine runtime itself?

E. Does any production Conversation Engine behavior currently perform repository
   implementation or mutation in response to conversational authorization?

F. If production Matilda does not itself perform repository implementation,
   does a production collaboration-authorization runtime solve any real current
   capability gap?

G. Is explicit authorization primarily an engineering operating-doctrine gate
   for the user–assistant development collaboration rather than a Matilda
   semantic runtime fact?

H. If a runtime representation were introduced, what would consume it?

I. What deterministic behavior would change when authorization is present?

J. What deterministic behavior would fail closed when authorization is absent?

K. If no production consumer exists, would persistence of authorization create
   unused semantic state?

L. Does repository evidence support standing authorization across turns?

M. Does repository evidence instead support narrowly bounded, non-reusable
   authorization?

N. Can authorization be safely inferred from prior turns, or must execution
   require current explicit evidence?

O. Would persisting authorization create a risk that stale authorization could
   be reused beyond its intended scope?

P. Is scope authorization separate from permission to execute an already-defined
   bounded implementation?

Q. Is challenge/correction state actually part of authorization, or does it
   remain ordinary user intent and conversational correction?

R. What actual failure exists today that a dedicated Collaboration Governance
   runtime artifact would prevent?

S. What evidence would falsify the need for any Phase 4 implementation?

Decision discipline:

Do not assume that every operating-doctrine rule must become production runtime
state.

Do not create semantic state without a consumer.

Do not persist authority merely because it can be represented.

Do not convert conversational evidence into standing authority.

Do not infer authorization from silence, prior cooperation, phase progression,
implementation readiness, or Matilda's recommendation.

Do not reuse downstream execution-authorization fields for collaboration
authorization.

Do not allow Matilda to broaden user authorization.

Do not allow Matilda to self-authorize.

Do not implement.

Do not change schema.

Do not change persistence.

Do not change prompts.

Do not change workflow behavior.

Do not change the structured response contract.

Do not add model invocations.

Do not reopen Phases 1–3.

Preserve:

User
= source and authority for explicit implementation authorization

Matilda
= Interpretation Authority only

Current user message
= authoritative conversational evidence of what the user explicitly requested

downstream execution governance
= separate organizational authority domain

Phase 4
= must introduce runtime state only if repository evidence establishes a real
  production consumer and a capability gap not already satisfied by explicit
  conversational intent

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_INVESTIGATED"
echo "USER_REMAINS_AUTHORIZATION_AUTHORITY"
echo "MATILDA_SELF_AUTHORIZATION=FORBIDDEN"
echo "DOWNSTREAM_EXECUTION_AUTHORIZATION_REMAINS_SEPARATE"
echo "DEDICATED_COLLABORATION_AUTHORIZATION_RUNTIME=NOT_ESTABLISHED"
echo "DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=NOT_ESTABLISHED"
echo "AUTHORIZATION_PERSISTENCE_REQUIREMENT=NOT_ESTABLISHED"
echo "STANDING_COLLABORATION_AUTHORIZATION=NOT_ESTABLISHED"
echo "PHASE_4_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY"

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
  echo "STOP: production runtime changed during Phase 4 collaboration-authorization investigation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-phase-4-collaboration-authorization-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 authorization investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-phase-4-collaboration-authorization-boundary.sh
git diff --cached --check
git commit -m "Investigate Phase 4 collaboration authorization boundary"
git push
