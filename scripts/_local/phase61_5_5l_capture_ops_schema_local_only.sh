#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT="docs/checkpoints/PHASE61_5_5I_OPS_EVENT_SCHEMA_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

{
  echo "== /events/ops bounded capture =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
} > "$OUT"

echo "$OUT"
