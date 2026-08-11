#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE PHASE 4 RESIDUAL GOVERNANCE RESPONSIBILITY ==="

REQUIRED_ANCESTOR="909482fa"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 collaboration-authorization classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/investigate-phase-4-residual-governance-responsibility\.sh$|^ M scripts/investigate-phase-4-residual-governance-responsibility\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING AUTHORIZATION CLASSIFICATION ==="
grep -nE \
  'PHASE_4_COLLABORATION_AUTHORIZATION_BOUNDARY_CLASSIFIED|COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE|DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=ABSENT|DEDICATED_COLLABORATION_AUTHORIZATION_PERSISTENCE=NOT_JUSTIFIED|SCOPE_AND_IMPLEMENTATION_AUTHORIZATION=REMAIN_DISTINCT|DOWNSTREAM_EXECUTION_GOVERNANCE=REMAINS_SEPARATE|PHASE_4_IMPLEMENTATION=NOT_JUSTIFIED_BY_COLLABORATION_AUTHORIZATION|NEXT_UNIT=INVESTIGATE_PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY' \
  scripts/classify-phase-4-collaboration-authorization-boundary.sh

echo
echo "=== INVENTORY PHASE 4 GOVERNANCE LANGUAGE ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-phase-4-residual-governance-responsibility.sh' \
  'Phase 4|Governance|governance|authority|authorization|approval|challenge|correction|override|revoke|scope boundary|execution boundary' \
  docs/governance docs/architecture scripts 2>/dev/null |
head -n 2600 || true

echo
echo "=== INVENTORY USER AUTHORITY AND CORRECTION SEMANTICS ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Intent Authority|Interpretation Authority|user correction|user challenge|challenge|correction|corrected intent|reconciled intent|supersed|approval|reject|revok' \
  docs/governance docs/architecture server db scripts/utils 2>/dev/null |
head -n 2600 || true

echo
echo "=== INVENTORY EXISTING AUTHORITY / CONTAMINATION ENFORCEMENT ==="
grep -RInE -C 8 \
  'eligible|ineligible_superseded|unresolved|detected_superseded_context|authority|contamination|supersession' \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts 2>/dev/null |
head -n 2200 || true

echo
echo "=== INVENTORY APPROVAL / PACKAGE BOUNDARY ==="
grep -RInE -C 8 \
  'Living Draft|non-authoritative|Approval Request|explicit approval|Canonical Package|self-approve|approval candidate|authoritative Package|Package creation' \
  docs/governance server db 2>/dev/null |
head -n 2400 || true

echo
echo "=== INVENTORY DOWNSTREAM GOVERNANCE BOUNDARIES ==="
grep -RInE -C 6 \
  'delegation_authorized|validation_authorized|envelope_authorized|execution_authorized|approval_required|Implicit approval is forbidden|Standing approval is forbidden|Approval reuse is forbidden' \
  docs/contracts \
  docs/governance \
  server/delegation \
  server/envelope \
  server/gate \
  server/execution \
  db/governance-runtime.ts \
  db/governance-lifecycle-persistence.ts 2>/dev/null |
head -n 2400 || true

echo
echo "=== SEARCH FOR UNOWNED COLLABORATION GOVERNANCE FACTS ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-phase-4-residual-governance-responsibility.sh' \
  'collaboration.*authority|collaboration.*governance|conversation.*authority|conversation.*governance|governance.*conversation|user.*override|user.*revocation|user.*revoke|user.*challenge|user.*correction|permission.*scope|authority.*scope' \
  server db scripts/utils docs 2>/dev/null |
head -n 2200 || true

cat <<'FINDINGS'

Phase 4 — Residual Governance Responsibility investigation:

Established state:

PHASE_1_RESPONSE_COMPOSITION=CLOSED
PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED
PHASE_3_ATTENTION_MANAGEMENT=CLOSED
PHASE_4_GOVERNANCE=ACTIVE_INVESTIGATION

The first Phase 4 candidate responsibility has now been classified:

USER_AUTHORED_COLLABORATION_AUTHORIZATION

Current evidence establishes:

COLLABORATION_AUTHORIZATION_RUNTIME_REQUIRED=NO_CURRENT_EVIDENCE
DEDICATED_COLLABORATION_AUTHORIZATION_CONSUMER=ABSENT
DEDICATED_COLLABORATION_AUTHORIZATION_PERSISTENCE=NOT_JUSTIFIED

