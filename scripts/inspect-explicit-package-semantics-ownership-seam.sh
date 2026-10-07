#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== EXPLICIT PACKAGE SEMANTICS OWNERSHIP SEAM ==="
echo "INVESTIGATION_ONLY=YES"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEW_IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== OLLAMA CONTEXT CONTRACT ==="
sed -n '250,330p' scripts/utils/ollamaChat.ts

echo
echo "=== EXPLICIT USER PACKAGE SEMANTICS VALIDATION ==="
sed -n '430,535p' scripts/utils/ollamaChat.ts

echo
echo "=== OLLAMA INVOCATION INPUT NORMALIZATION ==="
sed -n '1035,1065p' scripts/utils/ollamaChat.ts

echo
echo "=== PROMPT PRESENTATION ==="
sed -n '1335,1370p' scripts/utils/ollamaChat.ts

echo
echo "=== POST-GENERATION FIDELITY ==="
sed -n '1450,1495p' scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW INPUT CONTRACT ==="
sed -n '45,75p' server/matilda-chat-workflow.ts

echo
echo "=== WORKFLOW CONCRETE OPERATION DECISION ==="
sed -n '200,230p' server/matilda-chat-workflow.ts

echo
echo "=== WORKFLOW OLLAMA HANDOFF ==="
sed -n '350,405p' server/matilda-chat-workflow.ts

echo
echo "=== ALL PRODUCTION CALLERS / POPULATORS ==="
grep -RInE \
  'userPackageSemantics|packageSemanticsInput|explicitUserPackageSemantics|expectedOutcome:' \
  server db scripts \
  --exclude='*.test.ts' \
  --exclude='*.test.mjs' \
  --exclude='*.sh' \
  --exclude='*.py' \
  2>/dev/null | head -n 260 || true

echo
echo "=== TESTED AUTHORSHIP CONTRACT ==="
grep -RInE \
  'userPackageSemantics|explicit user package semantics|typed expectedOutcome|preserved exactly|user-authored intent evidence' \
  server scripts \
  --include='*.test.ts' \
  2>/dev/null | head -n 260 || true

echo
echo "=== CONCRETE OPERATION CLASSIFIER IMPLEMENTATION ==="
sed -n '120,195p' server/matilda-project-context-retrieval.ts

echo
echo "=== DETERMINATION GATE ==="
echo "QUESTION_1=Does an existing production workflow input already represent explicitly user-authored Package Semantics?"
echo "QUESTION_2=Can concrete request text be projected into that input without falsely labeling inferred semantics as user-authored?"
echo "QUESTION_3=Is a narrower request-explicit projection seam required instead of changing model prompting?"
echo "ATTEMPT_CLASS=OWNERSHIP_AND_PROJECTION_ARCHITECTURE"
echo "NEXT_ACTION=CLASSIFY_AUTHORSHIP_BOUNDARY_FROM_EXACT_CODE_BEFORE_ANY_IMPLEMENTATION"
