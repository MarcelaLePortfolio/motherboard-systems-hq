#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LOG='/private/tmp/motherboard-server-after-ollamachat-fix.log'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=89fb9faa' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'SERVER_LOG=/private/tmp/motherboard-server-after-ollamachat-fix.log' \
  'TARGET=READ_EXACT_EXCEPTION_ALREADY_EMITTED_BY_LIVE_BACKEND'

printf '\n=== SERVER LOG METADATA ===\n'
ls -lh "$LOG"
stat "$LOG"

printf '\n=== FULL CURRENT SERVER LOG ===\n'
cat "$LOG"

printf '\n=== MATILDA FAILURE LINES WITH CONTEXT ===\n'
grep -n -A30 -B15 -E \
  'Matilda conversation workflow|Conversational response failed|Ollama returned|support reference|selected context|investigation lifecycle|malformed structured|durable interpretation|Error:' \
  "$LOG" || true

printf '\n=== FINAL LOG TAIL ===\n'
tail -120 "$LOG"

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'LIVE_503_CONFIRMED=YES' \
  'LOG_OWNER_MATCHES_PORT_3000_PROCESS=YES' \
  'NEXT_ACTION=CLASSIFY_EXACT_EXCEPTION_FROM_LOG_OUTPUT' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
