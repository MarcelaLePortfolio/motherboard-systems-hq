#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

expected_head="b0a84ebb"

echo "=== CLASSIFY PHASE 2 / CORRIDOR 3 — VALIDATION VS PRODUCTION CONTROLS ==="

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches protected Corridor 2 checkpoint $expected_head."
  exit 1
fi

unexpected="$(
  git status --short |
  grep -vE '^\?\? scripts/classify-phase-2-validation-vs-production-controls\.sh$|^ M scripts/classify-phase-2-validation-vs-production-controls\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes."
  printf '%s\n' "$unexpected"
  exit 1
fi

echo "PROTECTED_BASELINE_DR=20260812_152517"

grep -q 'validationGenerationSeed?: number;' scripts/utils/ollamaChat.ts
grep -q 'seed: context.validationGenerationSeed' scripts/utils/ollamaChat.ts

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 1
fi

if grep -q 'validationGenerationSeed' routes/matilda.ts; then
  echo "STOP: direct production route supplies validationGenerationSeed."
  exit 1
fi

grep -q 'FIXED_SEED=424242' scripts/classify-bounded-fixed-seed-diagnostic-result.sh
grep -q 'PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT' \
  scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh

cat <<'FINDINGS'

PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=VALIDATION_VS_PRODUCTION_CONTROLS

REQUEST_SCOPED_VALIDATION_CONTROL=
  validationGenerationSeed

FIXED_VALIDATION_SEED=
  424242

ORDINARY_PRODUCTION_WORKFLOW_VALIDATION_SEED=
  ABSENT

DIRECT_PRODUCTION_ROUTE_VALIDATION_SEED=
  ABSENT

VALIDATION_CONTROL_SILENT_PRODUCTION_DEFAULT=
  NO

DIAGNOSTIC_REPEATABILITY=
  ESTABLISHED_ON_BOUNDED_FIXED_SEED_SURFACE

PRODUCTION_SEMANTIC_RELIABILITY_FROM_DIAGNOSTIC_REPEATABILITY=
  NOT_ESTABLISHED

FIXED_SEED_PRODUCTION_POLICY=
  NOT_ESTABLISHED

FIXED_SEED_PRODUCTION_REMEDY=
  NOT_ESTABLISHED

VALIDATION_VS_PRODUCTION_BOUNDARY=
  PRESERVED

BOUNDARY_CHANGE_REQUIRED=
  NO

PRODUCTION_POLICY_CHANGE=
  NONE

IMPLEMENTATION_AUTHORIZED=
  NO

CORRIDOR_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  REQUEST_VS_SHARED_POLICY
FINDINGS
