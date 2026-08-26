#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT APPROVALS RIGHT-PANEL COMPOSITION ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT APPROVALS DETAIL STRUCTURE ==="
rg -n \
  'Approve Canonical Package|EXECUTIVE SUMMARY|REQUESTED OUTCOME|PROPOSED WORK|PROPOSED ARTIFACTS|SCOPE|CONSTRAINTS|SUPPORTING EVIDENCE|Technical details|Approve|Request Changes|Current state|Proposed state' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== CURRENT DETAIL COMPONENT BOUNDARIES ==="
rg -n \
  'function |const .* = \(|return \(|className=|<section|<article|<details|<button' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== PACKAGES DETAIL STRUCTURE FOR VISUAL REFERENCE ==="
rg -n \
  'className=|function |const .* = \(|return \(|<section|<article|<button' \
  client/src/packages/PackagesWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== DESIGN BOUNDARY ==="
echo "DESIGN_FOUNDATION=PACKAGES_VISUAL_HIERARCHY"
echo "FUNCTIONAL_FOUNDATION=APPROVALS"
echo "NO_FIELDS_REMOVED_YET=YES"
echo "NO_REACT_CHANGE_AUTHORIZED=YES"
echo "QUESTION=WHAT_MINIMUM_VISIBLE_INFORMATION_SUPPORTS_A_CONFIDENT_APPROVAL_OR_REQUEST_CHANGES_DECISION"
echo
echo "NEXT_ACTION=PROPOSE_EXACT_VISIBLE_RIGHT_PANEL_AND_COLLAPSED_DETAIL_STRUCTURE_FROM_SOURCE_EVIDENCE"
