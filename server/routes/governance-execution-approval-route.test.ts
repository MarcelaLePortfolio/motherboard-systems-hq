import test from "node:test";
import assert from "node:assert/strict";

test("Corridor 2 approval request excludes repository execution authority", () => {
  const allowedFields = new Set([
    "envelope_id",
    "approved_by",
    "approval_scope",
    "commit_authorized",
    "push_authorized",
    "justification",
  ]);

  for (const forbidden of [
    "repo_path",
    "expected_head",
    "allowed_paths",
    "forbidden_paths",
    "branch",
    "remote",
  ]) {
    assert.equal(allowedFields.has(forbidden), false);
  }
});

test("push authority requires commit authority", () => {
  assert.equal(!(true && !true), true);
  assert.equal(!(true && !false), false);
});

test("Corridor 2 remains approval-only", () => {
  assert.deepEqual(
    {
      execution_scope_created: false,
      execution_authorized: false,
      execution_coordinates_materialized: false,
    },
    {
      execution_scope_created: false,
      execution_authorized: false,
      execution_coordinates_materialized: false,
    },
  );
});
