import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  listGovernanceExecutionReconciliationEntries,
  loadCertifiedGovernedLocalCommitProof,
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


test("certifies terminal commit-only reconciliation as durable local commit proof", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      push_requested: false,
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "COMMIT_CONFIRMED",
      push_requested: false,
      local_effect_status: "confirmed",
      remote_effect_status: "none",
      evidence: {
        pre_head: HEAD,
        post_head: "2222222222222222222222222222222222222222",
        branch: "feature/test",
      },
    }) as any,
  );

  assert.deepEqual(
    loadCertifiedGovernedLocalCommitProof(db, "x1"),
    {
      status: "ok",
      pre_head: HEAD,
      post_head: "2222222222222222222222222222222222222222",
      branch: "feature/test",
      approval_id: "a1",
      envelope_id: "e1",
      execution_id: "x1",
      project_id: "hq",
      package_id: "p1",
      package_version: 1,
      delegation_id: "d1",
      validation_result_id: "v1",
      envelope_gate_id: "g1",
      repo_path: "/tmp/repo",
      expected_head: HEAD,
      remote_effect: false,
      push_effect: false,
    },
  );
});

test("refuses to certify non-terminal commit-plus-push lineage", () => {
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
      evidence: {
        pre_head: "1111111111111111111111111111111111111111",
        post_head: "2222222222222222222222222222222222222222",
        branch: "feature/test",
      },
    }) as any,
  );

  assert.throws(
    () => loadCertifiedGovernedLocalCommitProof(db, "x1"),
    /commit_requested=true and push_requested=false/,
  );
});

test("refuses to certify failed reconciliation lineage", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      push_requested: false,
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "EXECUTION_FAILED_CLOSED",
      push_requested: false,
      local_effect_status: "unknown",
      remote_effect_status: "none",
    }) as any,
  );

  assert.throws(
    () => loadCertifiedGovernedLocalCommitProof(db, "x1"),
    /terminal commit-only reconciliation lineage/,
  );
});

test("persists certified prior-commit push-only lineage without a new local effect", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      execution_id: "push-only-x1",
      commit_requested: false,
      push_requested: true,
      prior_commit_execution_id: "prior-x1",
      local_effect_status: "none",
      remote_effect_status: "none",
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      execution_id: "push-only-x1",
      stage: "PUSH_CONFIRMED",
      commit_requested: false,
      push_requested: true,
      prior_commit_execution_id: "prior-x1",
      local_effect_status: "none",
      remote_effect_status: "confirmed",
    }) as any,
  );

  const entries =
    listGovernanceExecutionReconciliationEntries(
      db,
      "push-only-x1",
    );

  assert.deepEqual(
    entries.map((entry) => ({
      stage: entry.stage,
      prior_commit_execution_id:
        entry.prior_commit_execution_id,
      local_effect_status:
        entry.local_effect_status,
      remote_effect_status:
        entry.remote_effect_status,
    })),
    [
      {
        stage: "EXECUTION_STARTED",
        prior_commit_execution_id: "prior-x1",
        local_effect_status: "none",
        remote_effect_status: "none",
      },
      {
        stage: "PUSH_CONFIRMED",
        prior_commit_execution_id: "prior-x1",
        local_effect_status: "none",
        remote_effect_status: "confirmed",
      },
    ],
  );
});

test("rejects push-only reconciliation without prior commit execution reference", () => {
  const db = createDb();

  assert.throws(
    () =>
      persistGovernanceExecutionReconciliationEntry(
        db,
        base({
          execution_id: "push-only-no-proof",
          commit_requested: false,
          push_requested: true,
          local_effect_status: "none",
          remote_effect_status: "none",
        }) as any,
      ),
    /requires prior_commit_execution_id/,
  );
});

test("certified local commit proof requires pre_head to match durable expected_head", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      push_requested: false,
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "COMMIT_CONFIRMED",
      push_requested: false,
      local_effect_status: "confirmed",
      remote_effect_status: "none",
      evidence: {
        pre_head: "3333333333333333333333333333333333333333",
        post_head: "2222222222222222222222222222222222222222",
        branch: "feature/test",
      },
    }) as any,
  );

  assert.throws(
    () => loadCertifiedGovernedLocalCommitProof(db, "x1"),
    /pre_head does not match durable reconciliation expected_head/,
  );
});

test("refuses to certify malformed COMMIT_CONFIRMED evidence", () => {
  const db = createDb();

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      push_requested: false,
    }) as any,
  );

  persistGovernanceExecutionReconciliationEntry(
    db,
    base({
      stage: "COMMIT_CONFIRMED",
      push_requested: false,
      local_effect_status: "confirmed",
      remote_effect_status: "none",
      evidence: {
        pre_head: "not-a-head",
        post_head: "2222222222222222222222222222222222222222",
        branch: "feature/test",
      },
    }) as any,
  );

  assert.throws(
    () => loadCertifiedGovernedLocalCommitProof(db, "x1"),
    /evidence is incomplete or invalid/,
  );
});
