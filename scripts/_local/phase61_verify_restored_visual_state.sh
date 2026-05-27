#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

scripts/_local/phase61_run_local_verify.sh
scripts/_local/phase61_open_verified_dashboard.sh
git --no-pager log --oneline -5
