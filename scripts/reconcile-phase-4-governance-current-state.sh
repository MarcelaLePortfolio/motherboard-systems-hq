#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE PHASE 4 GOVERNANCE CURRENT STATE ==="

REQUIRED_ANCESTOR="3320b0ed"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 closure checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/reconcile-phase-4-governance-current-state\.sh$|^ M scripts/reconcile-phase-4-governance-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 3 CLOSURE ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_COMPLETE|PHASE_3_ATTENTION_MANAGEMENT_STATUS=CLOSED|PHASE_3_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE|PHASE_3_ATTENTION_MANAGEMENT=CLOSED|NEXT_ACTION=RECONCILE_PHASE_4_GOVERNANCE_CURRENT_STATE' \
  scripts/close-phase-3-attention-management.sh

echo
echo "=== INVENTORY GOVERNANCE TERMINOLOGY ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-4-governance-current-state.sh' \
  'Collaboration Governance|collaboration governance|Phase 4|PHASE_4|governance boundary|governance responsibility|governance state|governance runtime|governance authority' \
  docs scripts server db 2>/dev/null |
head -n 2200 || true

echo
echo "=== INVENTORY EXISTING GOVERNANCE SYSTEMS ==="
find docs server db scripts -type f \
  \( -iname '*governance*' -o -iname '*approval*' -o -iname '*authority*' -o -iname '*validation*' \) \
  -print |
sort |
head -n 2000

echo
echo "=== INVENTORY AUTHORITY BOUNDARIES ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Intent Authority|Interpretation Authority|Database Authority|Persistence Authority|Lifecycle Authority|Assignment Authority|Execution Authority|approval authority|authorization|authoritative Package|non-authoritative' \
  docs server db scripts 2>/dev/null |
head -n 2400 || true

echo
echo "=== INVENTORY APPROVAL / GOVERNANCE PIPELINE ==="
grep -RInE -C 7 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'Approval Request|Canonical Package|Delegation|Validation|Envelope|Execution|approval_required|canonical_package_created|delegation_authorized|validation_authorized|envelope_authorized|execution_authorized' \
  docs/governance server db scripts 2>/dev/null |
head -n 2600 || true

echo
echo "=== INVENTORY GOVERNANCE LIFECYCLE MODEL ==="
if [[ -f docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md ]]; then
  cat docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md
fi

echo
echo "=== INVENTORY GOVERNANCE VALIDATION CHARTER ==="
if [[ -f docs/governance/GOVERNANCE_VALIDATION_CHARTER.md ]]; then
  cat docs/governance/GOVERNANCE_VALIDATION_CHARTER.md
fi

echo
echo "=== INVENTORY MATILDA PACKAGE AUTHORITY ==="
if [[ -f docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md ]]; then
  cat docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md
fi

echo
echo "=== INVENTORY DELEGATION AUTHORITY ==="
if [[ -f docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md ]]; then
  grep -nE -C 8 \
    'authority|authorization|Pending|Authorized|Delegation Record|execution|validation|approval' \
    docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md |
  head -n 1600 || true
fi

echo
echo "=== INVENTORY CURRENT CONVERSATION GOVERNANCE FLAGS ==="
grep -RInE -C 8 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'approval_required|canonical_package_created|delegation_authorized|validation_authorized|envelope_authorized|execution_authorized' \
  server db scripts 2>/dev/null |
head -n 1600 || true

echo
echo "=== SEARCH FOR COLLABORATION-SPECIFIC GOVERNANCE RUNTIME ==="
collaboration_governance_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-4-governance-current-state.sh' \
    'CollaborationGovernance|collaborationGovernance|collaboration_governance|MatildaGovernanceArtifact|MatildaCollaborationGovernance|governanceDetermination|governanceDecision' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$collaboration_governance_refs" ]]; then
  echo "POSSIBLE_COLLABORATION_GOVERNANCE_RUNTIME_REFERENCES"
  printf '%s\n' "$collaboration_governance_refs"
else
  echo "DEDICATED_COLLABORATION_GOVERNANCE_RUNTIME_NOT_FOUND"
fi

echo
echo "=== SEARCH FOR GOVERNANCE PERSISTENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'governance_json|governance_state|governance_status|CREATE TABLE.*governance|ALTER TABLE.*governance|INSERT INTO.*governance' \
  db server scripts 2>/dev/null |
head -n 1200 || true

