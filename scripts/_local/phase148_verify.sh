#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[phase148] smoke runner"
bash scripts/_local/phase148_run_governance_final_pre_live_registry_summary_capsule_smoke.sh

echo "[phase148] report runner"
bash scripts/_local/phase148_run_governance_final_pre_live_registry_summary_capsule_report.sh >/tmp/phase148_governance_final_pre_live_registry_summary_capsule_report.pretty.json

echo "[phase148] seal"
bash scripts/_local/phase148_seal.sh

echo "[phase148] verification PASS"
echo "[handoff] Good handoff point after phase148 verify + commit + push."
echo "[wiring] Live wiring does not occur in phase149 below. Wiring begins only in a separate explicitly authorized live runtime registry owner mutation phase after this preparation corridor."
