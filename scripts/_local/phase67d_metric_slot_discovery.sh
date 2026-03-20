#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 67D metric slot discovery =="

echo "-- metric element ID references"
grep -R --line-number --exclude-dir=.git 'getElementById("metric-\|getElementById('\''metric-' public/js public/dashboard.html || true

echo
echo "-- metric ownership references"
grep -R --line-number --exclude-dir=.git 'metric-' public/js/telemetry public/js/agent-status-row.js public/js/phase64_agent_activity_wire.js public/js/dashboard-bundle-entry.js 2>/dev/null || true

echo
echo "-- protected surface check"
bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo "== Phase 67D metric slot discovery COMPLETE =="
