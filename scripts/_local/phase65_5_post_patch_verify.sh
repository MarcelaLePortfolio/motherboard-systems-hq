#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-/tmp/phase65_post_patch_verify.out}"

{
  echo "== Phase 65 post-patch verification =="
  echo
  echo "-- branch / head --"
  git branch --show-current
  git rev-parse --short HEAD

  echo
  echo "-- changed metrics hooks in source --"
  nl -ba public/js/agent-status-row.js | sed -n '360,700p'

  echo
  echo "-- protection guards --"
  bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
  bash scripts/_local/phase64_8_pre_push_contract_guard.sh

  echo
  echo "-- compose status --"
  docker compose ps dashboard || true

  echo
  echo "-- rerun hardened runtime verification --"
  bash scripts/_local/phase65_3_metrics_runtime_verify.sh

  echo
  echo "-- key verification excerpts --"
  grep -nE 'base_url=|dashboard_up=|container_http_up=|metric-tasks|metric-success|metric-success-rate|metric-latency|policy.probe.task|task_status|status":"running"|status":"queued"|Recv failure|Connection reset|error|failed' \
    /tmp/phase65_metrics_runtime_verify.out || true

  echo
  echo "Manual browser checks:"
  echo "1. Open http://127.0.0.1:8080"
  echo "2. Hard refresh with Cmd+Shift+R"
  echo "3. Confirm Tasks Running is not blank"
  echo "4. Confirm Success Rate is not blank"
  echo "5. Confirm Latency is not blank"
  echo "6. Confirm Task Events tab remains interactive"
} | tee "$OUT"

echo
echo "Post-patch verification log written to: $OUT"
