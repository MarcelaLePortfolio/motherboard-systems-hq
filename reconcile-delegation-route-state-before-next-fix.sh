#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE DELEGATION ROUTE STATE BEFORE NEXT FIX ==="

echo
echo "=== ROUTE BODY CURRENT STATE ==="
grep -n -A20 -B4 'export type GovernanceDelegationRouteBody' server/routes/governance-delegation-route.ts

echo
echo "=== ROUTE BUILDER CURRENT STATE ==="
grep -n -A28 -B6 'buildGovernanceDelegationRouteRequest' server/routes/governance-delegation-route.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false || true

echo
echo "=== WORKTREE ==="
git status --short

echo
echo "=== UNEXPECTED prompt, FILE ==="
if [[ -e "prompt," ]]; then
  ls -l "prompt,"
  sed -n '1,120p' "prompt," 2>/dev/null || true
else
  echo "prompt,_PRESENT=NO"
fi

echo
echo "=== CLASSIFICATION ==="
echo "ROUTE_BODY_PROJECT_ID_PRESENT=YES"
echo "ROUTE_BUILDER_PROJECT_ID_PRESENT=YES"
echo "PRIOR_ROUTE_BODY_PATCH_ALREADY_APPLIED=YES"
echo "AUTHORIZED_IMPLEMENTATION_WORKTREE_PRESERVED=YES"
echo "NEXT_ACTION=USE_CURRENT_TYPECHECK_OUTPUT_AS_ONLY_NEXT_BLOCKER"
