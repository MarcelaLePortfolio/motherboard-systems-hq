#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 69 VERIFY ALL"
echo "-------------------"

echo
echo "[1/2] Capture replay snapshot"
bash scripts/_local/phase69_replay_capture.sh

echo
echo "[2/2] Run replay validation"
bash scripts/_local/phase69_replay_runner.sh

echo
echo "PHASE 69 VERIFICATION COMPLETE"
