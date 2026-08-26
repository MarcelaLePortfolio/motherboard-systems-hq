#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT IEL SOURCE MATERIAL FOR LIVING DRAFT SEMANTICS ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "RECOVERY_POINT=DR_20260826_092915"

echo
echo "=== QUESTION ==="
echo "QUESTION=DO_EXISTING_MATILDA_AUTHORED_IEL_ARTIFACTS_CONTAIN_ENOUGH_REQUEST_SPECIFIC_SEMANTIC_INFORMATION_TO_DERIVE_LIVING_DRAFT_WORK_DELIVERABLES_SCOPE_CONSTRAINTS_AND_EXPECTED_OUTCOME_WITHOUT_NEW_GENERATION_OR_INVENTED_MEANING"

echo
echo "=== DRAFT SYNTHESIS INPUT AND IEL ACCESS ==="
sed -n '1,180p' db/matilda-draft-synthesis-runtime.ts

echo
echo "=== IEL TYPES AND PERSISTED FIELDS ==="
rg -n -C 10 \
  'InterpretationEvidence|interpretation.*ledger|matilda_observation|durableInterpretation|unresolved_questions|lineage_references|support.*provenance|investigation_lifecycle|evidence_entry' \
  db server routes \
  -g '*.ts' -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== WORKFLOW AUTHORING BOUNDARY ==="
sed -n '210,315p' server/matilda-chat-workflow.ts

echo
echo "=== SEARCH FOR EXISTING STRUCTURED SEMANTIC ARTIFACTS ==="
rg -n -C 8 \
  'expected.?outcome|proposed.?work|proposed.?artifacts|in.?scope|out.?of.?scope|constraints|deliverables|objective|scope|durableInterpretation' \
  server db routes \
  -g '*.ts' -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "DO_NOT_MODIFY_SYNTHESIS_YET=YES"
echo "DO_NOT_ADD_SECOND_OLLAMA_INVOCATION=YES"
echo "DO_NOT_PARSE_REQUEST_SPECIFICS_BY_GUESSING=YES"
echo "DO_NOT_PATCH_APPROVALS_REACT=YES"
echo "AUTHORITY_MODEL_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_WHICH_REQUEST_SPECIFIC_SEMANTICS_ARE_EXPLICITLY_PRESENT_IN_EXISTING_MATILDA_AUTHORED_IEL_CONTENT_AND_WHICH_ARE_NOT"
