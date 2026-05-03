#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 69 TELEMETRY REPLAY CAPTURE"
echo "---------------------------------"

OUTPUT_DIR="scripts/_local/fixtures/replay"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTFILE="$OUTPUT_DIR/task_events_replay_$TIMESTAMP.json"

mkdir -p "$OUTPUT_DIR"

echo "Capturing sample telemetry snapshot..."

cat scripts/_local/fixtures/telemetry/task_events_contract_sample.json > "$OUTFILE"

echo "Replay snapshot saved:"
echo "$OUTFILE"

echo
echo "Phase 69 replay capture COMPLETE"
