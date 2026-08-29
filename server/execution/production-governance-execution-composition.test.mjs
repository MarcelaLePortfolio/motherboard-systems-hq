import assert from "node:assert/strict";
import test from "node:test";

import sqlite from "../../db/client.ts";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { executeGovernedLocalCommit } from "./cade-governed-commit-adapter.ts";
import { executeGovernedRemotePush } from "./cade-governed-push-adapter.ts";
import {
  createProductionGovernanceExecutionRouter,
  productionGovernanceExecutionComposition,
  productionGovernanceExecutionDependencies,
} from "./production-governance-execution-composition.mjs";

test("binds the existing shared database client", () => {
  assert.equal(productionGovernanceExecutionDependencies.db, sqlite);
});

test("binds the existing approval evaluator", () => {
  assert.equal(
    productionGovernanceExecutionDependencies.evaluate_approval,
    evaluateExecutionApproval,
  );
});

test("binds the existing governed commit and push adapters", () => {
  assert.equal(
    productionGovernanceExecutionDependencies.execute_commit,
    executeGovernedLocalCommit,
  );
  assert.equal(
    productionGovernanceExecutionDependencies.execute_push,
    executeGovernedRemotePush,
  );
});

test("constructs the reachable governed workflow without authorizing production execution", () => {
  const router = createProductionGovernanceExecutionRouter();

  assert.ok(router);
  assert.equal(typeof router.use, "function");
  assert.deepEqual(productionGovernanceExecutionComposition, {
    route_mounted: true,
    execution_route_reachable: true,
    execution_approval_route_reachable: true,
    execution_scope_route_reachable: true,
    production_execution_authorized: false,
    new_authority_introduced: false,
  });
});
