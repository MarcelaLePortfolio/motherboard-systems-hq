#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase140] smoke"
npx tsx scripts/_local/phase140_governance_live_registry_wiring_readiness_smoke.ts

echo "[phase140] report"
npx tsx scripts/_local/phase140_governance_live_registry_wiring_readiness_report.ts >/tmp/phase140_governance_live_registry_wiring_readiness_report.json

echo "[phase140] report saved to /tmp/phase140_governance_live_registry_wiring_readiness_report.json"
echo "[phase140] seal PASS"
