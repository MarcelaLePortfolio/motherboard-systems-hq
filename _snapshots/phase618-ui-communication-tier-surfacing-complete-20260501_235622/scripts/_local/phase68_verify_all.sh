#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 68 VERIFY ALL"
echo "-------------------"

echo
echo "[1/2] Contract check"
bash scripts/_local/phase68_telemetry_contract_check.sh

echo
echo "[2/2] Validator smoke"
bash scripts/_local/phase68_validator_smoke.sh

echo
echo "PHASE 68 VERIFICATION COMPLETE"
