#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 66 metric collision check =="

QUEUE_REDUCER="public/js/telemetry_queue_depth_reducer.js"
FAILED_REDUCER="public/js/telemetry_failed_tasks_reducer.js"

test -f "$QUEUE_REDUCER"
test -f "$FAILED_REDUCER"

echo "-- reducer presence: OK"

QUEUE_SYMBOL_COLLISIONS="$(grep -R --line-number --exclude-dir=.git --exclude='telemetry_queue_depth_reducer.js' 'queueDepthTelemetry\|getQueueDepth' public/js || true)"
FAILED_SYMBOL_COLLISIONS="$(grep -R --line-number --exclude-dir=.git --exclude='telemetry_failed_tasks_reducer.js' 'failedTasksTelemetry\|getFailedTaskCount' public/js || true)"

if [ -n "$QUEUE_SYMBOL_COLLISIONS" ]; then
  echo "Queue depth ownership collision detected:"
  echo "$QUEUE_SYMBOL_COLLISIONS"
  exit 1
fi

if [ -n "$FAILED_SYMBOL_COLLISIONS" ]; then
  echo "Failed tasks ownership collision detected:"
  echo "$FAILED_SYMBOL_COLLISIONS"
  exit 1
fi

echo "-- ownership collision check: OK"

if grep -qE 'document\.|innerHTML|appendChild|insertAdjacent|querySelector\(' "$QUEUE_REDUCER"; then
  echo "Queue depth reducer contains forbidden DOM mutation or DOM access"
  exit 1
fi

if grep -qE 'document\.|innerHTML|appendChild|insertAdjacent|querySelector\(' "$FAILED_REDUCER"; then
  echo "Failed tasks reducer contains forbidden DOM mutation or DOM access"
  exit 1
fi

echo "-- reducer DOM isolation check: OK"

bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo "== Phase 66 metric collision check PASSED =="
