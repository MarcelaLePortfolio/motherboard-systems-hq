#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bash scripts/phase46_bringup.sh
bash scripts/phase46_smoke.sh
bash scripts/phase46_recovery_primitives.sh
bash scripts/phase46_shutdown.sh
