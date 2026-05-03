#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase146] smoke"
npx tsx scripts/_local/phase146_governance_final_delivery_receipt_smoke.ts

echo "[phase146] report"
npx tsx scripts/_local/phase146_governance_final_delivery_receipt_report.ts >/tmp/phase146_governance_final_delivery_receipt_report.json

echo "[phase146] report saved to /tmp/phase146_governance_final_delivery_receipt_report.json"
echo "[phase146] seal PASS"
