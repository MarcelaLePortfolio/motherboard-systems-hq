#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase147] smoke runner"
bash scripts/_local/phase147_run_governance_final_pre_live_registry_archive_record_smoke.sh

echo "[phase147] report runner"
bash scripts/_local/phase147_run_governance_final_pre_live_registry_archive_record_report.sh >/tmp/phase147_governance_final_pre_live_registry_archive_record_report.pretty.json

echo "[phase147] seal"
bash scripts/_local/phase147_seal.sh

echo "[phase147] verification PASS"
