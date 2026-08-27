import test from "node:test";
import assert from "node:assert/strict";

import {
  compilePersistedExecutionApproval,
} from "./compile-persisted-execution-approval.mjs";

test("compiles persisted approval into existing gate shape", () => {
  const compiled = compilePersistedExecutionApproval({
    approval_id: "approval-1",
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: new Date().toISOString(),
    expires_at: null,
    justification: "explicit user approval",
    status: "approved",
  });

  assert.deepEqual(
    compiled.version_control_authorization,
    {
      commit_authorized: true,
      push_authorized: false,
      remote: "origin",
      branch: "feature/test",
    },
  );

  assert.equal(compiled.mutation_authorized, false);
  assert.equal(compiled.shell_execution_authorized, false);
  assert.equal(compiled.autonomous_execution_authorized, false);
});

test("rejects invalid approval state", () => {
  assert.throws(() =>
    compilePersistedExecutionApproval({
      approval_id: "approval-2",
      approved_by: "user",
      status: "approval_required",
    }),
  );
});

test("rejects push without commit", () => {
  assert.throws(() =>
    compilePersistedExecutionApproval({
      approval_id: "approval-3",
      approved_by: "user",
      approval_scope: "governed_version_control_push",
      commit_authorized: false,
      push_authorized: true,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
      status: "approved",
    }),
  );
});
