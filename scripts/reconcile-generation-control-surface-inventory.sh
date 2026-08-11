#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE GENERATION CONTROL SURFACE INVENTORY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CORRIDOR-3 CHECKPOINT ==="
expected_head="d93682fe"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Corridor 3 classification checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-generation-control-surface-inventory\.sh$|^ M scripts/reconcile-generation-control-surface-inventory\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CORRIDOR_3_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CORRIDOR-3 RESULT ==="
grep -nE \
  'FAILURE_SURFACE_CLASSIFICATION=|MODEL_RELIABILITY_AT_DUAL_PROJECT_CONTEXT_IDENTITY_BOUNDARY|FAILURE_MECHANISM=|CHILD_SEGMENT_IDENTITY_MISAUTHORED_AS_PARENT_SUPPORT_IDENTITY|GENERATION_POLICY_CLASSIFICATION=|STILL_UNDETERMINED|CORRIDOR_3_RESULT=|STRUCTURED_RESPONSE_RELIABILITY_FAILURE_SURFACE_CLASSIFIED|NEXT_CORRIDOR=GENERATION_CONTROL_SURFACE_INVENTORY' \
  scripts/classify-structured-response-reliability-failure-surface.sh

echo "CORRIDOR_3_RESULT=CONFIRMED"

echo
echo "=== ACTIVE OLLAMA REQUEST SURFACE ==="
sed -n '820,865p' scripts/utils/ollamaChat.ts

echo
echo "=== EXPLICIT GENERATION OPTION SIGNALS ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'validationGenerationSeed|options:[[:space:]]*\{|seed:|temperature|top_p|top_k|num_predict|repeat_penalty|repeat_last_n|mirostat|stop:' \
  scripts \
  server \
  2>/dev/null |
  head -260 || true

echo
echo "=== PRODUCTION WORKFLOW CALL SITE ==="
grep -n -A28 -B12 \
  'await ollamaChat(message' \
  server/matilda-chat-workflow.ts

echo
echo "=== SEEDED DIAGNOSTIC SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -Ei 'seed|reproducib' || true

echo
echo "=== SEEDED DIAGNOSTIC REFERENCES ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'validationGenerationSeed|seeded reproduc|seeded.*diagnostic|production seed|temperature|top_p|top_k' \
  scripts \
  docs \
  2>/dev/null |
  head -280 || true

echo
echo "=== RETRY / MULTI-INVOKE SIGNALS AROUND OLLAMA CHAT ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'ollamaChat\(|retry|retries|second invocation|additional invocation|multiple invocation' \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts \
  scripts/*generation* \
  2>/dev/null |
  head -260 || true

echo
echo "=== MODEL AND ENDPOINT CONFIGURATION ==="
grep -nE \
  'OLLAMA_BASE_URL|OLLAMA_CHAT_MODEL|/api/generate|model:|stream:|format:' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CORRIDOR-4 RECONCILIATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=GENERATION_CONTROL_SURFACE_INVENTORY

ESTABLISHED_INPUT=
  Corridor 3 classified the observed failure as model reliability at the dual
  project-context identity boundary.

  The deterministic provenance validator remains correct and required.

CURRENT_PRODUCTION_REQUEST=
  One ollamaChat invocation reaches one Ollama /api/generate request.

  The production workflow does not currently supply validationGenerationSeed.

  No production temperature, top_p, or top_k policy has yet been established
  by the investigated Conversation Engine call path.

EXISTING_REQUEST_SCOPED_CONTROL=
  validationGenerationSeed

  ollamaChat already exposes this optional request-scoped diagnostic seam and
  maps it to Ollama options.seed when supplied.

CURRENT_USE_OF_SEED=
  VALIDATION_ONLY

  Repository evidence explicitly separates seeded diagnostic reproducibility
  from ordinary unseeded production behavior.

KNOWN_SAMPLING_CONTROL_CANDIDATES=
  seed
  temperature
  top_p
  top_k

CLASSIFICATION_OF_CANDIDATES=
  AVAILABLE_OR_POTENTIALLY_AVAILABLE_GENERATION_CONTROLS

  Their existence does not establish that any one is appropriate for
  production.

RETRY_CLASSIFICATION=
  NOT_AN_ESTABLISHED_PRODUCTION_GENERATION_POLICY

MULTI_INVOCATION_CLASSIFICATION=
  NOT_AN_ESTABLISHED_PRODUCTION_GENERATION_POLICY

MODEL_SELECTION_CLASSIFICATION=
  EXISTING_CONFIGURATION_SURFACE

  Changing the model would be a materially broader intervention than merely
  characterizing generation controls and is not authorized by this corridor.

PROMPT_OR_IDENTITY_REPRESENTATION=
  SEPARATE_INTERVENTION_CLASS

  Corridor 3 also preserves identity representation as a possible intervention
  class because historical evidence identified a presentation-level collision.

  That class must not be silently collapsed into sampling-control policy.

CONTROL_OWNERSHIP_BOUNDARY=
  CONVERSATION_ENGINE_GENERATION_REQUEST

  Any production sampling control would alter shared Conversation Engine
  generation behavior and therefore belongs at the generation-policy boundary,
  not inside the Adaptive Detail fixture or deterministic provenance validator.

CORRIDOR_4_RESULT=
  GENERATION_CONTROL_SURFACE_RECONCILED

WHAT_IS_NOT_YET_KNOWN=
  - whether production generation control is required;
  - whether sampling control can materially improve this failure surface;
  - which control would be smallest and safest;
  - whether identity-presentation intervention is preferable;
  - what acceptance threshold would justify intervention;
  - whether any candidate preserves semantic quality across other structured
    response responsibilities.

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_CORRIDOR=INTERVENTION_DECISION_BOUNDARY
NEXT_ACTION=CLASSIFY_WHETHER_CHARACTERIZATION_EVIDENCE_JUSTIFIES_BOUNDED_INTERVENTION_EXPERIMENT
MAP

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-generation-control-surface-inventory\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reconcile-generation-control-surface-inventory.sh
git diff --cached --check
git commit -m "Reconcile generation control surface inventory"
git push
