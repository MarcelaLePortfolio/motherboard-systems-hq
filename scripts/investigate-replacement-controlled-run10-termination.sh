#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_REPLACEMENT_CONTROLLED_COMPARISON_RESULT.txt"
RUNNER="scripts/run-replacement-controlled-comparison.sh"
SOURCE="scripts/run-dashboard-generation-control-comparison.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=e1e15c0b' \
  'ISSUE_RESOLVED=NO' \
  'ACTION=INVESTIGATE_RUN10_TERMINATION_WITH_COMMITTED_EVIDENCE_ONLY' \
  'NEW_OLLAMA_INVOCATION=NO'

printf '\n=== RESULT TAIL ===\n'
tail -80 "$RESULT" || true

printf '\n=== RUN10 LOCATION ===\n'
grep -n '^=== CONTROLLED RUN 10/10 ===$' "$RESULT" || true

printf '\n=== RUNNER EXECUTION BOUNDARY ===\n'
grep -nE \
  'npx tsx|tee|PIPESTATUS|RUN_STATUS|CONTROLLED_COUNT|COMPARISON SUMMARY|ACCEPTANCE BOUNDARY|exit 1' \
  "$RUNNER" || true

printf '\n=== SOURCE CONTROLLED LOOP ===\n'
sed -n '450,525p' "$SOURCE"

printf '\n=== TIMEOUT / ERROR HANDLING ===\n'
grep -nE \
  'OLLAMA_CHAT_TIMEOUT_MS|timed out|AbortController|setTimeout|catch|failureClass|OLLAMA_TIMEOUT' \
  scripts/utils/ollamaChat.ts "$SOURCE" || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'THIRD_ATTEMPT_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_RUN10_TERMINATION_CAUSE_FROM_THIS_EVIDENCE'

printf '\n=== WORKTREE ===\n'
git status --short
