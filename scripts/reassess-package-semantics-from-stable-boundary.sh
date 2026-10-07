#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c6aadb6fa"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== STABLE BOUNDARY ==="
echo "TARGETED_GROUNDING_REVERT=COMPLETE"
echo "GROUNDING_ATTEMPTS_2_AND_3_REMOVED=YES"
echo "DOGFOOD_RETRY_AUTHORIZED=NO"
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"
echo "INVESTIGATION_ONLY=YES"

echo
echo "=== PACKAGE SEMANTICS TYPE / OWNERSHIP ==="
grep -RInE \
  'MatildaPackageSemanticsArtifact|packageSemantics|expectedOutcome|requirePackageSemantics|concreteOperationMessage' \
  server scripts db routes 2>/dev/null | head -n 320 || true

echo
echo "=== CONCRETE OPERATION DERIVATION ==="
grep -RInE \
  'hasConcreteProjectOperation|CONCRETE_PROJECT_OPERATION_TERMS|concreteOperationMessage|requirePackageSemantics' \
  server scripts 2>/dev/null | head -n 220 || true

echo
echo "=== WORKFLOW HANDOFF INTO OLLAMA ==="
grep -nE \
  'ollamaChat|requirePackageSemantics|concreteOperationMessage|packageSemantics|expectedOutcome' \
  server/matilda-chat-workflow.ts 2>/dev/null || true

echo
echo "=== PARSE AND PERSISTENCE BOUNDARIES ==="
grep -RInE \
  'packageSemantics|package_semantics_json|expectedOutcome|living.*draft|LivingDraft' \
  server db scripts 2>/dev/null | head -n 320 || true

echo
echo "=== EXISTING DETERMINISTIC / USER-AUTHORED SEMANTICS PATHS ==="
grep -RInE \
  'user.*package.*semantics|validatedUserPackageSemantics|typed.*semantics|derive.*semantics|normalize.*semantics|explicit.*package.*semantics' \
  server scripts db 2>/dev/null | head -n 260 || true

echo
echo "=== ARCHITECTURAL QUESTION ==="
echo "QUESTION=Should request-explicit Package Semantics be deterministically projected from already-established user intent before model generation, while leaving inference-only semantics model-authored?"
echo "ATTEMPT_CLASS=DIFFERENT_FROM_PROMPT_GROUNDING"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=CLASSIFY_EXISTING_OWNERSHIP_AND_PROJECTION_SEAMS_BEFORE_PROPOSING_ANY_IMPLEMENTATION"
