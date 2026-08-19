#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=36e14845' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'OBSERVED=LS_CANNOT_RESOLVE_PREVIOUS_STDOUT_STDERR_PATH' \
  'TARGET=RESOLVE_CURRENT_LIVE_LOG_FILE_FROM_PROCESS_FILE_DESCRIPTORS'

PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1)"

if [[ -z "${PID:-}" ]]; then
  echo 'BACKEND_PID=NOT_FOUND'
  exit 1
fi

echo "BACKEND_PID=$PID"

printf '\n=== CURRENT PROCESS FILE DESCRIPTORS ===\n'
lsof -p "$PID" 2>/dev/null | grep -E '(^COMMAND| 1w | 2w |\.log|/private/tmp|/tmp)' || true

printf '\n=== FD 1 / FD 2 TARGETS ===\n'
for fd in 1 2; do
  echo "--- FD $fd ---"
  lsof -a -p "$PID" -d "$fd" -Fn 2>/dev/null || true
done

printf '\n=== CANDIDATE LIVE LOG FILES ===\n'
find /private/tmp /tmp \
  -maxdepth 2 \
  -type f \
  \( -name '*motherboard*' -o -name '*server*' -o -name '*.log' \) \
  -mmin -1440 \
  -print 2>/dev/null | sort

printf '\n=== READ ANY CURRENT FD-BACKED LOG CANDIDATE ===\n'
mapfile -t LOGS < <(
  lsof -p "$PID" 2>/dev/null |
  awk '$4 ~ /^1w|^2w/ {print $NF}' |
  grep -E '^/.*(log|server|motherboard)' |
  sort -u
)

if [[ "${#LOGS[@]}" -eq 0 ]]; then
  echo 'CURRENT_LOG_PATH=NOT_RESOLVED'
else
  for LOG in "${LOGS[@]}"; do
    echo "CURRENT_LOG_PATH=$LOG"
    if [[ -e "$LOG" ]]; then
      printf '\n--- LOG TAIL: %s ---\n' "$LOG"
      tail -160 "$LOG" || true

      printf '\n--- MATILDA ERROR CONTEXT: %s ---\n' "$LOG"
      grep -n -A30 -B20 -E \
        'Matilda conversation workflow|Conversational response failed|Ollama returned|support reference|selected context|investigation lifecycle|malformed structured|durable interpretation|Error:' \
        "$LOG" || true
    else
      echo 'PATH_VISIBLE_TO_LSOF_BUT_MISSING_FROM_FILESYSTEM=YES'
    fi
  done
fi

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'LIVE_503_CONFIRMED=YES' \
  'PREVIOUS_LOG_PATH_STALE_OR_UNLINKED=YES' \
  'NEXT_ACTION=CLASSIFY_FROM_CURRENT_FD_TARGET_OR_RESTARTLESS_CAPTURE_METHOD' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
