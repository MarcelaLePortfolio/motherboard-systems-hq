#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase143] smoke runner"
bash scripts/_local/phase143_run_governance_final_pre_live_registry_contract_package_smoke.sh

echo "[phase143] report runner"
bash scripts/_local/phase143_run_governance_final_pre_live_registry_contract_package_report.sh >/tmp/phase143_governance_final_pre_live_registry_contract_package_report.pretty.json

echo "[phase143] seal"
bash scripts/_local/phase143_seal.sh

echo "[phase143] verification PASS"
