#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY MODEL RUNTIME CONTEXT BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="66ec6455"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches hybrid-context requirement checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-model-runtime-context-boundary\.sh$|^ M scripts/classify-model-runtime-context-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "HYBRID_CONTEXT_REQUIREMENT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE STATE ==="

grep -nE \
  'PHASE=|HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION|HYBRID_CONTEXT_REQUIREMENT=|NOT_ESTABLISHED|HYBRID_CONTEXT_REQUIREMENT_CORRIDOR=|COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED|NEXT_CORRIDOR=|MODEL_RUNTIME_CONTEXT_BOUNDARY|NEXT_ACTION=|CLASSIFY_MODEL_RUNTIME_CONTEXT_BOUNDARY' \
  scripts/classify-hybrid-context-requirement.sh

echo "GOVERNING_PHASE_STATE=CONFIRMED"

echo
echo "=== INSPECT CURRENT MODEL RUNTIME INVOCATION BOUNDARY ==="

grep -RniE \
  'gemma3:4b|model:|/api/generate|fetch\(|OLLAMA|ollama|temperature|top_p|topP|top_k|topK|seed|num_ctx|numCtx|context window|context length|options:' \
  server \
  scripts/utils \
  --include='*.ts' \
  2>/dev/null | head -360 || true

echo
echo "=== INSPECT CURRENT SEMANTIC CONTEXT TRANSPORT ==="

grep -RniE \
  'OllamaChatContext|selectedHistory|projectContextExcerpts|projectContextSegmentCandidates|projectContextWarning|priorInvestigationLifecycle|explicitEvidenceRequest|validationGenerationSeed' \
  server \
  scripts/utils \
  --include='*.ts' \
  2>/dev/null | head -360 || true

echo
echo "=== SEARCH MODEL-RUNTIME CONTEXT REQUIREMENTS AND FAILURES ==="

grep -RniE \
  'model runtime context|model-runtime context|runtime context|num_ctx|context length|context window|context overflow|context limit|prompt too long|token limit|truncat|model context|ollama context|context capacity|context exhaustion' \
  docs \
  server \
  scripts \
  --exclude='classify-model-runtime-context-boundary.sh' \
  2>/dev/null | head -360 || true

echo
echo "=== MODEL RUNTIME CONTEXT BOUNDARY CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION

CORRIDOR=
  MODEL_RUNTIME_CONTEXT_BOUNDARY

CURRENT_MODEL=
  gemma3:4b

CURRENT_MODEL_INVOCATION=
  SINGLE_OLLAMA_GENERATION_INVOCATION

CURRENT_SEMANTIC_CONTEXT_OWNER=
  REPOSITORY_COMPOSED_OLLAMA_CHAT_CONTEXT_AND_PROMPT

CURRENT_MODEL_RUNTIME_CONTEXT_CONFIGURATION=
  OLLAMA_AND_MODEL_RUNTIME_DEFAULTS_UNLESS_EXPLICIT_REPOSITORY_EVIDENCE_SHOWS_OTHERWISE

EXPLICIT_REPOSITORY_CONTROLLED_MODEL_CONTEXT_LIMIT=
  NOT_ESTABLISHED

EXPLICIT_REPOSITORY_CONTROLLED_NUM_CTX=
  NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CAPACITY_REQUIREMENT=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_OF_CONTEXT_OVERFLOW_OR_MODEL_CONTEXT_EXHAUSTION=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_MODEL_RUNTIME_CONTEXT_CONFIGURATION_CAUSES_A_CURRENT_SEMANTIC_HISTORY_FAILURE=
  NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

BOUNDARY_CLASSIFICATION=
  PRESERVE_MODEL_RUNTIME_CONTEXT_CONFIGURATION_UNLESS_CONCRETE_REPOSITORY_SUPPORTED_FAILURE_ESTABLISHES_A_CHANGE_REQUIREMENT

RATIONALE=
  The repository owns preparation and transport of semantic generation context
  through the OllamaChatContext and prompt-composition boundary.

  Model-runtime context capacity is a separate concern from conversation-history
  admission, project-context retrieval, Investigation Lifecycle transport, and
  repository-controlled history-window policy.

  Repository evidence does not currently establish an explicit repository-owned
  model context-capacity policy.

  Repository evidence also does not establish a concrete context-overflow,
  truncation, or model-runtime context-exhaustion failure requiring a change.

  Absence of an explicit model-runtime context policy does not itself establish
  that one must be introduced.

  Therefore model-runtime context configuration must remain unchanged unless a
  concrete behavioral or architectural requirement is established.

FALSIFICATION_CONDITION=
  Reopen this boundary if repository-supported evidence demonstrates context
  overflow, truncation, capacity exhaustion, or semantic loss attributable to
  the model-runtime context configuration rather than to upstream selection,
  retrieval, admission, or prompt-composition behavior.

MODEL_RUNTIME_CONTEXT_IMPLEMENTATION=
  NOT_AUTHORIZED

MODEL_CONTEXT_SIZE_CHANGE=
  NOT_AUTHORIZED

NUM_CTX_CHANGE=
  NOT_AUTHORIZED

MODEL_CHANGE=
  NOT_AUTHORIZED

HISTORY_WINDOW_CHANGE=
  NOT_AUTHORIZED

TOKEN_BUDGET_IMPLEMENTATION=
  NOT_AUTHORIZED

HYBRID_CONTEXT_IMPLEMENTATION=
  NOT_AUTHORIZED

SELECTED_HISTORY=
  PRESERVE

PROJECT_CONTEXT_RETRIEVAL=
  PRESERVE

PRIOR_INVESTIGATION_LIFECYCLE=
  PRESERVE

ONE_OLLAMA_INVOCATION=
  PRESERVE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

MODEL_RUNTIME_CONTEXT_BOUNDARY_CORRIDOR=
  COMPLETE_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

NEXT_ACTION=
  CLASSIFY_PHASE_3_HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-model-runtime-context-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside model-runtime-context classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
