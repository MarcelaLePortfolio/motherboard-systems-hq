#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_guidance_signal_hunt.txt"

{
  echo "PHASE 487 — OPERATOR GUIDANCE SIGNAL HUNT"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] OPERATOR GUIDANCE / SYSTEM_HEALTH IN SOURCE ONLY"
  grep -RniE "Operator Guidance|SYSTEM_HEALTH|operatorGuidance|AWAITINGBOUNDEDGUIDANCE|Live operator guidance will appear here" \
    app components src server dashboard scripts \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    --exclude-dir=docs \
    2>/dev/null || true
  echo

  echo "[2] INTERVAL / TIMEOUT IN SOURCE ONLY"
  grep -RniE "setInterval|setTimeout" \
    app components src server dashboard scripts \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    --exclude-dir=docs \
    2>/dev/null || true
  echo

  echo "[3] EVENTSOURCE / STREAM / SSE IN SOURCE ONLY"
  grep -RniE "EventSource|text/event-stream|events/ops|events/reflections|ReadableStream|SSE|stream" \
    app components src server dashboard scripts \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    --exclude-dir=docs \
    2>/dev/null || true
  echo

  echo "[4] FETCH / API CALLS NEAR GUIDANCE"
  grep -RniE "fetch\\(|/api/|guidance|operatorGuidance" \
    app components src server dashboard scripts \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    --exclude-dir=docs \
    2>/dev/null || true
  echo

  echo "HUNT COMPLETE"
} > "$OUTPUT"

echo "Generated: $OUTPUT"
