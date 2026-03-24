#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase141] smoke"
npx tsx scripts/_local/phase141_governance_live_wiring_decision_smoke.ts

echo "[phase141] report"
npx tsx scripts/_local/phase141_governance_live_wiring_decision_report.ts >/tmp/phase141_governance_live_wiring_decision_report.json

echo "[phase141] report saved to /tmp/phase141_governance_live_wiring_decision_report.json"
echo "[phase141] seal PASS"
