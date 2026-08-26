#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

CONVERSATION_ID="matilda-conversation-hq-1787768048637-jpxjvu"

echo "=== INVESTIGATE SEEDED EXPECTED OUTCOME GAP ==="
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "CONVERSATION_ID=${CONVERSATION_ID}"

echo
echo "=== LIVING DRAFT TABLE SCHEMA ==="
sqlite3 -header -column db/main.db "
PRAGMA table_info(matilda_living_draft_packages);
"

echo
echo "=== SEEDED LIVING DRAFT SEMANTIC FIELDS ==="
sqlite3 -header -column db/main.db "
SELECT
  conversation_id,
  current_interpretation,
  expected_outcome,
  proposed_work,
  proposed_artifacts,
  in_scope,
  out_of_scope,
  constraints,
  unresolved_questions
FROM matilda_living_draft_packages
WHERE conversation_id = '${CONVERSATION_ID}'
LIMIT 1;
"

echo
echo "=== SOURCE IEL PACKAGE SEMANTICS JSON ==="
sqlite3 -header -column db/main.db "
SELECT
  entry_id,
  conversation_id,
  package_semantics_json
FROM matilda_interpretation_evidence_ledger
WHERE conversation_id = '${CONVERSATION_ID}'
ORDER BY created_at DESC
LIMIT 1;
"

echo
echo "=== SOURCE IEL EXPECTED OUTCOME EXTRACTION ==="
sqlite3 -header -column db/main.db "
SELECT
  entry_id,
  json_extract(package_semantics_json, '\$.expectedOutcome') AS expected_outcome,
  json_extract(package_semantics_json, '\$.proposedWork') AS proposed_work,
  json_extract(package_semantics_json, '\$.proposedArtifacts') AS proposed_artifacts,
  json_extract(package_semantics_json, '\$.inScope') AS in_scope,
  json_extract(package_semantics_json, '\$.outOfScope') AS out_of_scope,
  json_extract(package_semantics_json, '\$.constraints') AS constraints,
  json_extract(package_semantics_json, '\$.unresolvedQuestions') AS unresolved_questions
FROM matilda_interpretation_evidence_ledger
WHERE conversation_id = '${CONVERSATION_ID}'
ORDER BY created_at DESC
LIMIT 1;
"

echo
echo "=== APPROVAL PRESENTATION BINDING ==="
rg -n \
  'expected_outcome|expectedOutcome|Not recorded|What you are approving|readText' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  server \
  db \
  | head -160 || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "QUESTION_1=WAS_expectedOutcome_NULL_IN_MATILDA_AUTHORED_packageSemantics"
echo "QUESTION_2=IF_NOT_WAS_IT_LOST_DURING_LIVING_DRAFT_SYNTHESIS_OR_APPROVAL_READ_MODEL"
echo "QUESTION_3=IS_NOT_RECORDED_ONLY_A_PRESENTATION_FALLBACK"
echo "NEXT_ACTION=CLASSIFY_EXACT_FAILURE_LOCATION_BEFORE_ANY_FIX"
