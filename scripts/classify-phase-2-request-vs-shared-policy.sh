#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

expected_head="c88ea891"

echo "=== CLASSIFY PHASE 2 / CORRIDOR 4 — REQUEST VS SHARED POLICY ==="

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches protected Corridor 3 checkpoint $expected_head."
  exit 1
fi

unexpected="$(
  git status --short |
  grep -vE '^\?\? scripts/classify-phase-2-request-vs-shared-policy\.sh$|^ M scripts/classify-phase-2-request-vs-shared-policy\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes."
  printf '%s\n' "$unexpected"
  exit 1
fi

echo "PROTECTED_BASELINE_DR=20260812_153508"

grep -q 'validationGenerationSeed?: number;' scripts/utils/ollamaChat.ts
grep -q 'seed: context.validationGenerationSeed' scripts/utils/ollamaChat.ts

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: ordinary production workflow now supplies request-scoped generation control."
  exit 1
fi

if grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'generationPolicy|generation_policy|samplingPolicy|sampling_policy' \
  server routes app src config 2>/dev/null
then
  echo "STOP: shared generation-policy surface detected and requires separate classification."
  exit 1
fi

cat <<'FINDINGS'

PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=REQUEST_VS_SHARED_POLICY

ESTABLISHED_GENERATION_CONTROL_SEAM=
  REQUEST_SCOPED

ESTABLISHED_REQUEST_SCOPED_CONTROL=
  validationGenerationSeed

ESTABLISHED_REQUEST_SCOPED_PURPOSE=
  BOUNDED_DIAGNOSTIC_VALIDATION

ORDINARY_PRODUCTION_REQUEST_SCOPED_CONTROL=
  ABSENT

SHARED_CONVERSATION_ENGINE_SAMPLING_POLICY=
  ABSENT

SHARED_POLICY_REQUIRED_BY_CURRENT_EVIDENCE=
  NO

FUTURE_PRODUCTION_CONTROL_OWNERSHIP=
  NOT_YET_ESTABLISHED

OWNERSHIP_RULE=
  OWNERSHIP_MUST_FOLLOW_EVIDENCE_SUPPORTED_POLICY_SCOPE_NOT_CONFIGURATION_CONVENIENCE

REQUEST_SCOPED_POLICY_MAY_BE_APPROPRIATE_WHEN=
  CONTROL_IS_INTENTIONALLY_BOUNDED_TO_ONE_INVOCATION

SHARED_POLICY_MAY_BE_APPROPRIATE_WHEN=
  CONTROL_IS_SEPARATELY_ESTABLISHED_AS_A_COMMON_PRODUCTION_REQUIREMENT

ONE_WORKFLOW_ARCHITECTURE=
  PRESERVED

ONE_OLLAMA_INVOCATION_ARCHITECTURE=
  PRESERVED

NEW_SHARED_POLICY_LAYER=
  NOT_JUSTIFIED

PRODUCTION_POLICY_CHANGE=
  NONE

IMPLEMENTATION_AUTHORIZED=
  NO

CORRIDOR_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  AUTHORIZATION_AND_SEMANTIC_PRESERVATION
FINDINGS
