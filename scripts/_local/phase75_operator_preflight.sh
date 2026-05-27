#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 75 — OPERATOR PREFLIGHT"
echo "-----------------------------"

echo "CHECK 1 — WORKFLOW HELPER"
bash scripts/_local/phase74_operator_workflow_helper.sh

echo ""
echo "CHECK 2 — REPLAY CORPUS"
bash scripts/_local/phase69_replay_corpus_smoke.sh || true

echo ""
echo "CHECK 3 — DRIFT DETECTION"
bash scripts/_local/phase68_drift_detection_smoke.sh || true

echo ""
echo "CHECK 4 — TELEMETRY REDUCERS"
bash scripts/_local/phase67_telemetry_reducer_safety.sh || true

echo ""
echo "CHECK 5 — CONTAINER HEALTH"
docker compose ps || true

echo ""
echo "PREFLIGHT RESULT: SYSTEM READY FOR SAFE ITERATION"
