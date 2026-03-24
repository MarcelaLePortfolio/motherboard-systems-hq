#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase135] smoke runner"
bash scripts/_local/phase135_run_governance_cognition_snapshot_smoke.sh

echo "[phase135] report runner"
bash scripts/_local/phase135_run_governance_cognition_snapshot_report.sh >/tmp/phase135_governance_cognition_snapshot_report.pretty.json

echo "[phase135] seal"
bash scripts/_local/phase135_seal.sh

echo "[phase135] verification PASS"
