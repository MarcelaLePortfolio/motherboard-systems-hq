import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  listGovernanceExecutionReconciliationEntries,
  persistGovernanceExecutionReconciliationEntry,
} from "./governance-execution-reconciliation-persistence";

const HEAD =
  "1111111111111111111111111111111111111111";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_execution_approvals (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      status TEXT NOT NULL
    );

    CREATE TABLE governance_execution_scopes (
      approval_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      repo_path TEXT NOT NULL,
      expected_head TEXT NOT NULL,
      branch TEXT NOT NULL,
      allowed_paths TEXT NOT NULL,
      forbidden_paths TEXT NOT NULL,
      scope_constraints TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY
    );

    INSERT INTO governance_envelopes VALUES ('e1');

    INSERT INTO governance_execution_approvals
    VALUES ('a1', 'e1', 'p1', 1, 'approved');

    INSERT INTO governance_execution_scopes
    VALUES (
      'a1',
      'e1',
      'p1',
      1,
      '/tmp/repo',
      '${HEAD}',
      'feature/test',
      '["server/example.ts"]',
      '[".env"]',
      'bounded'
    );
  `);

  return db;
}

function base(overrides: Record<string, unknown> = {}) {
  return {
    execution_id: "x1",
    stage: "EXECUTION_STARTED" as const,
    project_id: "hq",
    package_id: "p1",
    package_version: 1,
    delegation_id: "d1",
    validation_result_id: "v1",
    envelope_gate_id: "g1",
    approval_id: "a1",
    envelope_id: "e1",
    repo_path: "/tmp/repo",
    expected_head: HEAD,
    branch: "feature/test",
    allowed_paths: ["server/example.ts"],
    forbidden_paths: [".env"],
    scope_constraints: "bounded",
    commit_requested: true,
    push_requested: true,
    local_effect_status: "none" as const,
    remote_effect_status: "none" as const,
    evidence: null,
    ...overrides,
  };
}

test("persists ordered immutable stages", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "COMMIT_CONFIRMED",
      local_effect_status: "confirmed",
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "PUSH_CONFIRMED",
      local_effect_status: "confirmed",
      remote_effect_status: "confirmed",
    }) as any,
  );

  assert.deepEqual(
    listGovernanceExecutionReconciliationEntries(
      db,
      "x1",
    ).map((entry) => entry.stage),
    [
      "EXECUTION_STARTED",
      "COMMIT_CONFIRMED",
      "PUSH_CONFIRMED",
    ],
  );
});

test("rejects duplicate stages", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  assert.throws(
    () =>
      persistGovernanceExecutionReconciliationEntry(
        db,
        base(),
      ),
    /stage already exists/,
  );
});

test("rejects scope drift", () => {
  const db = createDb();

  assert.throws(
    () =>
      persistGovernanceExecutionReconciliationEntry(
        db,
        base({
          allowed_paths: ["server/other.ts"],
        }) as any,
      ),
    /scope snapshot does not match/,
  );
});

test("preserves unknown effect state on failure", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base(),
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "EXECUTION_FAILED_CLOSED",
      local_effect_status: "unknown",
      remote_effect_status: "none",
    }) as any,
  );

  const entries =
    listGovernanceExecutionReconciliationEntries(
      db,
      "x1",
    );

  assert.equal(
    entries[1].local_effect_status,
    "unknown",
  );
});
