#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

expected_head="b61e6f43"

echo "=== CLASSIFY PHASE 2 / CORRIDOR 5 — AUTHORIZATION & SEMANTIC PRESERVATION ==="

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches protected Corridor 4 checkpoint $expected_head."
  exit 1
fi

unexpected="$(
  git status --short |
  grep -vE '^\?\? scripts/classify-phase-2-authorization-and-semantic-preservation\.sh$|^ M scripts/classify-phase-2-authorization-and-semantic-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes."
  printf '%s\n' "$unexpected"
  exit 1
fi

echo "PROTECTED_BASELINE_DR=20260812_154150"

grep -q 'validationGenerationSeed?: number;' scripts/utils/ollamaChat.ts
grep -q 'seed: context.validationGenerationSeed' scripts/utils/ollamaChat.ts

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow now supplies validationGenerationSeed."
  exit 1
fi

grep -q 'NOT_PROVEN_WIDER_SEMANTICALLY_SAFE' \
  scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh

grep -q 'PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=' \
  scripts/classify-generation-control-authorization-and-ownership-boundary.sh

grep -q 'ROLLBACK_BASELINE=' \
  scripts/classify-generation-control-authorization-and-ownership-boundary.sh

grep -q 'CURRENT_UNSEEDED_PRODUCTION_BEHAVIOR' \
  scripts/classify-generation-control-authorization-and-ownership-boundary.sh

cat <<'FINDINGS'

PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=AUTHORIZATION_AND_SEMANTIC_PRESERVATION

PRODUCTION_GENERATION_POLICY_NECESSITY=
  NOT_ESTABLISHED

SEMANTICALLY_SAFE_PRODUCTION_POLICY=
  NOT_ESTABLISHED

FIXED_SEED_DIAGNOSTIC_STATUS=
  SUPPORTED_FOR_BOUNDED_KNOWN_FAILURE_SURFACE

FIXED_SEED_WIDER_SEMANTIC_SAFETY=
  NOT_ESTABLISHED

FIXED_SEED_PRODUCTION_REMEDY=
  NOT_ESTABLISHED

PRODUCTION_POLICY_AUTHORIZATION=
  NOT_GRANTED

PRODUCTION_IMPLEMENTATION_AUTHORIZATION=
  NOT_GRANTED

MATILDA_SEMANTIC_AUTHORSHIP=
  MUST_BE_PRESERVED

FAIL_CLOSED_SEMANTIC_VALIDATION=
  MUST_BE_PRESERVED

FUTURE_POLICY_SEMANTIC_EVIDENCE_GATE=
  REQUIRED_BEFORE_PRODUCTION_IMPLEMENTATION

FUTURE_POLICY_EXPLICIT_AUTHORIZATION_GATE=
  REQUIRED_BEFORE_PRODUCTION_IMPLEMENTATION

ROLLBACK_BASELINE=
  CURRENT_UNCONFIGURED_UNSEEDED_PRODUCTION_BEHAVIOR

PRODUCTION_POLICY_CHANGE=
  NONE

IMPLEMENTATION_REQUIRED_BY_CORRIDOR=
  NO

IMPLEMENTATION_AUTHORIZED=
  NO

CORRIDOR_STATUS=
  COMPLETE

PHASE_2_CORRIDOR_SEQUENCE_STATUS=
  ALL_FIVE_CANONICAL_CORRIDORS_COMPLETE

NEXT_ACTION=
  VERIFY_AND_CLASSIFY_PHASE_2_DISPOSITION_BEFORE_PHASE_3
FINDINGS
