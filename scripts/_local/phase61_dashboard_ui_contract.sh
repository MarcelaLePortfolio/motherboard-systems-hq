#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

HTML="public/dashboard.html"
BUNDLE="public/bundle.js"
AGENT_JS="public/js/agent-status-row.js"
RECENT_JS="public/js/phase61_recent_history_wire.js"
DELEGATION_JS="public/js/dashboard-delegation.js"

scripts/verify-dashboard-layout-contract.sh "$HTML"

grep -q 'id="agent-status-container"' "$HTML"
grep -q 'id="delegation-input"' "$HTML"
grep -q 'id="delegation-submit"' "$HTML"
grep -q 'id="delegation-status-panel"' "$HTML"
grep -q 'id="delegation-response"' "$HTML"
grep -q 'id="recent-tasks-card"' "$HTML"
grep -q 'id="task-history-card"' "$HTML"
grep -q 'id="task-events-card"' "$HTML"

grep -q 'AGENTS = \["Matilda", "Cade", "Effie", "Atlas"\]' "$AGENT_JS"
grep -q 'indicator.bar.style.background = "rgba(252,211,77,0.95)"' "$AGENT_JS"
grep -q 'h-\[18px\]' "$AGENT_JS"

grep -q 'Loading recent tasks…' "$RECENT_JS"
grep -q 'Loading task history…' "$RECENT_JS"

grep -q '/api/delegate-task' "$DELEGATION_JS"
grep -q 'Task Delegation wiring active' "$BUNDLE"

echo "PASS: Phase 61 dashboard UI contract"
