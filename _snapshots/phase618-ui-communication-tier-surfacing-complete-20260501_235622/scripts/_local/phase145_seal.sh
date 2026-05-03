#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase145] smoke"
npx tsx scripts/_local/phase145_governance_pre_live_registry_delivery_manifest_smoke.ts

echo "[phase145] report"
npx tsx scripts/_local/phase145_governance_pre_live_registry_delivery_manifest_report.ts >/tmp/phase145_governance_pre_live_registry_delivery_manifest_report.json

echo "[phase145] report saved to /tmp/phase145_governance_pre_live_registry_delivery_manifest_report.json"
echo "[phase145] seal PASS"
