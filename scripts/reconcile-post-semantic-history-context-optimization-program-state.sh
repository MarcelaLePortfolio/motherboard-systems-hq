#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE POST SEMANTIC HISTORY CONTEXT OPTIMIZATION PROGRAM STATE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="3ac130ce"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches semantic-history closure checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-post-semantic-history-context-optimization-program-state\.sh$|^ M scripts/reconcile-post-semantic-history-context-optimization-program-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SEMANTIC_HISTORY_CLOSURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CLOSED MILESTONES ==="

grep -q 'MILESTONE_STATUS=' scripts/classify-semantic-history-context-optimization-milestone-closure.sh
grep -q 'CLOSED' scripts/classify-semantic-history-context-optimization-milestone-closure.sh

grep -q 'MILESTONE_CLOSURE_CLASSIFICATION=' scripts/classify-semantic-history-context-optimization-milestone-closure.sh
grep -q 'COMPLETE_WITH_NO_NEW_OPTIMIZATION_REQUIREMENT_ESTABLISHED' scripts/classify-semantic-history-context-optimization-milestone-closure.sh

echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=CLOSED"

echo
echo "=== POST-MILESTONE PROGRAM STATE ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

GENERATION_STABILITY=
  CLOSED

SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=
  CLOSED

SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_RESULT=
  COMPLETE_WITH_NO_NEW_OPTIMIZATION_REQUIREMENT_ESTABLISHED

PRODUCTION_GENERATION_INSTABILITY=
  DEFERRED_KNOWN_CONDITION

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

SEMANTIC_RANKING_REQUIREMENT=
  NOT_ESTABLISHED

TOKEN_BUDGET_REQUIREMENT=
  NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

HYBRID_CONTEXT_REQUIREMENT=
  NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

INTEGRATED_OPTIMIZATION_REQUIREMENT=
  NOT_ESTABLISHED

SELECTED_HISTORY_CONTRACT=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

DETERMINISTIC_REGRESSION_VALIDATION=
  PASS

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

NEW_RUNTIME_BEHAVIOR=
  NONE

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

SUCCESSOR_MILESTONE=
  NOT_YET_CLASSIFIED

SUCCESSOR_PHASE=
  NOT_YET_CLASSIFIED

SUCCESSOR_CORRIDOR=
  NOT_YET_CLASSIFIED

NEXT_ACTION=
  CLASSIFY_POST_SEMANTIC_HISTORY_SUCCESSOR_MILESTONE
MAP

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-post-semantic-history-context-optimization-program-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside post-milestone reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
