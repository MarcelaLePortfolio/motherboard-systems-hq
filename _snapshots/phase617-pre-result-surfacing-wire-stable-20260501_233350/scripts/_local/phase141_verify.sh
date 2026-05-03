#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase141] smoke runner"
bash scripts/_local/phase141_run_governance_live_wiring_decision_smoke.sh

echo "[phase141] report runner"
bash scripts/_local/phase141_run_governance_live_wiring_decision_report.sh >/tmp/phase141_governance_live_wiring_decision_report.pretty.json

echo "[phase141] seal"
bash scripts/_local/phase141_seal.sh

echo "[phase141] verification PASS"