Therefore this investigation must not reopen that candidate without
contradictory repository evidence.

The remaining question is narrower:

Does any other currently unsupported governance responsibility exist inside the
Matilda Conversation Engine boundary?

Candidate residual responsibilities requiring evidence testing:

1. User correction / challenge authority.

2. User revocation or supersession of previously expressed intent.

3. Matilda interpretation authority boundaries.

4. Living Draft non-authority.

5. Explicit approval before authoritative Package creation.

6. Prevention of Matilda self-approval.

7. Prevention of authority broadening between collaboration and downstream
   execution governance.

8. Deterministic exclusion of superseded or contaminated historical context.

9. Scope preservation when implementation is discussed but not authorized.

10. Any other governance fact that currently lacks both:

    - a semantic owner;
    - and deterministic enforcement where deterministic enforcement is required.

Classification questions:

A. Are user correction and challenge already represented through authoritative
   current user intent plus Reconciled Intent behavior?

B. Is superseded prior intent already governed by interpretation lifecycle,
   authority evaluation, contamination evaluation, and history selection?

C. Is Living Draft non-authority already established and enforced at the
   Approval / Canonical Package boundary?

D. Is Matilda self-approval already forbidden by existing approval doctrine?

E. Is downstream authority broadening already prevented by separate Delegation,
   Validation, Envelope, and Execution governance?

F. Does any current production behavior allow Matilda to exercise authority that
   repository doctrine assigns exclusively to the user or downstream governance?

G. Is any required governance fact currently lost between the user message,
   durable interpretation, IEL, conversation turn, Living Draft, Approval
   Request, and Canonical Package?

H. Is any missing governance behavior demonstrated by an actual repository
   capability gap rather than by abstract desirability?

I. Would a new Phase 4 semantic fact have a concrete production consumer?

J. Would a new Phase 4 runtime validator have an explicit invariant to enforce?

K. Would a new Phase 4 persistence field preserve authority that is otherwise
   lost?

L. If all candidate responsibilities are already owned by established
   architecture, is Phase 4 complete without implementation?

Investigation discipline:

Do not invent governance responsibilities from the phase name.

Do not create a generic Governance artifact.

Do not duplicate user intent.

Do not duplicate Investigation Lifecycle.

Do not duplicate history authority or contamination evaluation.

Do not duplicate Approval or Canonical Package authority.

Do not duplicate downstream organizational governance.

Do not create semantic state without a concrete consumer.

Do not introduce deterministic validation without an explicit invariant.

Do not implement.

Do not change schema.

Do not change persistence.

Do not change prompts.

Do not change workflow behavior.

Do not change structured response.

Do not add model invocations.

Do not reopen Phases 1–3.

Preserve:

User
= Intent Authority

Matilda
= Interpretation Authority

Living Draft
= non-authoritative derived collaboration artifact

Approval
= explicit transition toward authoritative Package creation

Canonical Package
= authoritative approved package representation

history authority / contamination evaluation
= deterministic protection against invalid historical semantic influence

downstream governance
= separate organizational authority domain

Phase 4
= may close without implementation if every repository-supported governance
  responsibility is already owned and no residual production capability gap is
  established

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY_INVESTIGATED"
echo "COLLABORATION_AUTHORIZATION_CANDIDATE=NO_RUNTIME_REQUIREMENT_ESTABLISHED"
echo "GENERIC_GOVERNANCE_ARTIFACT=NOT_JUSTIFIED"
echo "NEW_GOVERNANCE_SEMANTIC_FACT=NOT_ESTABLISHED"
echo "NEW_GOVERNANCE_RUNTIME_CONSUMER=NOT_ESTABLISHED"
echo "NEW_GOVERNANCE_PERSISTENCE=NOT_ESTABLISHED"
echo "PHASE_4_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_4_RESIDUAL_GOVERNANCE_RESPONSIBILITY"

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
  echo "STOP: production runtime changed during Phase 4 residual-governance investigation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-phase-4-residual-governance-responsibility\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 residual-governance investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-phase-4-residual-governance-responsibility.sh
git diff --cached --check
git commit -m "Investigate Phase 4 residual governance responsibility"
git push
