#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase138] smoke runner"
bash scripts/_local/phase138_run_governance_runtime_registry_export_smoke.sh

echo "[phase138] report runner"
bash scripts/_local/phase138_run_governance_runtime_registry_export_report.sh >/tmp/phase138_governance_runtime_registry_export_report.pretty.json

echo "[phase138] seal"
bash scripts/_local/phase138_seal.sh

echo "[phase138] verification PASS"
