#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase144] smoke"
npx tsx scripts/_local/phase144_governance_pre_live_registry_handoff_envelope_smoke.ts

echo "[phase144] report"
npx tsx scripts/_local/phase144_governance_pre_live_registry_handoff_envelope_report.ts >/tmp/phase144_governance_pre_live_registry_handoff_envelope_report.json

echo "[phase144] report saved to /tmp/phase144_governance_pre_live_registry_handoff_envelope_report.json"
echo "[phase144] seal PASS"
