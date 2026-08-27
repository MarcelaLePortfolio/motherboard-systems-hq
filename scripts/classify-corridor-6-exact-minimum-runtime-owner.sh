#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="f96a6e4ef"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — EXACT MINIMUM RUNTIME OWNER CLASSIFICATION ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ROUTE_IMPLEMENTATION_PRESENT=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo

TMP_ROOT=".tmp-corridor-6-minimum-owner"
rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT"
trap 'rm -rf "$TMP_ROOT"' EXIT

echo "=== ESTABLISHED RESOLUTION FACTS ==="
echo "MJS_IMPORTER_TO_APPROVAL_GATE=PASS"
echo "TS_STATIC_IMPORTER_TO_APPROVAL_GATE=FAIL"
echo "TS_NODE_TEST_IMPORTER_TO_APPROVAL_GATE=FAIL"
echo "DIRECT_TS_IMPORT_OF_CANONICAL_EVALUATOR=PASS"
echo "BUILD_EMITS_EVALUATOR_JS=YES"
echo "SOURCE_EVALUATOR_JS=NO"
echo "APPROVAL_GATE_UNIVERSALLY_BROKEN=NO"
echo "IMPORTER_CONTEXT_DEPENDENCE=ESTABLISHED"
echo

echo "=== CONTROL 1 — PRODUCTION EXECUTION ENTRY POINT FROM TS ==="
cat > "$TMP_ROOT/import-production-entry-point.ts" <<'NODE'
import {
  executeProductionExecutionEntryPoint,
} from "../server/execution/production-execution-entry-point";

console.log(
  "PRODUCTION_ENTRY_POINT_IMPORT_TYPE=" +
    typeof executeProductionExecutionEntryPoint,
);

if (typeof executeProductionExecutionEntryPoint !== "function") {
  process.exit(21);
}

console.log("CONTROL_1_PRODUCTION_ENTRY_POINT_TS_IMPORT=PASS");
NODE

node --import tsx "$TMP_ROOT/import-production-entry-point.ts"
echo

echo "=== CONTROL 2 — INJECTED APPROVAL EVALUATOR COMPOSITION ==="
cat > "$TMP_ROOT/injected-composition.ts" <<'NODE'
import {
  executeProductionExecutionEntryPoint,
} from "../server/execution/production-execution-entry-point";

let evaluatorCalls = 0;
let commitCalls = 0;
let pushCalls = 0;

const result = executeProductionExecutionEntryPoint(
  {
    envelope: {
      identity: {
        envelope_id: "envelope-control",
      },
      project_target: {
        repo_path: "/tmp/repository",
        branch: "feature/support-source-references-runtime",
        expected_head: "1111111111111111111111111111111111111111",
      },
      mutation_scope: {
        allowed_paths: ["server/routes/"],
      },
      delegation_authorization: {
        state: "delegated",
      },
    },
    governance: {
      ok: true,
    },
    approval: {
      approval_id: "approval-control",
      status: "approved",
    },
    executionId: "execution-control",
    commitRequested: false,
    pushRequested: false,
  } as any,
  {
    evaluateApproval: (() => {
      evaluatorCalls += 1;
      return {
        ok: true,
        version_control_authorization: {
          commit_authorized: false,
          push_authorized: false,
        },
      };
    }) as any,
    executeCommit: (() => {
      commitCalls += 1;
      throw new Error("commit effect must not run");
    }) as any,
    executePush: (() => {
      pushCalls += 1;
      throw new Error("push effect must not run");
    }) as any,
  },
);

if (result.status !== "ok") {
  throw new Error("injected composition did not return status=ok");
}

if (evaluatorCalls !== 1) {
  throw new Error(
    `expected exactly one injected evaluator call, got ${evaluatorCalls}`,
  );
}

if (commitCalls !== 0 || pushCalls !== 0) {
  throw new Error("Git effects unexpectedly executed");
}

console.log("CONTROL_2_INJECTED_APPROVAL_COMPOSITION=PASS");
console.log("INJECTED_EVALUATOR_CALLS=" + evaluatorCalls);
console.log("REAL_COMMIT_EFFECTS=0");
console.log("REAL_PUSH_EFFECTS=0");
NODE

