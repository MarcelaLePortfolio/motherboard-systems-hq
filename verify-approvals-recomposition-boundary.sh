#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY APPROVALS RECOMPOSITION BOUNDARY ==="
echo "IMPLEMENTATION_COMMIT=8932e682"
echo "CLIENT_BUILD=PASSED"
echo "EXPECTED_CHANGED_FILE=client/src/approvals/approvals-workspace.css"
echo "EXPECTED_REACT_CHANGE_PRESENT=CHECK_REQUIRED"

echo
echo "=== COMMIT FILES ==="
git show --stat --oneline --decorate=short 8932e682
echo
git show --name-only --format='' 8932e682

echo
echo "=== CURRENT REACT MARKERS ==="
rg -n \
  'executive-briefing__header--calm|executive-briefing__transition--compact|ArtifactSwitcher|Supporting evidence|Draft status' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== CURRENT CSS MARKERS ==="
rg -n \
  'Approvals calm decision-brief recomposition|executive-briefing__header--calm|executive-briefing__transition--compact' \
  client/src/approvals/approvals-workspace.css || true

echo
echo "NEXT_ACTION=DETERMINE_WHETHER_REACT_RECOMPOSITION_WAS_ACTUALLY_COMMITTED_BEFORE_LIVE_VISUAL_REVIEW"
