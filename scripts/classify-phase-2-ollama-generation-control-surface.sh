#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

expected_head="28814506"

echo "=== CLASSIFY PHASE 2 / CORRIDOR 2 — OLLAMA GENERATION CONTROLS ==="

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Ollama control-surface investigation checkpoint $expected_head."
  exit 1
fi

unexpected="$(
  git status --short |
  grep -vE '^\?\? scripts/classify-phase-2-ollama-generation-control-surface\.sh$|^ M scripts/classify-phase-2-ollama-generation-control-surface\.sh$' ||
  true
)"
if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes."
  printf '%s\n' "$unexpected"
  exit 1
fi

grep -q 'CURRENT_REPOSITORY_GENERATION_CONTROL=REQUEST_SCOPED_validationGenerationSeed' \
  scripts/reconcile-phase-2-ollama-generation-control-surface.sh

grep -q 'CURRENT_PRODUCTION_EXPLICIT_GENERATION_CONTROL=ABSENT' \
  scripts/reconcile-phase-2-ollama-generation-control-surface.sh

grep -q 'validationGenerationSeed?: number;' scripts/utils/ollamaChat.ts
grep -q 'seed: context.validationGenerationSeed' scripts/utils/ollamaChat.ts

if grep -nE \
  'temperature[[:space:]]*:|top_p[[:space:]]*:|top_k[[:space:]]*:|repeat_penalty[[:space:]]*:|num_predict[[:space:]]*:|num_ctx[[:space:]]*:' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: additional explicit adapter generation controls require classification."
  exit 1
fi

cat <<'FINDINGS'

PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=OLLAMA_GENERATION_CONTROLS

VERIFIED_REPOSITORY_CONTROL_SURFACE=
  REQUEST_SCOPED_validationGenerationSeed

VERIFIED_OLLAMA_REQUEST_MAPPING=
  validationGenerationSeed_TO_options.seed

ORDINARY_PRODUCTION_EXPLICIT_GENERATION_CONTROL=
  ABSENT

ADDITIONAL_REPOSITORY_SUPPORTED_PRODUCTION_CONTROL_NEED=
  NOT_ESTABLISHED

TEMPERATURE_PRODUCTION_NEED=
  NOT_ESTABLISHED

TOP_P_PRODUCTION_NEED=
  NOT_ESTABLISHED

TOP_K_PRODUCTION_NEED=
  NOT_ESTABLISHED

RETRY_POLICY_NEED=
  NOT_ESTABLISHED

MODEL_CHANGE_NEED=
  NOT_ESTABLISHED

CONTROL_AVAILABILITY_RULE=
  OLLAMA_CAPABILITY_AVAILABILITY_DOES_NOT_ESTABLISH_REPOSITORY_NEED

SEMANTIC_AUTHORITY=
  MATILDA_REMAINS_SEMANTIC_AUTHOR

DETERMINISTIC_CONTROL_ROLE=
  MAY_CONSTRAIN_GENERATION_ENVIRONMENT_ONLY_IF_SEPARATELY_SUPPORTED_AND_AUTHORIZED

ROLLBACK_BASELINE=
  CURRENT_UNCONFIGURED_PRODUCTION_SAMPLING_STATE

PRODUCTION_POLICY_CHANGE=
  NONE

IMPLEMENTATION_AUTHORIZED=
  NO

CORRIDOR_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  VALIDATION_VS_PRODUCTION_CONTROLS
FINDINGS

echo
echo "=== FINAL WORKTREE ==="
git status --short