node --import tsx "$TMP_ROOT/injected-composition.ts"
echo

echo "=== CONTROL 3 — ROUTE-LIKE MODULE WITHOUT APPROVAL-GATE IMPORT ==="
cat > "$TMP_ROOT/route-like-module.ts" <<'NODE'
import {
  executeProductionExecutionEntryPoint,
} from "../server/execution/production-execution-entry-point";

export function routeLikeComposition(
  request: any,
  dependencies: {
    evaluateApproval: (...args: any[]) => any;
    executeExecution?: typeof executeProductionExecutionEntryPoint;
  },
) {
  const executeExecution =
    dependencies.executeExecution ??
    executeProductionExecutionEntryPoint;

  return executeExecution(request, {
    evaluateApproval: dependencies.evaluateApproval as any,
    executeCommit: (() => {
      throw new Error("route-like control commit effect not bound");
    }) as any,
    executePush: (() => {
      throw new Error("route-like control push effect not bound");
    }) as any,
  });
}

console.log("CONTROL_3_ROUTE_LIKE_MODULE_LOAD=PASS");
NODE

cat > "$TMP_ROOT/route-like-module.test.ts" <<'NODE'
import test from "node:test";
import assert from "node:assert/strict";

import {
  routeLikeComposition,
} from "./route-like-module";

test(
  "route-like composition accepts injected approval evaluator without importing approval gate",
  () => {
    const result = routeLikeComposition(
      {
        envelope: {
          identity: {
            envelope_id: "e1",
          },
        },
        governance: {
          ok: true,
        },
        approval: {
          approval_id: "a1",
          status: "approved",
        },
        executionId: "x1",
        commitRequested: false,
        pushRequested: false,
      },
      {
        evaluateApproval: () => ({
          ok: true,
          version_control_authorization: {
            commit_authorized: false,
            push_authorized: false,
          },
        }),
      },
    );

    assert.equal(result.status, "ok");
    assert.equal(result.execution_id, "x1");
    assert.equal(result.commit_requested, false);
    assert.equal(result.push_requested, false);
  },
);
NODE

node --import tsx --test "$TMP_ROOT/route-like-module.test.ts"
echo

echo "=== CONTROL 4 — EXISTING PRODUCTION ENTRY POINT REGRESSION ==="
node --import tsx --test \
  server/execution/production-execution-entry-point.test.ts
echo

echo "=== CONTROL 5 — APPROVAL GATE REMAINS SEPARATE ==="
set +e
cat > "$TMP_ROOT/static-approval-import.ts" <<'NODE'
import "../server/execution/execution-approval-gate.mjs";
console.log("STATIC_APPROVAL_IMPORT_FROM_TS=PASS");
NODE

node --import tsx "$TMP_ROOT/static-approval-import.ts"
STATIC_APPROVAL_RC=$?
set -e

echo "STATIC_APPROVAL_IMPORT_FROM_TS_RC=$STATIC_APPROVAL_RC"
echo

echo "=== EXACT OWNER DETERMINATION ==="

if [[ "$STATIC_APPROVAL_RC" -ne 0 ]]; then
  echo "STATIC_TS_TO_MJS_APPROVAL_GATE_EDGE_INCOMPATIBLE=YES"
else
  echo "STATIC_TS_TO_MJS_APPROVAL_GATE_EDGE_INCOMPATIBLE=NO"
fi

