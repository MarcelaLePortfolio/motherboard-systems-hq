#!/usr/bin/env bash
# DASHBOARD_ROLLBACK_PROTECTION_GUARD_V2
echo "BLOCKED=LEGACY_DASHBOARD_ROLLBACK_DISABLED"
echo "REASON=PROTECTED_REACT_DASHBOARD_IS_AUTHORITATIVE"
echo "RECOVERY=GOVERNED_REACT_DASHBOARD_ONLY"
exit 78
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CHECKPOINT_TAG="${1:-v61.0-observational-workspace-checkpoint}"

git rev-parse -q --verify "refs/tags/${CHECKPOINT_TAG}" >/dev/null

git restore --source "${CHECKPOINT_TAG}" -- \
  public/dashboard.html \
  public/js/phase61_tabs_workspace.js

git diff -- public/dashboard.html public/js/phase61_tabs_workspace.js || true
