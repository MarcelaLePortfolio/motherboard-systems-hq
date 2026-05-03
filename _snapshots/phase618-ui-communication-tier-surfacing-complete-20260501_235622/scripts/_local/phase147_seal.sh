#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase147] smoke"
npx tsx scripts/_local/phase147_governance_final_pre_live_registry_archive_record_smoke.ts

echo "[phase147] report"
npx tsx scripts/_local/phase147_governance_final_pre_live_registry_archive_record_report.ts >/tmp/phase147_governance_final_pre_live_registry_archive_record_report.json

echo "[phase147] report saved to /tmp/phase147_governance_final_pre_live_registry_archive_record_report.json"
echo "[phase147] seal PASS"