echo "UNMOUNTED_ROUTE_REQUIRES_STATIC_APPROVAL_GATE_IMPORT=NO"
echo "UNMOUNTED_ROUTE_CAN_REQUIRE_APPROVAL_EVALUATOR_AS_INJECTED_DEPENDENCY=YES"
echo "PRODUCTION_EXECUTION_ENTRY_POINT_ALREADY_SUPPORTS_INJECTED_APPROVAL_EVALUATOR=YES"
echo "ROUTE_TESTS_CAN_AVOID_REAL_APPROVAL_GATE_IMPORT=YES"
echo "ROUTE_TESTS_CAN_AVOID_REAL_GIT_EFFECTS=YES"
echo
echo "MINIMUM_OWNER=UNMOUNTED_ROUTE_COMPOSITION_DEPENDENCY_BOUNDARY"
echo "PREEXISTING_APPROVAL_GATE_RUNTIME_REPAIR_REQUIRED_FOR_UNMOUNTED_ROUTE=NO"
echo "APPROVAL_GATE_PRODUCTION_BINDING_OWNER=FUTURE_PRODUCTION_REACHABILITY_OR_MOUNT_COMPOSITION"
echo "PRODUCTION_BINDING_RUNTIME_QUESTION=DEFERRED_UNTIL_ROUTE_MOUNT_OR_REACHABILITY_IS_AUTHORIZED"
echo "ROUTE_AND_PRODUCTION_BINDING_REMAIN_SEPARATE_AUTHORIZATION_UNITS=YES"
echo

echo "=== ROUTE IMPLEMENTATION BOUNDARY ==="
echo "ROUTE_MAY_IMPORT_PRODUCTION_EXECUTION_ENTRY_POINT=YES"
echo "ROUTE_MAY_IMPORT_DURABLE_READERS=YES"
echo "ROUTE_MAY_IMPORT_APPROVAL_COMPILER=YES"
echo "ROUTE_MUST_NOT_STATICALLY_IMPORT_EXECUTION_APPROVAL_GATE=YES"
echo "ROUTE_MUST_REQUIRE_APPROVAL_EVALUATOR_DEPENDENCY=YES"
echo "ROUTE_MUST_REQUIRE_OR_INJECT_EXECUTION_EFFECTS_WITHOUT_REAL_GIT_IN_TESTS=YES"
echo "ROUTE_MUST_REJECT_CLIENT_AUTHORITY_FIELDS=YES"
echo "ROUTE_MUST_REMAIN_UNMOUNTED=YES"
echo

echo "=== AUTHORIZATION DETERMINATION ==="
echo "NEW_PREEXISTING_RUNTIME_REPAIR_UNIT_REQUIRED=NO"
echo "NEW_RUNTIME_REPAIR_AUTHORIZATION_REQUIRED_FOR_UNMOUNTED_ROUTE=NO"
echo "PRIOR_UNMOUNTED_ROUTE_AUTHORIZATION_SCOPE_EXPANDED=NO"
echo "ROUTE_SCOPE_REDUCED_BY_REMOVING_STATIC_APPROVAL_GATE_BINDING=YES"
echo "PRODUCTION_APPROVAL_GATE_BINDING_NOT_IMPLEMENTED=YES"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo

echo "=== FAILURE CONTAINMENT ==="
echo "FAILED_TEMP_RUNTIME_HYPOTHESES_REUSED=NO"
echo "APPROVAL_GATE_SOURCE_EDIT=NO"
echo "EXECUTION_SWITCH_SOURCE_EDIT=NO"
echo "EXECUTION_REGISTRY_SOURCE_EDIT=NO"
echo "ROUTE_IMPLEMENTATION_APPLIED=NO"
echo "ROUTE_MOUNT_APPLIED=NO"
echo "GIT_EFFECT_CHANGE=NO"
echo "GENERIC_CADE_CHANGE=NO"
echo "SHELL_OR_MUTATION_AUTHORITY_CHANGE=NO"
echo "SCHEDULER_OR_AUTONOMY_CHANGE=NO"
echo

echo "=== RESULT ==="
echo "EXACT_MINIMUM_RUNTIME_OWNER_CLASSIFIED=YES"
echo "MINIMUM_SAFE_MODEL=UNMOUNTED_ROUTE_WITH_REQUIRED_INJECTED_APPROVAL_EVALUATOR"
echo "CORRIDOR_6_STATUS=ACTIVE_READY_TO_RESUME_BOUNDED_UNMOUNTED_ROUTE_IMPLEMENTATION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=RESUME_UNMOUNTED_ROUTE_IMPLEMENTATION_WITH_NO_STATIC_APPROVAL_GATE_IMPORT_AND_NO_PRODUCTION_BINDING"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
