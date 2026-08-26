#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY APPROVALS INFORMATION HIERARCHY IMPLEMENTATION ==="
echo "IMPLEMENTATION_COMMIT=b256f2d3"
echo "RECOVERY_POINT=DR_20260826_092915"

echo
echo "=== EXPECTED PRIMARY MARKERS ==="
rg -n \
  'Package Review|What you are approving|Approval effect|Needs review' \
  client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== EXPECTED COLLAPSED TECHNICAL MARKERS ==="
rg -n \
  'Technical details|Source status|Artifact position|Supporting evidence' \
  client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== LEGACY PRIMARY MARKERS MUST BE ABSENT ==="
if rg -n \
  'Approve Canonical Package|Selected artifact:|<DecisionBadge>Pending</DecisionBadge>|BriefingSection title="Requested outcome"|BriefingSection title="Proposed work"|BriefingSection title="Proposed artifacts"|function artifactLabel|index=\{index\}' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "LEGACY_PRIMARY_PRESENTATION=YES"
  exit 1
fi
echo "LEGACY_PRIMARY_PRESENTATION=NO"

echo
echo "=== BUILD ==="
(
  cd client
  npm run build
)

git diff --check

echo
echo "IMPLEMENTATION_VALIDATED=YES"
echo "PACKAGES_TAB_REMOVAL_AUTHORIZED=NO"
echo "NEXT_ACTION=LIVE_VISUAL_REVIEW_OF_REFINED_APPROVALS_BEFORE_ANY_FURTHER_CHANGE"
