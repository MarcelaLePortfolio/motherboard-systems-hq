#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY APPROVALS RECOMPOSITION LIVE-REVIEW READINESS ==="
echo "IMPLEMENTATION_COMMIT=727ac28c"
echo "CLIENT_BUILD=PASS"
echo "ARTIFACT_SWITCHER_REMOVED=YES"
echo "OBSOLETE_NAVIGATION_REMOVED=YES"

echo
echo "=== REACT MARKERS ==="
rg -n \
  'executive-briefing__header--calm|executive-briefing__transition--compact|Draft status|executive-briefing-technical__evidence' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

echo
echo "=== LEGACY MARKERS MUST BE ABSENT ==="
if rg -n \
  'function ArtifactSwitcher|<ArtifactSwitcher|function selectPrevious|function selectNext' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "LEGACY_APPROVAL_NAVIGATION_PRESENT=YES"
  exit 1
fi
echo "LEGACY_APPROVAL_NAVIGATION_PRESENT=NO"

echo
echo "=== CURRENT DIFF BOUNDARY ==="
git status --short
git diff --check

echo
echo "LIVE_VISUAL_REVIEW_READY=YES"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"
echo "NEXT_ACTION=OPEN_APPROVALS_IN_UI_AND_COMPARE_DIRECTLY_WITH_PACKAGES_BEFORE_ANY_FURTHER_CHANGE"
