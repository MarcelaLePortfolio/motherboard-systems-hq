#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e033fcbe9"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "ATTEMPT_3_AUTHORIZED=YES"
echo "AUTHORIZED_HYPOTHESIS=DETERMINISTIC_CURRENT_REQUEST_GROUNDING_BEFORE_MODEL_GENERATION"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "LIVE_DOGFOOD=NO"

echo
echo "=== CONCRETE OPERATION FIDELITY IMPLEMENTATION ==="
grep -n -A95 -B20 \
  'function enforceConcreteOperationPackageSemanticsFidelity' \
  "$TARGET"

echo
echo "=== REQUIRE PACKAGE SEMANTICS PROMPT REGION ==="
grep -n -A25 -B20 \
  'The current request requires durable Package Semantics' \
  "$TARGET"

echo
echo "=== CURRENT REQUEST PROMPT PRESENTATION ==="
grep -n -A12 -B12 \
  'Current user request' \
  "$TARGET" || true

echo
echo "=== MESSAGE / PROMPT CONSTRUCTION REFERENCES ==="
grep -nE \
  'const message|message:|currentRequest|Current user request|requirePackageSemantics|messages:' \
  "$TARGET" | head -n 160

echo
echo "=== EXISTING DETERMINISTIC OPERATION HELPERS ==="
grep -nE \
  'operationTerms|operationSemanticTerms|concreteOperation|normalize.*Token|tokenize|subject' \
  "$TARGET" | head -n 200

echo
echo "=== AUTHORIZED ATTEMPT 3 BOUNDARY ==="
echo "GOAL=Derive the smallest deterministic current-request operation-and-subject grounding and present it before model generation."
echo "MUST_NOT_CHANGE=FIDELITY_GUARD,PARSER,OUTPUT_SCHEMA,AUTHORITY_MODEL"
echo "NEXT_ACTION=IMPLEMENT_ONLY_AFTER_EXACT_INSERTION_BOUNDARY_IS_CONFIRMED"
