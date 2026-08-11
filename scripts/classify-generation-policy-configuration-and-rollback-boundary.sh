#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION POLICY CONFIGURATION AND ROLLBACK BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY AUTHORIZATION CHECKPOINT ==="
expected_head="f133b842"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches generation-control authorization checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-policy-configuration-and-rollback-boundary\.sh$|^ M scripts/classify-generation-policy-configuration-and-rollback-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING AUTHORIZATION BOUNDARY ==="
grep -nE \
  'PRODUCTION_POLICY_AUTHORITY=|MUST_BE_EXPLICITLY_ESTABLISHED_BEFORE_IMPLEMENTATION|OPERATIONAL_SAFETY_GATE=|ROLLBACK_BASELINE=|PRODUCTION_IMPLEMENTATION_AUTHORIZED=|CLASSIFY_GENERATION_POLICY_CONFIGURATION_AND_ROLLBACK_BOUNDARY' \
  scripts/classify-generation-control-authorization-and-ownership-boundary.sh

echo "GOVERNING_AUTHORIZATION_BOUNDARY=CONFIRMED"

echo
echo "=== INSPECT CURRENT CONFIGURATION SURFACE ==="
grep -RInE \
  'validationGenerationSeed|OLLAMA_CHAT_MODEL|OLLAMA_BASE_URL|temperature|top_p|top_k|seed:' \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server \
  --include='*.ts' |
  head -260 || true

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: explicit generation control is present in the production workflow."
  exit 2
fi

echo "PRODUCTION_EXPLICIT_GENERATION_CONTROL=ABSENT"
echo "ROLLBACK_BASELINE=CURRENT_UNSEEDED_PRODUCTION_BEHAVIOR"

echo
echo "=== CONFIGURATION AND ROLLBACK CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_POLICY_CONFIGURATION_AND_ROLLBACK_BOUNDARY
UNIT=CONFIGURATION_AND_ROLLBACK_CLASSIFICATION

CURRENT_PRODUCTION_CONFIGURATION=
  NO_EXPLICIT_SEED
  NO_EXPLICIT_TEMPERATURE
  NO_EXPLICIT_TOP_P
  NO_EXPLICIT_TOP_K

CURRENT_PRODUCTION_POLICY_SOURCE=
  OLLAMA_AND_MODEL_DEFAULTS

CURRENT_DIAGNOSTIC_CONFIGURATION_SEAM=
  REQUEST_SCOPED_validationGenerationSeed

CURRENT_SHARED_CONFIGURATION_OBJECT=
  NOT_ESTABLISHED

CURRENT_PRODUCTION_POLICY_OBSERVABILITY=
  NOT_ESTABLISHED_AS_A_GENERATION_POLICY_SURFACE

CURRENT_ROLLBACK_BASELINE=
  CURRENT_UNSEEDED_PRODUCTION_BEHAVIOR

CONFIGURATION_BOUNDARY=
  Any future shared production generation policy must be represented as an
  explicit bounded configuration surface rather than hidden ad hoc values at
  individual call sites.

REQUIRED_CONFIGURATION_PROPERTIES=
  - explicit control names;
  - bounded accepted values;
  - deterministic fallback behavior when configuration is absent;
  - clear distinction between diagnostic and production controls;
  - no implicit promotion of validationGenerationSeed;
  - no partially applied shared policy.

REQUIRED_OBSERVABILITY_PROPERTIES=
  Before production rollout, the active generation policy must be inspectable
  without inferring it from model behavior.

  Observability must distinguish:

  - no shared policy configured;
  - a shared production policy configured;
  - request-scoped diagnostic overrides;
  - the effective values sent to Ollama.

REQUIRED_ROLLBACK_PROPERTIES=
  Rollback must restore the current production baseline:

  - no explicit production seed;
  - no explicit production temperature;
  - no explicit production top_p;
  - no explicit production top_k;
  - one Ollama invocation preserved;
  - deterministic validators preserved;
  - prompt contract preserved;
  - no diagnostic control leakage.

ROLLBACK_MUST_BE=
  EXPLICIT
  TESTABLE
  REVERSIBLE
  BOUNDED

ROLLBACK_MUST_NOT_DEPEND_ON=
  - changing model-authored structured output;
  - weakening fail-closed validation;
  - deleting diagnostic validation seams;
  - retries;
  - multiple Ollama invocations;
  - manual hidden state.

FAILURE_CONTAINMENT_REQUIREMENT=
  If a future production generation policy causes contract regressions,
  rollback must restore the prior unconfigured production generation state
  without requiring additional semantic intervention.

CONFIGURATION_PRECEDENCE_REQUIREMENT=
  A future production design must explicitly define precedence between shared
  production policy and request-scoped diagnostic controls before
  implementation.

  Current evidence does not authorize choosing that precedence yet.

SAFE_DEFAULT=
  ABSENCE_OF_SHARED_PRODUCTION_POLICY

DIAGNOSTIC_SEED_SEAM=
  PRESERVE

PRODUCTION_POLICY_CONFIGURATION_IMPLEMENTATION=
  NOT_AUTHORIZED

PRODUCTION_POLICY_OBSERVABILITY_IMPLEMENTATION=
  NOT_AUTHORIZED

PRODUCTION_ROLLBACK_IMPLEMENTATION=
  NOT_AUTHORIZED

PRODUCTION_SEED=
  NOT_AUTHORIZED

PRODUCTION_TEMPERATURE=
  NOT_AUTHORIZED

PRODUCTION_TOP_P=
  NOT_AUTHORIZED

PRODUCTION_TOP_K=
  NOT_AUTHORIZED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

BOUNDARY_CLASSIFICATION_RESULT=
  CONFIGURATION_REQUIREMENTS_ESTABLISHED
  OBSERVABILITY_REQUIREMENTS_ESTABLISHED
  ROLLBACK_REQUIREMENTS_ESTABLISHED
  IMPLEMENTATION_NOT_AUTHORIZED

PHASE_2_STATUS=
  READY_FOR_PHASE_2_DISPOSITION_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_GENERATION_POLICY_AND_CONTROL_BOUNDARY_PHASE_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-policy-configuration-and-rollback-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-generation-policy-configuration-and-rollback-boundary.sh
git diff --cached --check
git commit -m "Classify generation policy rollback boundary"
git push
