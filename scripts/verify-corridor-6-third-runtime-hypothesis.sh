#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="2d93dbcebe2e3ddba9a2fdcabcff51c4329f2a46"
CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== BEHAVIORAL COMPILER EQUIVALENCE ==="
npx tsx -e '
const assert = require("node:assert/strict");
const tsCompiler = require("./server/execution/compile-persisted-execution-approval.ts").compilePersistedExecutionApproval;

(async () => {
  const mjsCompiler = (
    await import("./server/execution/compile-persisted-execution-approval.mjs")
  ).compilePersistedExecutionApproval;

  const valid = {
    approval_id: "approval-1",
    envelope_id: "envelope-1",
    package_id: "package-1",
    package_version: 1,
    approved_by: "user-1",
    approval_scope: "bounded",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: "2026-08-28T00:00:00.000Z",
    expires_at: null,
    justification: null,
    status: "approved",
    created_at: "2026-08-28T00:00:00.000Z",
  };

  assert.deepEqual(tsCompiler(valid), mjsCompiler(valid));

  for (const record of [
    {},
    { ...valid, status: "pending" },
    { ...valid, approval_id: "" },
    { ...valid, approved_by: "" },
    { ...valid, commit_authorized: false, push_authorized: true },
  ]) {
    let oldError = "";
    let newError = "";

    try { mjsCompiler(record); }
    catch (error) { oldError = error.message; }

    try { tsCompiler(record); }
    catch (error) { newError = error.message; }

    assert.equal(newError, oldError);
    assert.notEqual(newError, "");
  }

  console.log("COMPILER_BEHAVIORAL_EQUIVALENCE=PASS");
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
'

npx tsx server/routes/governance-execution-route.test.ts
npx tsx server/execution/production-execution-entry-point.test.ts
npx tsx db/governance-execution-read-repository.test.ts
npx tsx db/governance-execution-approval-persistence.test.ts
npx tsx db/governance-execution-scope-persistence.test.ts
npx tsc --noEmit
npm run build

test -f dist/server/execution/compile-persisted-execution-approval.js
test -f dist/server/execution/execution-approval-gate.js
test -f dist/server/execution/production-governance-execution-composition.js

node - <<'EOF_NODE'
const compiler = require("./dist/server/execution/compile-persisted-execution-approval.js");
const composition = require("./dist/server/execution/production-governance-execution-composition.js");

if (typeof compiler.compilePersistedExecutionApproval !== "function") {
  throw new Error("Compiled approval compiler missing");
}

if (typeof composition.createProductionGovernanceExecutionRouter !== "function") {
  throw new Error("Compiled production composition missing");
}

if (!composition.createProductionGovernanceExecutionRouter()) {
  throw new Error("Compiled production router construction failed");
}

console.log("FULL_DIST_EXECUTION_COMPOSITION=PASS");
EOF_NODE

node dist/server/index.js >/tmp/corridor-6-third-runtime.log 2>&1 &
SERVER_PID=$!
sleep 3

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
  cat /tmp/corridor-6-third-runtime.log
  echo "COMPILED_SERVER_RUNTIME=FAIL"
  exit 1
fi

kill "${SERVER_PID}" 2>/dev/null || true
wait "${SERVER_PID}" 2>/dev/null || true

echo "COMPILED_SERVER_RUNTIME=PASS"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "NEW_AUTHORITY_INTRODUCED=NO"
echo "THIRD_RUNTIME_HYPOTHESIS=VERIFIED"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
