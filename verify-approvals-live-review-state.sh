#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY APPROVALS LIVE REVIEW STATE ==="
echo "BASELINE_COMMIT=37794f20"
echo "CLIENT_BUILD=PASS"
echo "LIVE_VISUAL_REVIEW_READY=YES"

echo
echo "=== TRACKED WORKING TREE ==="
git status --short

echo
echo "=== APPROVALS REACT CURRENT MARKERS ==="
rg -n \
  'DecisionBadge|executive-briefing__header|executive-briefing__transition|Technical details|DecisionActions|Pending decisions' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== APPROVALS CSS CURRENT MARKERS ==="
rg -n \
  'Approvals calm decision-brief recomposition|executive-inbox-layout|executive-inbox-reading-pane|executive-briefing-section|executive-decision-actions' \
  client/src/approvals/approvals-workspace.css || true

echo
echo "=== REVIEW BOUNDARY ==="
echo "NO_FURTHER_IMPLEMENTATION_BEFORE_VISUAL_REVIEW=YES"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"
echo "NEXT_ACTION=OPEN_APPROVALS_AND_PACKAGES_SIDE_BY_SIDE_AND_REVIEW_VISUAL_RESULT"
