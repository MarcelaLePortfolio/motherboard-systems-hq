#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

scripts/verify-dashboard-two-panel-structure.sh
scripts/_local/phase61_run_local_verify.sh
scripts/_local/phase61_open_verified_dashboard.sh
