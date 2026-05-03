#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

rm -f \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_phase61-layout-contract-locked-20260310.tar \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_phase61-exact-current-state-20260310.tar \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_v60.2-operator-console-polish-preview.tar \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_v60.1-recovered-stable-dashboard-checkpoint-20260309.tar \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_v60.1-dashboard-hierarchy-polish-preview.tar \
  ./.artifacts/docker/motherboard_systems_hq-dashboard_v60.0-agent-pool-polish-preview.tar

echo "Emergency space recovery completed."
df -h .
