#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 67B event shape inspection =="

TASK_EVENT_REFERENCES="$(grep -R --line-number --exclude-dir=.git 'task-events\|/events/task-events' public/js || true)"
if [ -z "$TASK_EVENT_REFERENCES" ]; then
  echo "No task-events references found in public/js"
  exit 1
fi

echo "-- task-events references found"
echo "$TASK_EVENT_REFERENCES"

FIELD_REFERENCES="$(grep -R --line-number --exclude-dir=.git 'task_id\|run_id\|state\|ts' public/js || true)"
if [ -z "$FIELD_REFERENCES" ]; then
  echo "No task event field references found in public/js"
  exit 1
fi

echo "-- event field references found"
echo "$FIELD_REFERENCES"

QUEUE_REDUCER_FIELDS="$(grep -n 'task_id\|run_id\|state\|ts' public/js/telemetry_queue_depth_reducer.js || true)"
FAILED_REDUCER_FIELDS="$(grep -n 'task_id\|run_id\|state\|ts' public/js/telemetry_failed_tasks_reducer.js || true)"

if [ -z "$QUEUE_REDUCER_FIELDS" ]; then
  echo "Queue depth reducer field assumptions missing"
  exit 1
fi

if [ -z "$FAILED_REDUCER_FIELDS" ]; then
  echo "Failed tasks reducer field assumptions missing"
  exit 1
fi

echo "-- reducer field assumptions present"

bash scripts/_local/phase67_runtime_compat_check.sh

echo "== Phase 67B event shape inspection PASSED =="
