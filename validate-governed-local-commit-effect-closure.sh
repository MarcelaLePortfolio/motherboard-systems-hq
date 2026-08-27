#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE GOVERNED LOCAL COMMIT EFFECT CLOSURE ==="
echo "MODE=EXECUTION"
echo "PRODUCTION_CHANGE=NONE"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"

EXPECTED_HEAD_PREFIX="bd7cbc004"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CLOSED IMPLEMENTATION CHECKPOINT ==="
echo "LOCAL_COMMIT_EFFECT_COMMIT=5e46709dc"
echo "VALIDATION_FIX_RECORD=bd7cbc004"

echo
echo "=== VERIFY COMMITTED SURFACES ==="
for f in \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/smoke-test-governed-local-commit.ts
do
  test -f "${f}" || {
    echo "STOP: missing committed surface ${f}"
    exit 1
  }
  echo "PRESENT=${f}"
done

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== REVALIDATE TEMP-REPOSITORY LOCAL COMMIT EFFECT ==="
npx tsx server/execution/smoke-test-governed-local-commit.ts
echo "LOCAL_COMMIT_SMOKE=PASS"

echo
echo "=== VERIFY PROCESS CONTRACT ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const effect = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(effect, /execFileSync/);
assert.match(effect, /shell:\s*false/);
assert.match(effect, /realpathSync/);

assert.doesNotMatch(effect, /\bexecSync\s*\(/);
assert.doesNotMatch(effect, /\bspawn\s*\(/);
assert.doesNotMatch(effect, /["']push["']/);
assert.doesNotMatch(effect, /--force/);
assert.doesNotMatch(effect, /--force-with-lease/);

console.log("PROCESS_CONTRACT=PASS");
NODE

echo
echo "=== VERIFY GOVERNED ADAPTER PROVENANCE ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const adapter = fs.readFileSync(
  "server/execution/cade-governed-commit-adapter.ts",
  "utf8",
);

for (const pattern of [
  /commit_authorized=true/,
  /push_authorized=true/,
  /approval_id/,
  /envelope_id/,
  /execution_id/,
  /pre_head/,
  /post_head/,
  /committed_files/,
  /remote_effect:\s*false/,
  /push_effect:\s*false/,
  /affectedFiles/,
]) {
  assert.match(adapter, pattern);
}

console.log("PROVENANCE_CONTRACT=PASS");
NODE

echo
echo "=== VERIFY GENERIC ROUTE REMAINS UNREACHABLE ==="
if git grep -n -E \
  'executeGovernedLocalCommit|performGovernedLocalCommit' \
  -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts
then
  echo "STOP: governed local commit reachable through generic Cade route"
  exit 1
fi
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"

echo
echo "=== VERIFY APPROVAL BOUNDARY REMAINS CLOSED ==="
grep -q 'governed_version_control_commit' \
  server/execution/execution-approval-gate.mjs
grep -q 'push_authorized: false' \
  server/execution/execution-approval-gate.mjs
grep -q 'mutation_authorized: false' \
  server/execution/execution-approval-gate.mjs
grep -q 'shell_execution_authorized: false' \
  server/execution/execution-approval-gate.mjs
grep -q 'autonomous_execution_authorized: false' \
  server/execution/execution-approval-gate.mjs
echo "APPROVAL_BOUNDARY=PASS"

echo
echo "=== VERIFY ACTIVE PROJECT HISTORY WAS NOT USED BY SMOKE ==="
grep -q 'mkdtempSync' \
  server/execution/smoke-test-governed-local-commit.ts
grep -q 'os.tmpdir' \
  server/execution/smoke-test-governed-local-commit.ts
echo "TEMP_REPOSITORY_TEST_BOUNDARY=PASS"

echo
echo "=== CLOSURE ==="
echo "GOVERNED_LOCAL_COMMIT_EFFECT_UNIT=CLOSED"
echo "LOCAL_COMMIT_CAPABILITY_IMPLEMENTED=YES"
echo "LOCAL_COMMIT_CAPABILITY_GENERIC_ROUTE_EXPOSED=NO"
echo "REMOTE_PUSH_EFFECT=NOT_ENABLED"
echo "GENERIC_SHELL_AUTHORITY=DISABLED"
echo "GENERIC_MUTATION_AUTHORITY=DISABLED"
echo "AUTONOMOUS_EXECUTION_AUTHORITY=DISABLED"
echo "NEXT_ACTION=CLASSIFY_REMOTE_PUSH_SUCCESSOR_UNIT_FROM_CLOSED_LOCAL_COMMIT_BOUNDARY"
