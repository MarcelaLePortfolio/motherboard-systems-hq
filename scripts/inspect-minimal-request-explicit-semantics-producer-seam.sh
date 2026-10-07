#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== MINIMAL REQUEST-EXPLICIT SEMANTICS PRODUCER SEAM ==="
echo "INVESTIGATION_ONLY=YES"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== CURRENT WORKFLOW SEQUENCE ==="
sed -n '350,410p' server/matilda-chat-workflow.ts

echo
echo "=== PACKAGE SEMANTICS REQUIREMENT ==="
sed -n '78,100p' server/matilda-chat-workflow.ts

echo
echo "=== PACKAGE SEMANTICS VALIDATION / PARSE ==="
sed -n '380,455p' scripts/utils/ollamaChat.ts
grep -nE \
  'parseStructuredResponse|validateMatildaPackageSemanticsArtifact|packageSemantics:' \
  scripts/utils/ollamaChat.ts | head -n 100

echo
echo "=== EXISTING DETERMINISTIC PROJECTION PRECEDENTS ==="
sed -n '1560,1655p' scripts/utils/ollamaChat.ts

echo
echo "=== CONCRETE OPERATION CLASSIFIER ==="
sed -n '145,195p' server/matilda-project-context-retrieval.ts

echo
echo "=== EXISTING OPERATION / SUBJECT EXTRACTION ==="
grep -RInE \
  'operationTerms|subjectTerms|expectedOutcome fidelity|concreteOperationMessage|normalize.*operation|extract.*operation|extract.*subject' \
  server scripts \
  --exclude='*.sh' \
  2>/dev/null | head -n 240 || true

echo
echo "=== PERSISTENCE CONSUMERS EXPECTING SAME ARTIFACT ==="
grep -RInE \
  'packageSemantics|package_semantics_json|selectedPackageSemantics' \
  db/matilda-interpretation-runtime.ts \
  db/matilda-draft-synthesis-runtime.ts \
  server/atlas/atlas-preexecution-read-model.ts \
  2>/dev/null | head -n 220 || true

echo
echo "=== REQUIRED INVARIANTS ==="
echo "ARTIFACT_TYPE_REUSE=MatildaPackageSemanticsArtifact"
echo "USER_PACKAGE_SEMANTICS_AUTHORSHIP_PATH_UNCHANGED=REQUIRED"
echo "EXPLICIT_USER_FIDELITY_UNCHANGED=REQUIRED"
echo "MODEL_PACKAGE_SEMANTICS_SCHEMA_UNCHANGED=REQUIRED"
echo "ONLY_LITERAL_REQUEST_ESTABLISHED_EXPECTED_OUTCOME_PROJECTABLE=YES"
echo "OTHER_FIELDS_REMAIN_MODEL_AUTHORED_OR_NULL=YES"
echo "PROJECTION_NON_AUTHORITATIVE=YES"
echo "APPROVAL_AUTHORITY_CREATED=NO"
echo "DELEGATION_AUTHORITY_CREATED=NO"
echo "VALIDATION_AUTHORITY_CREATED=NO"
echo "EXECUTION_AUTHORITY_CREATED=NO"

echo
echo "=== DECISION GATE ==="
echo "QUESTION=Can expectedOutcome be deterministically reconciled after model parsing but before workflow requirement enforcement and persistence, using only literal operation-and-subject information established by the current request?"
echo "SUCCESS_CONDITION=NO_NEW_ARTIFACT_TYPE_NO_USER_AUTHORSHIP_RECLASSIFICATION_NO_AUTHORITY_CHANGE"
echo "NEXT_ACTION=IF_SUPPORTED_REQUEST_EXPLICIT_IMPLEMENTATION_AUTHORIZATION_FOR_THIS_NARROW_SEAM"
