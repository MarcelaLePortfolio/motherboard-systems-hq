#!/usr/bin/env bash
set -euo pipefail

git fetch --tags

RESTORE_TAG="v63.0-telemetry-integration-golden"

echo "== restoring layout-bearing files from ${RESTORE_TAG} =="
git checkout "${RESTORE_TAG}" -- \
  public/dashboard.html \
  public/css/dashboard.css \
  public/js/phase61_tabs_workspace.js \
  public/js/phase61_recent_history_wire.js \
  public/js/agent-status-row.js \
  public/js/dashboard-bundle-entry.js

echo
echo "== layout/script guards =="
bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
bash scripts/_local/phase64_8_pre_push_contract_guard.sh

echo
echo "== rebuild dashboard =="
docker compose build dashboard
docker compose up -d dashboard

echo
echo "== compose status =="
docker compose ps dashboard || true

echo
echo "== runtime verification =="
bash scripts/_local/phase65_3_metrics_runtime_verify.sh || true
