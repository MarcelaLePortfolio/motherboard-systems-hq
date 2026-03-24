#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase145] smoke runner"
bash scripts/_local/phase145_run_governance_pre_live_registry_delivery_manifest_smoke.sh

echo "[phase145] report runner"
bash scripts/_local/phase145_run_governance_pre_live_registry_delivery_manifest_report.sh >/tmp/phase145_governance_pre_live_registry_delivery_manifest_report.pretty.json

echo "[phase145] seal"
bash scripts/_local/phase145_seal.sh

echo "[phase145] verification PASS"
