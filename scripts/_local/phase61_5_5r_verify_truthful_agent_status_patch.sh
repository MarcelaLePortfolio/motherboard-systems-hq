#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "== HEAD =="
git rev-parse --short HEAD
git log --oneline -n 3

echo
echo "== tracked file status =="
git status --short public/js/agent-status-row.js public/bundle.js public/bundle.js.map scripts/_local/phase61_5_5q_truthful_agent_status_from_named_ops_events.sh

echo
echo "== source contains named ops handlers =="
grep -n 'handleOpsEvent("ops.state"' public/js/agent-status-row.js
grep -n 'applyAgentMap' public/js/agent-status-row.js
grep -n 'source.addEventListener("ops.state"' public/js/agent-status-row.js

echo
echo "== bundle contains named ops handlers =="
grep -n 'handleOpsEvent("ops.state"' public/bundle.js
grep -n 'applyAgentMap' public/bundle.js
grep -n 'source.addEventListener("ops.state"' public/bundle.js

echo
echo "== exact diff vs HEAD =="
git diff -- public/js/agent-status-row.js public/bundle.js public/bundle.js.map scripts/_local/phase61_5_5q_truthful_agent_status_from_named_ops_events.sh || true
