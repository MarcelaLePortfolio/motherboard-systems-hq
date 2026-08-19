#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=f84a2762' \
  'OLLAMA_SERVICE=HEALTHY' \
  'GEMMA3_4B=AVAILABLE' \
  'DIRECT_MODEL_GENERATION=PASS' \
  'TARGET=RUN_MATILDA_STUB_AND_WORKFLOW_FAILURE_BOUNDARY' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE'

printf '\n=== RUN MATILDA STUB IMPORT ===\n'
sed -n '1,125p' server/matilda-chat-workflow.ts

printf '\n=== FULL WORKFLOW FAILURE REGION ===\n'
sed -n '100,370p' server/matilda-chat-workflow.ts

printf '\n=== RUN MATILDA STUB DEFINITION ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'export (async )?function runMatildaStub|export const runMatildaStub|function runMatildaStub' \
  . 2>/dev/null | head -80

printf '\n=== STUB CALLERS AND TESTS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'runMatildaStub\(' \
  server db routes scripts 2>/dev/null | head -160

printf '\n=== STRUCTURED RESPONSE PARSER / VALIDATOR ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'JSON\.parse|structured.*response|parse.*response|supportSourceReferences|validate.*response|validationGenerationSeed|options\.seed' \
  server db routes 2>/dev/null | head -420

printf '\n=== IMPORTANT OBSERVATION ===\n'
printf '%s\n' \
  'UNIT_TESTS_PASS=YES' \
  'UNIT_TESTS_EXERCISE_LIVE_GENERATION_PATH=NOT_ESTABLISHED' \
  '503_CATCH_BOUNDARY_IS_BROAD=YES' \
  'THROWN_CAUSE_IS_CURRENTLY_MASKED_BY_GENERIC_UNAVAILABLE_ERROR=YES' \
  'NEXT_REQUIRED_EVIDENCE=IDENTIFY_ORIGINAL_ERROR_INSIDE_WORKFLOW_CATCH' \
  'FIX_NOT_YET_JUSTIFIED=YES'

printf '\n=== WORKTREE ===\n'
git status --short
