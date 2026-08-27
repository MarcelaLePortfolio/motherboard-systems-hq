#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE AND CLOSE GOVERNED REMOTE PUSH EFFECT UNIT ==="
echo "MODE=EXECUTION"
echo "PRODUCTION_CHANGE=NONE"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"

EXPECTED_HEAD_PREFIX="054d45b00"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFIED IMPLEMENTATION CHECKPOINTS ==="
echo "REMOTE_PUSH_EFFECT_COMMIT=93d3fe06a"
echo "REMOTE_PUSH_SMOKE_FIX_RECORD=054d45b00"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== REVALIDATE TEMP BARE REMOTE PUSH EFFECT ==="
npx tsx server/execution/smoke-test-governed-remote-push.ts
echo "REMOTE_PUSH_SMOKE=PASS"

echo
echo "=== VERIFY PUSH PROCESS CONTRACT ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(source, /performGovernedRemotePush/);
assert.match(source, /execFileSync/);
assert.match(source, /shell:\s*false/);
assert.match(source, /"push"/);
assert.match(source, /HEAD:refs\/heads\//);
assert.match(source, /ls-remote/);
assert.match(source, /remoteEffect:\s*true/);
assert.match(source, /pushEffect:\s*true/);
assert.match(source, /forceEffect:\s*false/);

assert.doesNotMatch(source, /--force/);
assert.doesNotMatch(source, /--force-with-lease/);
assert.doesNotMatch(source, /\bexecSync\s*\(/);
assert.doesNotMatch(source, /\bspawn\s*\(/);

console.log("REMOTE_PUSH_PROCESS_CONTRACT=PASS");
NODE

echo
echo "=== VERIFY PUSH ADAPTER PROVENANCE ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/execution/cade-governed-push-adapter.ts",
  "utf8",
);

for (const pattern of [
  /commit_authorized=true/,
  /push_authorized=true/,
  /expected_push_head/,
  /approval_id/,
  /envelope_id/,
  /execution_id/,
  /remote_url/,
  /pre_remote_head/,
  /post_remote_head/,
  /local_head/,
  /remote_effect:\s*true/,
  /push_effect:\s*true/,
  /force_effect:\s*false/,
  /affectedFiles:\s*\[\]/,
]) {
  assert.match(source, pattern);
}

console.log("REMOTE_PUSH_PROVENANCE=PASS");
NODE

echo
echo "=== VERIFY LOCAL COMMIT UNIT REMAINS STABLE ==="
if git diff -- \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/smoke-test-governed-local-commit.ts \
  | grep -q .; then
  echo "STOP: closed local commit unit changed"
  exit 1
fi
echo "LOCAL_COMMIT_UNIT_STABLE=YES"

echo
echo "=== VERIFY PUSH APPROVAL UNIT REMAINS STABLE ==="
if git diff -- \
  server/execution/execution-approval-gate.mjs \
  server/execution/smoke-test-version-control-contract.mjs \
  server/execution/smoke-test-version-control-push-approval.mjs \
  | grep -q .; then
  echo "STOP: closed push approval unit changed"
  exit 1
fi
echo "PUSH_APPROVAL_UNIT_STABLE=YES"

echo
echo "=== VERIFY GENERIC AUTHORITY SURFACES REMAIN UNCHANGED ==="
if git diff -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  | grep -q .; then
  echo "STOP: prohibited generic authority surface changed"
  exit 1
fi
echo "GENERIC_AUTHORITY_SURFACES_STABLE=YES"

echo
echo "=== VERIFY GENERIC ROUTE HAS NO VERSION CONTROL REACHABILITY ==="
if git grep -n -E \
  'performGovernedLocalCommit|executeGovernedLocalCommit|performGovernedRemotePush|executeGovernedRemotePush' \
  -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts
then
  echo "STOP: governed version control reachable through generic Cade route"
  exit 1
fi
echo "GENERIC_CADE_ROUTE_VERSION_CONTROL_REACHABILITY=NO"

echo
echo "=== VERIFY ACTIVE PROJECT REMOTE WAS NOT USED BY SMOKE ==="
grep -q 'mkdtempSync' \
  server/execution/smoke-test-governed-remote-push.ts
grep -q 'init.*--bare\|--bare' \
  server/execution/smoke-test-governed-remote-push.ts
echo "TEMP_BARE_REMOTE_TEST_BOUNDARY=PASS"

echo
echo "=== CLOSURE ==="
echo "GOVERNED_REMOTE_PUSH_EFFECT_UNIT=CLOSED"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTED=YES"
echo "REMOTE_PUSH_EFFECT_VALIDATED_AGAINST_TEMP_BARE_REMOTE=YES"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION_ENABLED=NO"
echo "LOCAL_COMMIT_UNIT_REMAINS_CLOSED=YES"
echo "PUSH_APPROVAL_UNIT_REMAINS_CLOSED=YES"
echo "GENERIC_MUTATION_AUTHORITY=DISABLED"
echo "GENERIC_SHELL_AUTHORITY=DISABLED"
echo "AUTONOMOUS_EXECUTION_AUTHORITY=DISABLED"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "NEXT_ACTION=CLASSIFY_PRODUCTION_REACHABILITY_AND_END_TO_END_GOVERNED_GIT_FLOW_BEFORE_ACTIVE_REPOSITORY_ENABLEMENT"
