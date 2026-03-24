#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase137] smoke runner"
bash scripts/_local/phase137_run_governance_dashboard_contract_registration_smoke.sh

echo "[phase137] report runner"
bash scripts/_local/phase137_run_governance_dashboard_contract_registration_report.sh >/tmp/phase137_governance_dashboard_contract_registration_report.pretty.json

echo "[phase137] seal"
bash scripts/_local/phase137_seal.sh

echo "[phase137] verification PASS"
