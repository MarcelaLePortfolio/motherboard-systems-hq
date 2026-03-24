#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase136] smoke"
npx tsx scripts/_local/phase136_governance_dashboard_consumption_smoke.ts

echo "[phase136] report"
npx tsx scripts/_local/phase136_governance_dashboard_consumption_report.ts >/tmp/phase136_governance_dashboard_consumption_report.json

echo "[phase136] report saved to /tmp/phase136_governance_dashboard_consumption_report.json"
echo "[phase136] seal PASS"
