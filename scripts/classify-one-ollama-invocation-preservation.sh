#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY ONE OLLAMA INVOCATION PRESERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="36589be8"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches selectedHistory preservation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-one-ollama-invocation-preservation\.sh$|^ M scripts/classify-one-ollama-invocation-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SELECTED_HISTORY_PRESERVATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CURRENT SINGLE INVOCATION CONTRACT ==="

workflow_calls="$(grep -Ec 'await[[:space:]]+ollamaChat\(' server/matilda-chat-workflow.ts || true)"
if [[ "$workflow_calls" -ne 1 ]]; then
  echo "STOP: expected exactly one workflow ollamaChat invocation; found $workflow_calls."
  exit 2
fi

grep -q '/api/generate' scripts/utils/ollamaChat.ts

echo "ONE_OLLAMA_INVOCATION_RUNTIME_CONTRACT=CONFIRMED"

echo
echo "=== ONE OLLAMA INVOCATION PRESERVATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  OPTIMIZATION_INTEGRATION_AND_CLOSURE

CORRIDOR=
  ONE_OLLAMA_INVOCATION_PRESERVATION

CURRENT_WORKFLOW_OLLAMA_INVOCATIONS=
  ONE

CURRENT_OLLAMA_ENDPOINT=
  /api/generate

MULTI_INVOCATION_OPTIMIZATION_REQUIREMENT=
  NOT_ESTABLISHED

RETRY_GENERATION_REQUIREMENT=
  NOT_ESTABLISHED

PARALLEL_GENERATION_REQUIREMENT=
  NOT_ESTABLISHED

SECOND_PASS_GENERATION_REQUIREMENT=
  NOT_ESTABLISHED

ONE_OLLAMA_INVOCATION_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

ONE_OLLAMA_INVOCATION=
  PRESERVE

CLASSIFICATION=
  EXISTING_SINGLE_GENERATION_INVOCATION_CONTRACT_REMAINS_VALID_AND_UNCHANGED

RATIONALE=
  No completed semantic-history optimization phase established a requirement
  for additional model invocations.

  Semantic ranking was not established as required.

  Token-budget or history-window optimization was not established as required.

  Hybrid-context coordination and model-runtime context changes were not
  established as required.

  Therefore there is no evidence-supported reason to introduce retries,
  parallel generation, second-pass generation, or any additional Ollama call.

  The existing one-user-message to one-workflow to one-Ollama-invocation
  contract remains preserved.

RETRIES=
  NOT_AUTHORIZED

PARALLEL_GENERATION=
  NOT_AUTHORIZED

SECOND_PASS_GENERATION=
  NOT_AUTHORIZED

MULTI_MODEL_GENERATION=
  NOT_AUTHORIZED

SELECTED_HISTORY_CONTRACT=
  PRESERVE

CONVERSATION_CONTEXT_RUNTIME=
  PRESERVE

PROJECT_CONTEXT_CHANNEL=
  PRESERVE

PRIOR_INVESTIGATION_LIFECYCLE_CHANNEL=
  PRESERVE

STRUCTURED_RESPONSE_CONTRACT=
  PRESERVE

FAIL_CLOSED_VALIDATION=
  PRESERVE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

ONE_OLLAMA_INVOCATION_PRESERVATION_CORRIDOR=
  COMPLETE

NEXT_CORRIDOR=
  DETERMINISTIC_REGRESSION_VALIDATION

NEXT_ACTION=
  CLASSIFY_DETERMINISTIC_REGRESSION_VALIDATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-one-ollama-invocation-preservation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside one-Ollama-invocation preservation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
