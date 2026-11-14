#!/usr/bin/env bash
# DASHBOARD_ROLLBACK_PROTECTION_GUARD_V2
echo "BLOCKED=LEGACY_DASHBOARD_ROLLBACK_DISABLED"
echo "REASON=PROTECTED_REACT_DASHBOARD_IS_AUTHORITATIVE"
echo "RECOVERY=GOVERNED_REACT_DASHBOARD_ONLY"
exit 78
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

if scripts/phase41_invariants_gate.sh; then
  echo "OK: no revert needed."
  exit 0
fi

git reset --hard
git clean -fd
git checkout -f "v40.6-shadow-audit-task-events-green"
echo "Reverted to v40.6-shadow-audit-task-events-green"
exit 41
