#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'OLLAMA_API_REACHABLE=YES' \
  'REQUIRED_MODEL_PRESENT=YES' \
  'DIRECT_GEMMA3_4B_GENERATION=PASS' \
  'OLLAMA_ROOT_CAUSE=RULED_OUT' \
  'NEXT_HYPOTHESIS=MATILDA_ADAPTER_OR_STRUCTURED_VALIDATION_PATH' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE'

printf '\n=== EXACT WORKFLOW THROW BOUNDARY ===\n'
sed -n '330,375p' server/matilda-chat-workflow.ts

printf '\n=== RUN MATILDA STUB LOCATION ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'runMatildaStub' server db routes 2>/dev/null | head -120

printf '\n=== ADAPTER / VALIDATION FAILURE SURFACE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'project-context support reference|semantic acceptance|structured response|validateMatilda|parseMatilda|fail.closed|Ollama returned|supportSourceReferences' \
  server db routes 2>/dev/null | head -360

printf '\n=== MATILDA ADAPTER SOURCES ===\n'
find server db routes -type f \
  \( -iname '*matilda*' -o -iname '*ollama*' \) \
  -not -path '*/node_modules/*' \
  -print | sort

printf '\n=== WORKFLOW TEST SURFACES ===\n'
find server db routes -type f \
  \( -name '*matilda*test.ts' -o -name '*ollama*test.ts' \) \
  -not -path '*/node_modules/*' \
  -print | sort

printf '\n=== EXISTING TARGETED MATILDA TESTS ===\n'
while IFS= read -r test_file; do
  echo
  echo ">>> RUNNING: $test_file"
  npx tsx "$test_file" || true
done < <(
  find server db routes -type f \
    \( -name '*matilda*test.ts' -o -name '*ollama*test.ts' \) \
    -not -path '*/node_modules/*' \
    -print | sort
)

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'OLLAMA_SERVICE=HEALTHY' \
  'GEMMA3_4B=AVAILABLE' \
  'DIRECT_MODEL_GENERATION=PASS' \
  'CURRENT_FAILURE_CLASS=MATILDA_APPLICATION_PATH' \
  'NO_FIX_AUTHORIZED=YES' \
  'NEXT_ACTION=CLASSIFY_EXACT_ADAPTER_OR_VALIDATOR_FAILURE_FROM_OUTPUT'

printf '\n=== WORKTREE ===\n'
git status --short
