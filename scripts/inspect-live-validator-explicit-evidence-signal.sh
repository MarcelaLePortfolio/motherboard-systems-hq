#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== LIVE VALIDATOR SIGNAL INSPECTION ==="

echo
echo "=== VALIDATOR SOURCE ==="
cat scripts/validate-support-driven-source-excerpt-live.ts

echo
echo "=== OLLAMA CONTEXT TYPE ==="
rg -n -C 6 'explicitEvidenceRequest|interface OllamaChatContext' \
  scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW WIRING ==="
rg -n -C 8 'isExplicitEvidenceRequest|explicitEvidenceRequest|ollamaChat' \
  server/matilda-chat-workflow.ts

echo
echo "=== CLASSIFIER ==="
cat server/matilda-evidence-request-signal.ts

echo
echo "=== DETERMINATION ==="
cat <<'QUESTION'
Determine from repository evidence only:

1. Does scripts/validate-support-driven-source-excerpt-live.ts call ollamaChat
   directly without setting explicitEvidenceRequest?

2. If yes, does that mean the repeated live test is still exercising the old
   supportSourceReferences-triggered path rather than the new deterministic
   explicit-evidence admission path?

3. Does the live validation prompt itself satisfy isExplicitEvidenceRequest?

4. Is the smallest correct next unit to update only the live validator so it
   computes and passes the real classifier result, preserving production
   semantics instead of hard-coding true?

Return exactly one classification:

LIVE_VALIDATOR_SIGNAL_GAP_CONFIRMED
LIVE_VALIDATOR_ALREADY_EXERCISES_SIGNAL
LIVE_VALIDATOR_SIGNAL_GAP_NOT_READY

Do not modify production implementation.
Do not close Evidence Composition.
Do not rerun the same live harness until this seam is reconciled.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
