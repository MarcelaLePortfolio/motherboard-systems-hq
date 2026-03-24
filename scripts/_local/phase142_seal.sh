#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase142] smoke"
npx tsx scripts/_local/phase142_governance_authorization_gate_smoke.ts

echo "[phase142] report"
npx tsx scripts/_local/phase142_governance_authorization_gate_report.ts >/tmp/phase142_governance_authorization_gate_report.json

echo "[phase142] report saved to /tmp/phase142_governance_authorization_gate_report.json"
echo "[phase142] seal PASS"