echo
echo "=== FALSIFICATION — EXISTING PHASE 4 CAPABILITY ==="
grep -RInE -C 6 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-4-governance-current-state.sh' \
  'governance.*implemented|implemented.*governance|collaboration.*governance.*implemented|governance.*runtime.*implemented|governance.*artifact.*implemented' \
  docs scripts server db 2>/dev/null |
head -n 1800 || true

cat <<'FINDINGS'

Phase 4 — Collaboration Governance current-state reconciliation:

Starting state:

PHASE_1_RESPONSE_COMPOSITION=CLOSED
PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED
PHASE_3_ATTENTION_MANAGEMENT=CLOSED
PHASE_4_GOVERNANCE=ACTIVE_INVESTIGATION
PHASE_4_GOVERNANCE_IMPLEMENTATION=NOT_AUTHORIZED

This unit is repository reconciliation only.

The purpose is to determine what "Collaboration Governance" means after the
first three Matilda Collaboration Runtime phases are closed, without confusing
it with already-established organizational governance, approval, delegation,
validation, or execution machinery.

Required distinctions:

1. Existing organizational governance is not automatically Phase 4
   Collaboration Governance.

2. Existing approval authority is not automatically Phase 4 Collaboration
   Governance.

3. Existing Canonical Package authority is not automatically Phase 4
   Collaboration Governance.

4. Existing Delegation, Validation, Envelope, and Execution states remain
   downstream organizational responsibilities.

5. Matilda remains Interpretation Authority.

6. The user remains Intent Authority.

7. Living Draft remains non-authoritative.

8. Approval remains the transition into authoritative Package creation.

9. Phase 4 must not duplicate downstream approval or execution governance merely
   because those mechanisms already use governance terminology.

10. Phase 4 must not reopen Response Composition, Investigation Lifecycle, or
    Attention Management.

Questions requiring current-state classification:

A. Does a dedicated Collaboration Governance semantic artifact already exist?

B. Does a dedicated Collaboration Governance runtime already exist?

C. Does dedicated Collaboration Governance persistence already exist?

D. Is there any repository-supported collaboration decision that remains
   semantically unresolved after Phases 1–3?

E. Does Phase 4 concern governance of the user–Matilda collaboration itself,
   rather than governance of approved organizational work?

F. Which collaboration behaviors currently exist only as methodology or
   doctrine rather than runtime capability?

G. Does runtime need to represent user authorization, implementation permission,
   scope permission, challenge/correction state, or another collaboration
   governance fact?

H. Are any of those already represented sufficiently by existing user intent,
   workflow, approval, or conversation semantics?

I. What authority boundary would own any missing governance decision?

J. Which governance decisions must remain user-authored rather than
   Matilda-authored?

K. Which decisions, if any, may Matilda semantically interpret without granting
   herself authorization?

L. Which existing organizational governance systems are architectural inputs or
   analogies only, rather than owners of Phase 4?

M. What actual collaboration failure would justify a new Phase 4 runtime
   capability?

N. What evidence would falsify the need for a distinct Phase 4 runtime?

O. What is the smallest next investigation that materially reduces uncertainty?

Investigation discipline:

Do not equate organizational governance with Collaboration Governance.

Do not equate approval_required with implementation authorization without
repository evidence.

Do not allow Matilda to grant herself execution or implementation authority.

Do not move approval, delegation, validation, envelope, or execution authority
upstream into the Conversation Engine.

Do not implement.

Do not add schema.

Do not add persistence.

Do not alter prompts.

Do not alter workflow behavior.

Do not alter Investigation Lifecycle.

Do not alter Conversation Context Runtime.

Do not reopen Phase 1.

Do not reopen Phase 2.

Do not reopen Phase 3.

Do not add model invocations.

Preserve:

User
= Intent Authority

Matilda
= Interpretation Authority

Living Draft
= non-authoritative

Approval
= transition into authoritative Package creation

Conversation
-> Interpretation Evidence Ledger
-> Living Draft
-> Reconciled Intent
-> Approval Request
-> Canonical Package
-> Delegation
-> Validation
-> Envelope
-> Execution

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_4_GOVERNANCE_CURRENT_STATE_RECONCILED"
echo "PHASE_4_GOVERNANCE_IMPLEMENTATION=NOT_STARTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_4_GOVERNANCE_CURRENT_STATE"

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
  echo "STOP: production runtime changed during Phase 4 current-state reconciliation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-phase-4-governance-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 4 investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reconcile-phase-4-governance-current-state.sh
git diff --cached --check
git commit -m "Reconcile Phase 4 Collaboration Governance current state"
git push
