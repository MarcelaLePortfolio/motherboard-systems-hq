#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION CONTROL AUTHORIZATION AND OWNERSHIP BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REQUEST-SCOPED POLICY CHECKPOINT ==="
expected_head="76a9326b"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches request-scoped generation-policy checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-control-authorization-and-ownership-boundary\.sh$|^ M scripts/classify-generation-control-authorization-and-ownership-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REQUEST_SCOPED_POLICY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING POLICY BOUNDARY ==="
grep -nE \
  'REQUEST_SCOPED_DIAGNOSTIC_CONTROL_ESTABLISHED|SHARED_PRODUCTION_POLICY_NOT_ESTABLISHED|SEPARATE_EXPLICIT_POLICY_DECISION_REQUIRED|PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=|PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=|CLASSIFY_GENERATION_CONTROL_AUTHORIZATION_AND_OWNERSHIP_BOUNDARY' \
  scripts/classify-request-scoped-vs-shared-generation-policy-boundary.sh

echo "GOVERNING_POLICY_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY SEMANTIC-PRESERVATION DISPOSITION ==="
grep -nE \
  'DEFER_PRODUCTION_PROMOTION|NOT_PROVEN_WIDER_SEMANTICALLY_SAFE|PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=|SEMANTIC_PRESERVATION_CORRIDOR_STATUS=' \
  scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh

echo "SEMANTIC_PRESERVATION_DISPOSITION=CONFIRMED"

echo
echo "=== VERIFY CURRENT REQUEST-SCOPED CONTROL ==="
grep -nE \
  'validationGenerationSeed|seed: context\.validationGenerationSeed' \
  scripts/utils/ollamaChat.ts

echo "REQUEST_SCOPED_CONTROL=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS CONTROL-FREE ==="
if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow now contains explicit generation control."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_EXPLICIT_GENERATION_CONTROL=ABSENT"

echo
echo "=== AUTHORIZATION AND OWNERSHIP CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_AUTHORIZATION_AND_OWNERSHIP_BOUNDARY
UNIT=AUTHORIZATION_AND_OWNERSHIP_CLASSIFICATION

CURRENT_REQUEST_SCOPED_CONTROL=
  validationGenerationSeed

CURRENT_REQUEST_SCOPED_CONTROL_OWNER=
  CALLER_OF_OLLAMA_CHAT

CURRENT_REQUEST_SCOPED_CONTROL_PURPOSE=
  BOUNDED_DIAGNOSTIC_VALIDATION

CURRENT_REQUEST_SCOPED_AUTHORIZATION=
  ESTABLISHED_FOR_DIAGNOSTIC_USE_ONLY

SHARED_PRODUCTION_POLICY_OWNER=
  NOT_YET_ESTABLISHED

PRODUCTION_POLICY_AUTHORITY=
  MUST_BE_EXPLICITLY_ESTABLISHED_BEFORE_IMPLEMENTATION

RATIONALE=
  The existing validationGenerationSeed seam is caller-supplied and
  request-scoped.

  It has no ordinary production caller and therefore does not currently
  exercise shared production-policy authority.

  Promoting a seed or any other sampling control into normal production would
  introduce a shared behavioral policy affecting all model-authored response
  responsibilities that traverse the production workflow.

AUTHORIZATION_INVARIANT=
  Diagnostic availability is not production authorization.

  A control being technically implementable does not authorize changing
  ordinary production generation behavior.

PRODUCTION_POLICY_DECISION_OWNER_REQUIREMENT=
  A production generation-policy owner must be explicitly identified at the
  Conversation Engine policy boundary before implementation.

  The owner must have authority to approve:

  - behavioral scope;
  - semantic tradeoffs;
  - default configuration;
  - operational rollout;
  - rollback;
  - validation requirements;
  - failure disposition.

IMPLEMENTATION_AUTHORITY_REQUIREMENT=
  Explicit production implementation authorization must be separate from:

  - diagnostic experiment authorization;
  - fixture implementation authorization;
  - test execution authorization;
  - technical feasibility;
  - candidate support on one failure surface.

SEMANTIC_EVIDENCE_GATE=
  REQUIRED

  Production promotion must not occur while wider semantic preservation
  remains unresolved.

OPERATIONAL_SAFETY_GATE=
  REQUIRED_BEFORE_PRODUCTION_IMPLEMENTATION

  Any shared production generation control must define:

  - bounded configuration semantics;
  - safe default behavior;
  - observable active configuration;
  - rollback to the prior unconfigured production state;
  - validation of the rollback path;
  - no accidental diagnostic-to-production leakage.

ROLLBACK_BASELINE=
  CURRENT_UNSEEDED_PRODUCTION_BEHAVIOR

  The current production workflow supplies no validation seed and no explicit
  temperature, top_p, or top_k control.

REQUEST_SCOPED_DIAGNOSTIC_CONTROL=
  PRESERVE

SHARED_PRODUCTION_POLICY=
  DO_NOT_IMPLEMENT

PRODUCTION_SEED=
  NOT_AUTHORIZED

PRODUCTION_TEMPERATURE=
  NOT_AUTHORIZED

PRODUCTION_TOP_P=
  NOT_AUTHORIZED

PRODUCTION_TOP_K=
  NOT_AUTHORIZED

RETRY_POLICY_CHANGE=
  NOT_AUTHORIZED

MODEL_CHANGE=
  NOT_AUTHORIZED

PROMPT_CHANGE=
  NOT_AUTHORIZED_BY_THIS_CORRIDOR

VALIDATOR_RELAXATION=
  NOT_AUTHORIZED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

AUTHORIZATION_BOUNDARY_RESULT=
  DIAGNOSTIC_AUTHORITY_ESTABLISHED
  PRODUCTION_POLICY_AUTHORITY_NOT_YET_ESTABLISHED
  PRODUCTION_IMPLEMENTATION_AUTHORITY_NOT_GRANTED

PHASE_2_STATUS=
  CONTINUE_TO_POLICY_CONFIGURATION_AND_ROLLBACK_BOUNDARY_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_GENERATION_POLICY_CONFIGURATION_AND_ROLLBACK_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-control-authorization-and-ownership-boundary\.sh$' ||
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

git add scripts/classify-generation-control-authorization-and-ownership-boundary.sh
git diff --cached --check
git commit -m "Classify generation control authorization boundary"
git push
