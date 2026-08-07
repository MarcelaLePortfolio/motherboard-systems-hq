#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${MOTHERBOARD_REPO_DIR:-$HOME/Projects/motherboard-systems-hq-clean}"
DR_PIPELINE="$REPO_DIR/scripts/full_dr_pipeline.sh"

if [ ! -f "$DR_PIPELINE" ]; then
  echo "DR ERROR: canonical pipeline not found:"
  echo "$DR_PIPELINE"
  exit 1
fi

echo "RUNNING FULL DR SYSTEM..."
bash "$DR_PIPELINE"
