#!/usr/bin/env bash
set -euo pipefail

echo "=== CHECK RUNNING PROMPT DIAGNOSTIC ==="

echo "=== TSX / OLLAMA PROCESSES ==="
ps aux | grep -E 'tsx|run-bounded-prompt-presentation-diagnostic|ollama' | grep -v grep || true

echo "=== OLLAMA HEALTH ==="
curl -sS --max-time 5 http://localhost:11434/api/tags >/dev/null \
  && echo "OLLAMA_REACHABLE=YES" \
  || echo "OLLAMA_REACHABLE=NO"

echo "=== CURRENT DIAGNOSTIC LOGS ==="
ls -lt artifacts/prompt-presentation-diagnostic-*.log 2>/dev/null | head -5 || true

latest="$(ls -t artifacts/prompt-presentation-diagnostic-*.log 2>/dev/null | head -1 || true)"
if [[ -n "$latest" ]]; then
  echo "LATEST_LOG=$latest"
  echo "LATEST_LOG_SIZE=$(wc -c < "$latest")"
  tail -20 "$latest" || true
fi

echo "PRODUCTION_CHANGE=NONE"
