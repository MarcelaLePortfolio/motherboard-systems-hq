#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase142] smoke runner"
bash scripts/_local/phase142_run_governance_authorization_gate_smoke.sh

echo "[phase142] report runner"
bash scripts/_local/phase142_run_governance_authorization_gate_report.sh >/tmp/phase142_governance_authorization_gate_report.pretty.json

echo "[phase142] seal"
bash scripts/_local/phase142_seal.sh

echo "[phase142] verification PASS"
