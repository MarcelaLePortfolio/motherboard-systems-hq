#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 77 — OPERATOR DAILY LOOP"
echo "------------------------------"

echo "LOOP STEP 1 — START COMMAND"
bash scripts/_local/phase76_operator_start_command.sh

echo ""
echo "LOOP STEP 2 — RISK SUMMARY"
bash scripts/_local/phase73_run_safety_gate.sh || true

echo ""
echo "LOOP STEP 3 — CURRENT TASK SIGNALS"
bash scripts/_local/operator_guidance.sh status || true

echo ""
echo "LOOP STEP 4 — RECENT EVENTS SNAPSHOT"
if [ -f scripts/_local/phase69_replay_corpus_smoke.sh ]; then
  bash scripts/_local/phase69_replay_corpus_smoke.sh || true
fi

echo ""
echo "LOOP STEP 5 — SAFE NEXT MOVE"
bash scripts/_local/operator_guidance_next_action.sh || true

echo ""
echo "DAILY LOOP RESULT: OPERATOR IN CONTROL"
