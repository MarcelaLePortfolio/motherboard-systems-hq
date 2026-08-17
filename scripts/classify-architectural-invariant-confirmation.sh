#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY ARCHITECTURAL INVARIANT CONFIRMATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 08b69dab HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-architectural-invariant-confirmation\.sh$|^ M scripts/classify-architectural-invariant-confirmation\.sh$' ||
  true
)"
test -z "$unexpected"

transition="scripts/close-fail-closed-and-provenance-contract-confirmation-and-enter-architectural-invariant-confirmation.sh"
test -f "$transition"

grep -q 'ACTIVE_CORRIDOR=' "$transition"
grep -q '^ARCHITECTURAL_INVARIANT_CONFIRMATION$' \
  <(awk '/ACTIVE_CORRIDOR=/{getline; print}' "$transition")

echo "=== VERIFY ONE OLLAMA INVOCATION ==="
production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "=== VERIFY REPLY / DURABLE INTERPRETATION SEPARATION ==="
grep -q 'ollamaResult.reply' server/matilda-chat-workflow.ts
grep -q 'ollamaResult.durableInterpretation' server/matilda-chat-workflow.ts

echo "=== VERIFY WORKFLOW-OWNED IEL PERSISTENCE ==="
grep -q 'createInterpretationEvidenceLedgerEntry' server/matilda-chat-workflow.ts
grep -q 'durableInterpretation' server/matilda-chat-workflow.ts

echo "=== VERIFY LIVING DRAFT DERIVES THROUGH IEL EVIDENCE IDS ==="
grep -q 'evidence_entry_ids' db/matilda-chat-draft-integration.ts
grep -q 'synthesizeLivingDraft' db/matilda-chat-draft-integration.ts
grep -q 'latest_entry_id' db/matilda-chat-draft-integration.ts

if ! grep -qE \
  'interpretation.evidence|InterpretationEvidence|matilda_interpretation_evidence_ledger|evidence_entry_ids' \
  db/matilda-draft-synthesis-runtime.ts
then
  echo "STOP: Living Draft synthesis is not proven to consume IEL evidence."
  exit 2
fi

echo "=== VERIFY APPROVAL BOUNDARY ==="
grep -q 'approval_required !== true' db/matilda-canonical-package-runtime.ts
grep -q 'Summary is not eligible for approval' db/matilda-canonical-package-runtime.ts
grep -q 'canonical_approved' db/matilda-canonical-package-runtime.ts

echo "=== VERIFY EXECUTION REMAINS DOWNSTREAM ==="
grep -q 'delegation_authorized: false' server/matilda-chat-workflow.ts
grep -q 'validation_authorized: false' server/matilda-chat-workflow.ts
grep -q 'envelope_authorized: false' server/matilda-chat-workflow.ts
grep -q 'execution_authorized: false' server/matilda-chat-workflow.ts

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE
MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION
PHASE_3=
PRODUCTION_RELIABILITY_VALIDATION_AND_MILESTONE_CLOSURE
CORRIDOR_4=
ARCHITECTURAL_INVARIANT_CONFIRMATION
ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=
PRESERVED
REPLY_DURABLE_INTERPRETATION_SEPARATION=
PRESERVED
WORKFLOW_OWNED_IEL_PERSISTENCE=
PRESERVED
LIVING_DRAFT_IEL_DERIVATION_BOUNDARY=
PRESERVED
APPROVAL_TO_CANONICAL_PACKAGE_BOUNDARY=
PRESERVED
DOWNSTREAM_EXECUTION_AUTHORITY_BOUNDARY=
PRESERVED
ARCHITECTURAL_CONTRADICTION=
NONE_ESTABLISHED
NEW_PRODUCTION_CHANGE=
NONE
IMPLEMENTATION_AUTHORIZED=
NO_NEW_IMPLEMENTATION
ARCHITECTURAL_INVARIANT_CONFIRMATION=
SATISFIED_ON_CURRENT_REPOSITORY_EVIDENCE
CORRIDOR_4_STATUS=
READY_FOR_CLOSURE
NEXT_ACTION=
RUN_DR_BEFORE_CLOSING_CORRIDOR_4_AND_ENTERING_MILESTONE_CLOSURE_READINESS
MAP
