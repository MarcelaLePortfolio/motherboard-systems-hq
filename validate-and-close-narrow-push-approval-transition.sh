#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE AND CLOSE NARROW PUSH APPROVAL TRANSITION ==="
echo "MODE=EXECUTION"
echo "PRODUCTION_CHANGE=NONE"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTATION_AUTHORIZED=NO"
echo "REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="aa932097d"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFIED IMPLEMENTATION CHECKPOINTS ==="
echo "PUSH_APPROVAL_IMPLEMENTATION_COMMIT=d277f13e1"
echo "PUSH_APPROVAL_SMOKE_FIX_RECORD=aa932097d"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== VERSION CONTROL CONTRACT REGRESSION SMOKE ==="
npx tsx server/execution/smoke-test-version-control-contract.mjs
echo "VERSION_CONTROL_CONTRACT_SMOKE=PASS"

echo
echo "=== PUSH APPROVAL TRANSITION SMOKE ==="
npx tsx server/execution/smoke-test-version-control-push-approval.mjs
echo "PUSH_APPROVAL_SMOKE=PASS"

echo
echo "=== VERIFY PHASE SEPARATION ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/execution/execution-approval-gate.mjs",
  "utf8",
);

assert.match(
  source,
  /governed_planning_only/,
);

assert.match(
  source,
  /governed_version_control_commit/,
);

assert.match(
  source,
  /governed_version_control_push/,
);

assert.match(
  source,
  /expected_push_head/,
);

assert.match(
  source,
  /governed_local_commit_verified/,
);

assert.match(
  source,
  /push_authority_granted/,
);

assert.match(
  source,
  /mutation_authorized:\s*false/,
);

assert.match(
  source,
  /shell_execution_authorized:\s*false/,
);

assert.match(
  source,
  /autonomous_execution_authorized:\s*false/,
);

console.log("PHASE_SEPARATION=PASS");
NODE

echo
echo "=== VERIFY APPROVAL UNIT HAS NO GIT PROCESS EFFECT ==="
node - <<'NODE'
const fs = require("fs");

const files = [
  "server/execution/execution-approval-gate.mjs",
  "server/execution/smoke-test-version-control-contract.mjs",
  "server/execution/smoke-test-version-control-push-approval.mjs",
];

const prohibited = [
  /node:child_process/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
  /\bgit\s+push\b/,
];

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");

  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process or push effect in ${file}`,
      );
    }
  }
}

console.log("APPROVAL_UNIT_SIDE_EFFECTS=NONE");
NODE

echo
echo "=== VERIFY LOCAL COMMIT EFFECT REMAINS UNCHANGED ==="
if git diff -- \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/smoke-test-governed-local-commit.ts \
  | grep -q .; then
  echo "STOP: closed local commit unit changed"
  exit 1
fi

echo "LOCAL_COMMIT_UNIT_STABLE=YES"

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
echo "=== VERIFY PUSH EFFECT STILL ABSENT ==="
if git grep -n -E \
  'performGovernedRemotePush|executeGovernedRemotePush|action: "push_changes"|action: '\''push_changes'\''' \
  -- \
  server/cade \
  server/execution \
  routes
then
  echo "STOP: remote push effect unexpectedly exists"
  exit 1
fi

echo "REMOTE_PUSH_EFFECT_IMPLEMENTED=NO"

echo
echo "=== VERIFY GENERIC ROUTE HAS NO VERSION CONTROL EFFECT REACHABILITY ==="
if git grep -n -E \
  'performGovernedLocalCommit|executeGovernedLocalCommit|performGovernedRemotePush|executeGovernedRemotePush' \
  -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts
then
  echo "STOP: governed version control effect reachable through generic Cade route"
  exit 1
fi

echo "GENERIC_CADE_ROUTE_VERSION_CONTROL_REACHABILITY=NO"

echo
echo "=== CLOSURE ==="
echo "NARROW_PUSH_APPROVAL_TRANSITION=CLOSED"
echo "PUSH_APPROVAL_CAPABILITY_IMPLEMENTED=YES"
echo "REMOTE_PUSH_EFFECT_IMPLEMENTED=NO"
echo "REMOTE_PUSH_EXECUTION_ENABLED=NO"
echo "LOCAL_COMMIT_UNIT_REMAINS_CLOSED=YES"
echo "GENERIC_MUTATION_AUTHORITY=DISABLED"
echo "GENERIC_SHELL_AUTHORITY=DISABLED"
echo "AUTONOMOUS_EXECUTION_AUTHORITY=DISABLED"
echo "NEXT_ACTION=CLASSIFY_AND_AUTHORIZE_GOVERNED_REMOTE_PUSH_EFFECT_UNIT_FROM_CLOSED_PUSH_APPROVAL_BOUNDARY"
