#!/usr/bin/env bash
# DASHBOARD_ROLLBACK_PROTECTION_GUARD_V2
echo "BLOCKED=LEGACY_DASHBOARD_ROLLBACK_DISABLED"
echo "REASON=PROTECTED_REACT_DASHBOARD_IS_AUTHORITATIVE"
echo "RECOVERY=GOVERNED_REACT_DASHBOARD_ONLY"
exit 78
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

GOOD_REF="${1:-2b467a03}"

git rev-parse -q --verify "${GOOD_REF}^{commit}" >/dev/null

git restore --source "${GOOD_REF}" -- \
  public/dashboard.html \
  public/js/phase61_tabs_workspace.js

git diff -- public/dashboard.html public/js/phase61_tabs_workspace.js || true
