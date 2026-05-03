#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

git add \
  docs/recovery_full_audit/15_recovery_checkpoint_bands.txt \
  docs/recovery_full_audit/18_recovery_visual_compare_launch.txt \
  docs/recovery_full_audit/phase65_layout_launch_port_8081.txt \
  docs/recovery_full_audit/phase65_wiring_launch_port_8082.txt \
  docs/recovery_full_audit/operator_guidance_launch_port_8083.txt \
  scripts/_local/phase457_launch_recovery_visual_compare.sh

git commit -m "Record recovery visual compare launch artifacts"
git push
