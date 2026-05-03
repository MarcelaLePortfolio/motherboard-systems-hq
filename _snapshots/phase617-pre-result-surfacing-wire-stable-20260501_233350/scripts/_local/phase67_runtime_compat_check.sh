#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 67 runtime compatibility check =="

QUEUE_REDUCER="public/js/telemetry_queue_depth_reducer.js"
FAILED_REDUCER="public/js/telemetry_failed_tasks_reducer.js"

test -f "$QUEUE_REDUCER"
test -f "$FAILED_REDUCER"

echo "-- reducer presence: OK"

if ! grep -q 'telemetryBus.*subscribe\|window\.telemetryBus.*subscribe' "$QUEUE_REDUCER"; then
  echo "Queue depth reducer does not subscribe through telemetry bus"
  exit 1
fi

if ! grep -q 'telemetryBus.*subscribe\|window\.telemetryBus.*subscribe' "$FAILED_REDUCER"; then
  echo "Failed tasks reducer does not subscribe through telemetry bus"
  exit 1
fi

echo "-- reducer subscription pattern: OK"

BUS_PROVIDER="$(grep -R --line-number --exclude-dir=.git 'telemetryBus' public/js || true)"
if [ -z "$BUS_PROVIDER" ]; then
  echo "No telemetryBus references found in public/js"
  exit 1
fi

echo "-- telemetry bus references found"

TASK_STREAM_REFERENCES="$(grep -R --line-number --exclude-dir=.git '/events/task-events\|task-events' public/js || true)"
if [ -z "$TASK_STREAM_REFERENCES" ]; then
  echo "No task-events stream references found in public/js"
  exit 1
fi

echo "-- task-events stream references found"

for reducer in "$QUEUE_REDUCER" "$FAILED_REDUCER"; do
  if ! grep -q 'task_id' "$reducer"; then
    echo "Reducer missing task_id handling: $reducer"
    exit 1
  fi

  if ! grep -q 'state' "$reducer"; then
    echo "Reducer missing state handling: $reducer"
    exit 1
  fi
done

echo "-- reducer event shape assumptions present"

bash scripts/_local/phase66_metric_collision_check.sh

echo "== Phase 67 runtime compatibility check PASSED =="
