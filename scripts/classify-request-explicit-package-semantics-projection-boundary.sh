#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== REQUEST-EXPLICIT PACKAGE SEMANTICS PROJECTION BOUNDARY ==="
echo "INVESTIGATION_ONLY=YES"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== ESTABLISHED AUTHORSHIP CLASSIFICATION ==="
echo "USER_PACKAGE_SEMANTICS=EXPLICIT_USER_AUTHORED_INTENT_EVIDENCE"
echo "ORDINARY_CONVERSATIONAL_TEXT_AUTOMATICALLY_POPULATES_USER_PACKAGE_SEMANTICS=NO"
echo "CONCRETE_OPERATION_MESSAGE=RAW_CURRENT_REQUEST_FOR_POST_GENERATION_FIDELITY"
echo "MODEL_PACKAGE_SEMANTICS=NON_AUTHORITATIVE_MODEL_AUTHORED_ARTIFACT"
echo "AUTOMATIC_PROJECTION_INTO_USER_PACKAGE_SEMANTICS=PROHIBITED_BY_AUTHORSHIP_BOUNDARY"

echo
echo "=== EXISTING SEMANTIC / PROJECTION TYPES ==="
grep -RInE \
  'requestExplicit|request-explicit|projection|projected|derived.*intent|intent.*derived|non.authoritative|authorship|user-authored|system-derived|model-authored' \
  server db scripts \
  --exclude='*.sh' \
  --exclude='*.py' \
  2>/dev/null | head -n 320 || true

echo
echo "=== PACKAGE SEMANTICS TYPE DEFINITIONS ==="
sed -n '315,430p' scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW RESULT AND PERSISTENCE HANDOFF ==="
sed -n '45,110p' server/matilda-chat-workflow.ts
sed -n '450,550p' server/matilda-chat-workflow.ts

echo
echo "=== INTERPRETATION LEDGER WRITE CONTRACT ==="
grep -nE \
  'package_semantics|packageSemantics|durable_interpretation|user_message|observation' \
  db/matilda-interpretation-runtime.ts | head -n 180 || true

echo
echo "=== EXISTING NON-AUTHORITATIVE PACKAGE BOUNDARIES ==="
grep -RInE \
  'non_authoritative|non-authoritative|packageSemantics|expectedOutcome' \
  server db \
  --exclude='*.test.ts' \
  2>/dev/null | head -n 280 || true

echo
echo "=== AUTHORITY BOUNDARY CHECK ==="
grep -RInE \
  'executionAuthorized|delegation_authorized|validation_authorized|approval|authority|authorize' \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts \
  2>/dev/null | head -n 240 || true

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_APPROACH_CLASS=PROMPT_GROUNDING_MODEL_AUTHORED_EXPECTED_OUTCOME"
echo "NEW_APPROACH_CLASS=DETERMINISTIC_LITERAL_REQUEST_PROJECTION"
echo "USER_AUTHORSHIP_REUSE_ALLOWED=NO"
echo "MODEL_INFERENCE_REQUIRED_FOR_PROJECTION=NO"
echo "PROJECTION_MUST_REMAIN_NON_AUTHORITATIVE=YES"
echo "PROJECTION_MUST_NOT_CREATE_APPROVAL_DELEGATION_EXECUTION_OR_VALIDATION_AUTHORITY=YES"
echo "QUESTION=Can an existing non-authoritative semantic boundary carry literal request-explicit expectedOutcome without changing authorship or authority semantics?"
echo "NEXT_ACTION=IDENTIFY_REUSE_OR_MINIMAL_NEW_BOUNDARY_THEN_REQUEST_IMPLEMENTATION_AUTHORIZATION"
