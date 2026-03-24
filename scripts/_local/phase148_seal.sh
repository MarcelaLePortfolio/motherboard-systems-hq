#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase148] smoke"
npx tsx scripts/_local/phase148_governance_final_pre_live_registry_summary_capsule_smoke.ts

echo "[phase148] report"
npx tsx scripts/_local/phase148_governance_final_pre_live_registry_summary_capsule_report.ts >/tmp/phase148_governance_final_pre_live_registry_summary_capsule_report.json

echo "[phase148] report saved to /tmp/phase148_governance_final_pre_live_registry_summary_capsule_report.json"
echo "[phase148] seal PASS"
