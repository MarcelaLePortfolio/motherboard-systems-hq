#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

scripts=(
  "scripts/_local/phase128_consumption_registry_enforcement_smoke.sh"
  "scripts/_local/phase128_consumption_registry_validation_smoke.sh"
  "scripts/_local/phase128_consumption_registry_report_smoke.sh"
  "scripts/_local/phase128_consumption_registry_fixture_smoke.sh"
  "scripts/_local/phase128_consumption_registry_proof_smoke.sh"
  "scripts/_local/phase128_consumption_registry_snapshot_smoke.sh"
  "scripts/_local/phase128_consumption_registry_bundle_smoke.sh"
  "scripts/_local/phase128_consumption_registry_runtime_guard_smoke.sh"
  "scripts/_local/phase128_consumption_registry_readonly_view_smoke.sh"
  "scripts/_local/phase128_consumption_registry_entrypoint_smoke.sh"
)

for script in "${scripts[@]}"; do
  [[ -x "$script" ]] || { echo "Missing executable smoke script: $script"; exit 1; }
  "$script"
done

echo "phase128 smoke suite: PASS"
