#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT="docs/checkpoints/PHASE61_5_5S_PROBE_TRUTHFUL_AGENT_RUNTIME_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.5s truthful agent runtime probe =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== verifier summary =="
  scripts/_local/phase61_5_5r_verify_truthful_agent_status_patch.sh
  echo

  echo "== live /events/ops bounded sample =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
  echo
  echo

  echo "== extracted agent-bearing lines from latest bounded sample =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops 2>/dev/null \
    | grep -nE 'ops.state|agents|Matilda|Cade|Effie|Atlas|status|actor|source|worker' || true
  echo

  echo "== dashboard container logs tail =="
  docker logs --tail 80 motherboard_systems_hq-dashboard-1 2>&1 || true
  echo

  echo "== current source handler anchors =="
  grep -nE 'function handleOpsEvent|function applyAgentMap|function applySingleAgent|addEventListener\\("ops.state"|source\\.onmessage' public/js/agent-status-row.js public/bundle.js || true
  echo
} > "$OUT"

echo "$OUT"
