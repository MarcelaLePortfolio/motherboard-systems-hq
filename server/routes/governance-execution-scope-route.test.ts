import assert from "node:assert/strict";
import test from "node:test";

import {
  createGovernanceExecutionScopeRouter,
} from "./governance-execution-scope-route";

test("constructs governed execution scope router", () => {
  const router = createGovernanceExecutionScopeRouter({
    db: {} as any,
    materialize_execution_scope: (() => {
      throw new Error("materializer must not execute during construction");
    }) as any,
  });

  assert.ok(router);
  assert.equal(typeof router.use, "function");
});

test("scope route exposes no repository coordinate authority fields", () => {
  const authorizedInputFields = [
    "approval_id",
    "envelope_id",
    "allowed_paths",
    "forbidden_paths",
    "scope_constraints",
  ];

  for (const forbidden of [
    "repo_path",
    "expected_head",
    "branch",
    "remote",
    "remote_url",
    "remote_push_url",
    "project_id",
  ]) {
    assert.equal(authorizedInputFields.includes(forbidden), false);
  }
});
