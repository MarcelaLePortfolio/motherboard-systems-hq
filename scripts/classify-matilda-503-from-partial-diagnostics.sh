#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_COMMIT=1ec70230' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE'

printf '\n=== OBSERVED EVIDENCE ===\n'
printf '%s\n' \
  'HTTP_503_ORIGIN=routes/api-chat.ts' \
  '503_TRIGGER=MatildaConversationWorkflowUnavailableError' \
  'WORKFLOW_ERROR_THROW_SITE=server/matilda-chat-workflow.ts' \
  'OLLAMA_HEALTH_RESULT=NOT_CAPTURED_IN_PASTED_OUTPUT' \
  'MODEL_PRESENCE_RESULT=NOT_CAPTURED_IN_PASTED_OUTPUT' \
  'DIRECT_GENERATION_RESULT=NOT_CAPTURED_IN_PASTED_OUTPUT'

printf '\n=== REQUIRED FOLLOW-UP ===\n'
printf '%s\n' \
  'CLASSIFICATION=INSUFFICIENT_EVIDENCE_TO_LOCALIZE_ROOT_CAUSE' \
  'NEXT_STEP=RUN_ONLY_OLLAMA_AND_MODEL_AVAILABILITY_CHECKS' \
  'NO_FIX_AUTHORIZED=YES'

printf '\n=== OLLAMA SERVICE HEALTH ===\n'
curl -sS --max-time 5 http://127.0.0.1:11434/api/tags || true

printf '\n=== DIRECT MODEL CHECK ===\n'
curl -sS --max-time 30 \
  http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"gemma3:4b","prompt":"Reply with exactly MODEL_OK","stream":false}' || true

printf '\n=== WORKTREE ===\n'
git status --short
