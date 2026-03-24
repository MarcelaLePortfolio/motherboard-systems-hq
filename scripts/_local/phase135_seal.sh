#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase135] smoke"
npx tsx scripts/_local/phase135_governance_cognition_snapshot_smoke.ts

echo "[phase135] report"
npx tsx scripts/_local/phase135_governance_cognition_snapshot_report.ts >/tmp/phase135_governance_cognition_snapshot_report.json

echo "[phase135] report saved to /tmp/phase135_governance_cognition_snapshot_report.json"
echo "[phase135] seal PASS"
