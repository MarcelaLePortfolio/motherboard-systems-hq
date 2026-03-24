#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase138] smoke"
npx tsx scripts/_local/phase138_governance_runtime_registry_export_smoke.ts

echo "[phase138] report"
npx tsx scripts/_local/phase138_governance_runtime_registry_export_report.ts >/tmp/phase138_governance_runtime_registry_export_report.json

echo "[phase138] report saved to /tmp/phase138_governance_runtime_registry_export_report.json"
echo "[phase138] seal PASS"
