#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6dcc20ca4"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== SERVER BUILD ==="
npm run build

echo
echo "=== CLIENT BUILD ==="
(
  cd client
  npm run build
)

echo
echo "=== DELEGATION READ MODEL IMPLEMENTATION ==="
grep -n \
  -E 'awaiting_delegation|delegated|ambiguous|governance_delegations|LIMIT 2|authorization_state' \
  db/canonical-package-read-repository.ts

echo
echo "=== CLIENT DELEGATION ADAPTER ==="
grep -n \
  -E 'delegateCanonicalPackage|/api/governance/delegation|AUTHORIZED|package_version|delegated_by' \
  client/src/approvals/governanceDelegationApi.ts

echo
echo "=== EXECUTIVE UI GUARDS ==="
grep -n \
  -E 'awaiting_delegation|Delegated|Delegation unavailable|handleDelegate|delegationError|onDelegated|does not authorize execution' \
  client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== GOVERNANCE ROUTE AUTHORITY BOUNDARY ==="
grep -n \
  -E 'scheduler_authorized: false|worker_claim_authorized: false|orchestration_authorized: false|routing_authorized: false|assignment_authorized: false|execution_authorized: false|downstream_governance_authorized: false|new_authority_introduced: false' \
  server/routes/governance-delegation-route.ts

echo
echo "=== WORKTREE STATUS ==="
git status --short
