#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase143] smoke"
npx tsx scripts/_local/phase143_governance_final_pre_live_registry_contract_package_smoke.ts

echo "[phase143] report"
npx tsx scripts/_local/phase143_governance_final_pre_live_registry_contract_package_report.ts >/tmp/phase143_governance_final_pre_live_registry_contract_package_report.json

echo "[phase143] report saved to /tmp/phase143_governance_final_pre_live_registry_contract_package_report.json"
echo "[phase143] seal PASS"
