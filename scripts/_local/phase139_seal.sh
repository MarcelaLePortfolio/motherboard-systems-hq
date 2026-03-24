#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase139] smoke"
npx tsx scripts/_local/phase139_governance_shared_registry_owner_bundle_smoke.ts

echo "[phase139] report"
npx tsx scripts/_local/phase139_governance_shared_registry_owner_bundle_report.ts >/tmp/phase139_governance_shared_registry_owner_bundle_report.json

echo "[phase139] report saved to /tmp/phase139_governance_shared_registry_owner_bundle_report.json"
echo "[phase139] seal PASS"
