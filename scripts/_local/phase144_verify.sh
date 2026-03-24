#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase144] smoke runner"
bash scripts/_local/phase144_run_governance_pre_live_registry_handoff_envelope_smoke.sh

echo "[phase144] report runner"
bash scripts/_local/phase144_run_governance_pre_live_registry_handoff_envelope_report.sh >/tmp/phase144_governance_pre_live_registry_handoff_envelope_report.pretty.json

echo "[phase144] seal"
bash scripts/_local/phase144_seal.sh

echo "[phase144] verification PASS"
