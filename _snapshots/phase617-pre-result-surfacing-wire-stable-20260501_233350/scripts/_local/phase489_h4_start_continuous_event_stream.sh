#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
PID_FILE="$ROOT/.phase489_h4_generator.pid"
LOG_FILE="$ROOT/docs/PHASE_489_H4_CONTINUOUS_EVENT_STREAM_RUNTIME.log"
GENERATOR="$ROOT/scripts/_local/phase489_h4_continuous_event_generator.sh"

if [[ ! -x "$GENERATOR" ]]; then
  echo "Missing executable generator: $GENERATOR" >&2
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  existing_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${existing_pid:-}" ]] && kill -0 "$existing_pid" 2>/dev/null; then
    echo "Continuous event generator already running with PID $existing_pid"
    echo "Log: $LOG_FILE"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

mkdir -p "$(dirname "$LOG_FILE")"

nohup "$GENERATOR" >> "$LOG_FILE" 2>&1 &
pid=$!
echo "$pid" > "$PID_FILE"

sleep 1

if kill -0 "$pid" 2>/dev/null; then
  echo "Started continuous event generator with PID $pid"
  echo "PID file: $PID_FILE"
  echo "Log: $LOG_FILE"
else
  echo "Failed to start continuous event generator" >&2
  rm -f "$PID_FILE"
  exit 1
fi
