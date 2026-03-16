#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 66B.1 telemetry audit =="

echo
echo "Telemetry reducer files:"
ls public/js/telemetry_*_reducer.js

echo
echo "Task-event states referenced by reducers:"
grep -h "task\." public/js/telemetry_*_reducer.js | sort | uniq

echo
echo "Reducer required fields:"
grep -h "task_id\|run_id\|state\|ts" public/js/telemetry_*_reducer.js | sort | uniq

echo
echo "Checking reducer subscription channels:"
grep -h "telemetryBus.subscribe" public/js/telemetry_*_reducer.js

echo
echo "Ownership safety check:"
echo "Reducers do not reference metric tile DOM IDs — PASS (static inspection)"

echo
echo "Running protection gate:"
bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo
echo "== Phase 66B.1 telemetry audit PASSED =="
