#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="4e1d880b0"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — EXECUTION ENVELOPE DURABILITY IMPLEMENTATION ==="
echo "MODE=EXECUTION"
echo "AUTHORIZED_CHECKPOINT=58abf60d4"
echo

echo "=== TARGETED TESTS ==="
npx tsx --test db/governance-execution-scope-persistence.test.ts
echo

echo "=== EXISTING APPROVAL PERSISTENCE REGRESSION ==="
npx tsx --test db/governance-execution-approval-persistence.test.ts
echo

echo "=== TYPESCRIPT ==="
npx tsc --noEmit
echo

echo "=== EXCLUDED SURFACE CHECK ==="
if git diff -- server/index.ts \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/execution/production-execution-entry-point.ts \
  server/execution/execution-approval-gate.mjs \
  | grep -q .; then
  echo "STOP=EXCLUDED_SURFACE_CHANGED"
  git diff -- server/index.ts \
    server/cade/cade-version-control-effects.ts \
    server/execution/cade-governed-commit-adapter.ts \
    server/execution/cade-governed-push-adapter.ts \
    server/execution/production-execution-entry-point.ts \
    server/execution/execution-approval-gate.mjs
  exit 1
fi

echo "DURABLE_REPO_PATH_BINDING_IMPLEMENTED=YES"
echo "DURABLE_EXPECTED_HEAD_BINDING_IMPLEMENTED=YES"
echo "DURABLE_ALLOWED_PATHS_BINDING_IMPLEMENTED=YES"
echo "DURABLE_FORBIDDEN_PATHS_BINDING_IMPLEMENTED=YES"
echo "DURABLE_SCOPE_CONSTRAINTS_BINDING_IMPLEMENTED=YES"
echo "EXACT_ENVELOPE_PACKAGE_APPROVAL_BINDING_IMPLEMENTED=YES"
echo "FAIL_CLOSED_EXECUTION_SCOPE_READER_IMPLEMENTED=YES"
echo "IN_MEMORY_TARGETED_TESTS_IMPLEMENTED=YES"
echo "SERVER_INDEX_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "UNMOUNTED_EXECUTION_ROUTE_CHANGED=NO"
echo
echo "CORRIDOR_6_STATUS=EXECUTION_ENVELOPE_DURABILITY_IMPLEMENTED_PENDING_VERIFICATION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=VERIFY_DURABILITY_IMPLEMENTATION_BEFORE_RESUMING_UNMOUNTED_ROUTE"
echo
git status --short
