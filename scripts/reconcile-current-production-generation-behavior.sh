#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE CURRENT PRODUCTION GENERATION BEHAVIOR ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY INVESTIGATION-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-current-production-generation-behavior\.sh$|^ M scripts/reconcile-current-production-generation-behavior\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY GENERATION STABILITY MILESTONE ==="
grep -nE \
  'SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY|PHASE_1=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION|NEXT_ACTION=BEGIN_PHASE_1_CURRENT_PRODUCTION_GENERATION_BEHAVIOR_RECONCILIATION' \
  docs/architecture/CONVERSATION_ENGINE_GENERATION_STABILITY.md

echo "GENERATION_STABILITY_MILESTONE=CONFIRMED"

echo
echo "=== PRODUCTION OLLAMA GENERATION ENTRY POINTS ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'ollamaChat\(|OLLAMA_BASE_URL|api/generate|/api/generate|generate\(' \
  server scripts app routes \
  2>/dev/null || true

echo
echo "=== CURRENT GENERATION OPTIONS / SAMPLING CONTROLS ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'temperature|top_p|top_k|seed|repeat_penalty|num_predict|options[[:space:]]*:' \
  server scripts app routes \
  2>/dev/null || true

echo
echo "=== STRUCTURED RESPONSE CONTRACT SURFACE ==="
grep -nE \
  'reply|durableInterpretation|summary|explanationStatus|supportSourceReferences|investigationLifecycle|JSON|format|options|seed|temperature|top_p|top_k' \
  scripts/utils/ollamaChat.ts \
  2>/dev/null || true

echo
echo "=== PRODUCTION WORKFLOW INVOCATION SURFACE ==="
grep -nE \
  'ollamaChat|selectedHistory|projectContext|priorInvestigationLifecycle|supportSource|conversationContext' \
  server/matilda-chat-workflow.ts \
  2>/dev/null || true

echo
echo "=== EXISTING GENERATION-STABILITY / REPEATABILITY EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'unseeded|seeded reproducibility|remaining unseeded variance|live repeatability|production reliability|generation stability|semantic-generation stability|production sampling policy' \
  scripts docs \
  2>/dev/null || true

echo
echo "=== RELEVANT VALIDATION SCRIPTS ==="
find scripts -maxdepth 1 -type f | sort | grep -Ei \
  'ollama|response|adaptive|stability|generation|semantic|support-reference' || true

echo
echo "=== CURRENT RECONCILIATION BOUNDARY ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=CURRENT_PRODUCTION_GENERATION_BEHAVIOR_RECONCILIATION

INVESTIGATION_GOALS=
  1. Identify the actual production semantic-generation invocation path.
  2. Identify current production sampling / generation controls, if any.
  3. Distinguish production controls from validation-only seeded diagnostics.
  4. Identify existing evidence about ordinary unseeded variability.
  5. Identify structured-response and semantic-stability failure surfaces.
  6. Determine what must be measured before any production intervention can be justified.

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE
NEXT_ACTION=CLASSIFY_CURRENT_PRODUCTION_GENERATION_BEHAVIOR
MAP

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-current-production-generation-behavior\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reconcile-current-production-generation-behavior.sh
git diff --cached --check
git commit -m "Reconcile current production generation behavior"
git push
