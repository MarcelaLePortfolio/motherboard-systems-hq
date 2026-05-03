#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase139] smoke runner"
bash scripts/_local/phase139_run_governance_shared_registry_owner_bundle_smoke.sh

echo "[phase139] report runner"
bash scripts/_local/phase139_run_governance_shared_registry_owner_bundle_report.sh >/tmp/phase139_governance_shared_registry_owner_bundle_report.pretty.json

echo "[phase139] seal"
bash scripts/_local/phase139_seal.sh

echo "[phase139] verification PASS"
