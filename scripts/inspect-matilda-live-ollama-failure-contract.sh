#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=bd8afbc8' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'KNOWN=OLLAMA_AND_MODEL_HEALTHY' \
  'KNOWN=FAILURE_OCCURS_INSIDE_WORKFLOW_TRY_BOUNDARY' \
  'TARGET=OLLAMA_CHAT_LIVE_GENERATION_AND_VALIDATION_CONTRACT'

printf '\n=== OLLAMA CHAT IMPLEMENTATION ===\n'
sed -n '1,420p' scripts/utils/ollamaChat.ts

printf '\n=== OLLAMA CHAT RELATED TESTS AND RUNNERS ===\n'
find . \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( -iname '*ollama*test*' -o -iname '*generation*runner*' -o -iname '*generation*stability*' \) \
  -print 2>/dev/null | sort | head -240

printf '\n=== EXACT FAIL-CLOSED ERROR STRINGS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E \
  'Ollama returned|project-context support reference|support reference.*not supplied|semantic acceptance|durableInterpretation|evidenceSufficient|investigationLifecycle' \
  scripts server db routes 2>/dev/null | head -500

printf '\n=== GENERATION POLICY / DIAGNOSTIC SEED SURFACE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E \
  'validationGenerationSeed|424242|options.*seed|seed.*options|temperature|top_p|top_k' \
  scripts server db routes 2>/dev/null | head -360

printf '\n=== CURRENT HYPOTHESIS CLASSIFICATION ===\n'
printf '%s\n' \
  'HYPOTHESIS=LIVE_OLLAMA_RESPONSE_FAILS_APPLICATION_STRUCTURED_OR_PROVENANCE_VALIDATION' \
  'RATIONALE=OLLAMA_DIRECT_GENERATION_PASSES_BUT_WORKFLOW_OLLAMA_CHAT_REMAINS_INSIDE_503_BOUNDARY' \
  'PRIOR_GENERATION_INSTABILITY_RELEVANT=YES' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'PRODUCTION_SEED_AUTHORIZED=NO' \
  'RETRY_POLICY_AUTHORIZED=NO' \
  'NEXT_ACTION=IDENTIFY_EXACT_FAIL_CLOSED_CONDITION_BEFORE_ANY_FIX'

printf '\n=== WORKTREE ===\n'
git status --short
