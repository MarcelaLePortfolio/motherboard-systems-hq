#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase137] smoke"
npx tsx scripts/_local/phase137_governance_dashboard_contract_registration_smoke.ts

echo "[phase137] report"
npx tsx scripts/_local/phase137_governance_dashboard_contract_registration_report.ts >/tmp/phase137_governance_dashboard_contract_registration_report.json

echo "[phase137] report saved to /tmp/phase137_governance_dashboard_contract_registration_report.json"
echo "[phase137] seal PASS"
