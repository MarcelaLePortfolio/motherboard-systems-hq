#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase140] smoke runner"
bash scripts/_local/phase140_run_governance_live_registry_wiring_readiness_smoke.sh

echo "[phase140] report runner"
bash scripts/_local/phase140_run_governance_live_registry_wiring_readiness_report.sh >/tmp/phase140_governance_live_registry_wiring_readiness_report.pretty.json

echo "[phase140] seal"
bash scripts/_local/phase140_seal.sh

echo "[phase140] verification PASS"
