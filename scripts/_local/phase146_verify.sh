#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase146] smoke runner"
bash scripts/_local/phase146_run_governance_final_delivery_receipt_smoke.sh

echo "[phase146] report runner"
bash scripts/_local/phase146_run_governance_final_delivery_receipt_report.sh >/tmp/phase146_governance_final_delivery_receipt_report.pretty.json

echo "[phase146] seal"
bash scripts/_local/phase146_seal.sh

echo "[phase146] verification PASS"
