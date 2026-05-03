#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GUIDANCE="$(bash scripts/_local/operator_guidance.sh status)"

RISK="$(echo "$GUIDANCE" | awk -F= '/^risk=/{print $2}')"
SAFE="$(echo "$GUIDANCE" | awk -F= '/^safe_to_continue=/{print $2}')"

echo "PHASE 72 — OPERATOR NEXT ACTION"
echo "risk=$RISK"
echo "safe_to_continue=$SAFE"

if [[ "$SAFE" == "YES" ]]; then
  echo "ACTION: run smoke verification"
  bash scripts/_local/phase72_run_operator_guidance_smoke.sh
  echo "RESULT: guidance layer verified"
elif [[ "$RISK" == "HIGH" ]]; then
  echo "ACTION: restore golden anchor required"
  echo "git checkout v63.0-telemetry-integration-golden -- public/dashboard.html"
  echo "git checkout v63.0-telemetry-integration-golden -- public/css/dashboard.css"
  echo "git checkout v63.0-telemetry-integration-golden -- public/js/phase61_tabs_workspace.js"
  echo "git checkout v63.0-telemetry-integration-golden -- public/js/phase61_recent_history_wire.js"
else
  echo "ACTION: investigate runtime health"
  docker ps
fi
