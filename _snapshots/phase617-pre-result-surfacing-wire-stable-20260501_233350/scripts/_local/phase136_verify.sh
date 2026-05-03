#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase136] smoke runner"
bash scripts/_local/phase136_run_governance_dashboard_consumption_smoke.sh

echo "[phase136] report runner"
bash scripts/_local/phase136_run_governance_dashboard_consumption_report.sh >/tmp/phase136_governance_dashboard_consumption_report.pretty.json

echo "[phase136] seal"
bash scripts/_local/phase136_seal.sh

echo "[phase136] verification PASS"
