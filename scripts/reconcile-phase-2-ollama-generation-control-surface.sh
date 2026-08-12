#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== PHASE 2 / CORRIDOR 2 — OLLAMA GENERATION CONTROLS ==="
echo "MODE=INVESTIGATION_ONLY"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo

echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "HEAD_SUBJECT=$(git log -1 --pretty=%s)"

unexpected_status="$(
  git status --short |
  grep -vE '^\?\? scripts/reconcile-phase-2-ollama-generation-control-surface\.sh$|^ M scripts/reconcile-phase-2-ollama-generation-control-surface\.sh$|^M  scripts/reconcile-phase-2-ollama-generation-control-surface\.sh$|^A  scripts/reconcile-phase-2-ollama-generation-control-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected_status" ]]; then
  echo "STOP: working tree contains changes outside the current investigation artifact."
  printf '%s\n' "$unexpected_status"
  exit 1
fi

echo "WORKTREE_BASELINE=CLEAN_EXCEPT_CURRENT_INVESTIGATION_ARTIFACT"
echo "PROTECTED_BASELINE_DR=20260812_151244"
echo

echo "=== OLLAMACHAT CONTROL CONTRACT ==="
grep -nF 'validationGenerationSeed' scripts/utils/ollamaChat.ts || true
nl -ba scripts/utils/ollamaChat.ts | sed -n '836,855p'
echo

echo "=== EXISTING GENERATION-CONTROL INVESTIGATION EVIDENCE ==="
for f in \
  scripts/reconcile-generation-control-surface-inventory.sh \
  scripts/investigate-scoped-matilda-generation-control-contract.sh \
  scripts/classify-scoped-matilda-generation-control-contract.sh \
  scripts/investigate-adaptive-detail-generation-stability-controls.sh \
  scripts/classify-adaptive-detail-generation-stability-control-seam.sh
do
  if [[ -f "$f" ]]; then
    echo
    echo "--- $f ---"
    grep -nE \
      'CONTROL|SEED|TEMPERATURE|TOP_P|TOP_K|REQUEST|PRODUCTION|VALIDATION|OLLAMA|SUPPORTED|SURFACE|SEMANTIC|AUTHORIZ|IMPLEMENT|DEFAULT|OPTION|POLICY|BOUNDARY|FINDING|RESULT|NEXT' \
      "$f" | head -240 || true
  fi
done
echo

echo "=== ACTIVE ADAPTER-SUPPORTED REPOSITORY CONTROL SURFACE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'validationGenerationSeed|seed[[:space:]]*:|temperature[[:space:]]*:|top_p[[:space:]]*:|top_k[[:space:]]*:|repeat_penalty[[:space:]]*:|num_predict[[:space:]]*:|num_ctx[[:space:]]*:' \
  server routes app src scripts/utils 2>/dev/null || true
echo

echo "=== PRODUCTION CALLERS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'ollamaChat(' server routes 2>/dev/null || true
echo

echo "=== PRODUCTION WORKFLOW CONTEXT ==="
nl -ba server/matilda-chat-workflow.ts | sed -n '210,232p'
echo

echo "=== CORRIDOR 2 BOUNDARY ==="
cat <<'TEXT'
Determine the repository-relevant Ollama generation-control surface.

Distinguish:
- controls represented by the current Conversation Engine adapter;
- controls exercised only by validation or diagnostic callers;
- controls that Ollama may support but the repository has not established a need for;
- semantic and ownership implications of any future candidate production control;
- rollback to the current unconfigured production sampling baseline.

Availability alone does not establish production need.
TEXT
echo

echo "CORRIDOR_2_STATUS=INVESTIGATION_ACTIVE"
echo "CURRENT_REPOSITORY_GENERATION_CONTROL=REQUEST_SCOPED_validationGenerationSeed"
echo "CURRENT_PRODUCTION_EXPLICIT_GENERATION_CONTROL=ABSENT"
echo "PRODUCTION_POLICY_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_REPOSITORY_RELEVANT_OLLAMA_GENERATION_CONTROL_SURFACE"
echo

echo "=== FINAL WORKTREE ==="
git status --short
