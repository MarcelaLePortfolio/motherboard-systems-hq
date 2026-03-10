#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

scripts/_local/phase61_clean_rewrite_workspace_region.sh
scripts/verify-dashboard-two-panel-structure.sh
git diff -- public/dashboard.html
