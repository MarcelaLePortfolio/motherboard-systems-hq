import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  ensureGovernanceExecutionApprovalTable,
  persistGovernanceExecutionApproval,
} from "./governance-execution-approval-persistence";
import {
  ensureGovernanceExecutionScopeTable,
  loadGovernanceExecutionScope,
  persistGovernanceExecutionScope,
} from "./governance-execution-scope-persistence";

function fixture() {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version)
    );
  `);

  db.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version
    ) VALUES (?, ?)
  `).run("pkg-1", 1);

  db.prepare(`
    INSERT INTO governance_envelopes (
      envelope_id,
      package_id,
      package_version
    ) VALUES (?, ?, ?)
  `).run("env-1", "pkg-1", 1);

  db.prepare(`
    INSERT INTO governance_envelopes (
      envelope_id,
      package_id,
      package_version
    ) VALUES (?, ?, ?)
  `).run("env-2", "pkg-1", 1);

  ensureGovernanceExecutionApprovalTable(db);

  persistGovernanceExecutionApproval(db, {
    approval_id: "approval-1",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/test",
    issued_at: new Date().toISOString(),
  });

  persistGovernanceExecutionApproval(db, {
    approval_id: "approval-2",
    envelope_id: "env-2",
    package_id: "pkg-1",
    package_version: 1,
    approved_by: "user",
    approval_scope: "governed_version_control_commit",
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/other",
    issued_at: new Date().toISOString(),
  });

  ensureGovernanceExecutionScopeTable(db);

  return db;
}

test("persists exact execution target and mutation scope", () => {
  const db = fixture();

  const persisted = persistGovernanceExecutionScope(db, {
    approval_id: "approval-1",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    repo_path: "/workspace/motherboard-systems-hq",
    expected_head: "a".repeat(40),
    branch: "feature/test",
    allowed_paths: [
      "db/governance-execution-scope-persistence.ts",
      "db/governance-execution-scope-persistence.test.ts",
    ],
    forbidden_paths: ["server/index.ts"],
    scope_constraints: "Bounded Corridor 6 durability unit only.",
  });

  assert.equal(
    persisted.repo_path,
    "/workspace/motherboard-systems-hq",
  );
  assert.equal(persisted.expected_head, "a".repeat(40));
  assert.equal(persisted.branch, "feature/test");
  assert.deepEqual(persisted.allowed_paths, [
    "db/governance-execution-scope-persistence.ts",
    "db/governance-execution-scope-persistence.test.ts",
  ]);
  assert.deepEqual(persisted.forbidden_paths, ["server/index.ts"]);
});

test("fails closed on package lineage mismatch", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionScope(db, {
      approval_id: "approval-1",
      envelope_id: "env-1",
      package_id: "pkg-other",
      package_version: 1,
      repo_path: "/workspace/motherboard-systems-hq",
      expected_head: "b".repeat(40),
      branch: "feature/test",
      allowed_paths: ["db/example.ts"],
      forbidden_paths: [],
      scope_constraints: "Bounded scope.",
    }),
  );
});

test("rejects invalid expected head and empty allowed paths", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionScope(db, {
      approval_id: "approval-1",
      envelope_id: "env-1",
      package_id: "pkg-1",
      package_version: 1,
      repo_path: "/workspace/motherboard-systems-hq",
      expected_head: "not-a-sha",
      branch: "feature/test",
      allowed_paths: ["db/example.ts"],
      forbidden_paths: [],
      scope_constraints: "Bounded scope.",
    }),
  );

  assert.throws(() =>
    persistGovernanceExecutionScope(db, {
      approval_id: "approval-1",
      envelope_id: "env-1",
      package_id: "pkg-1",
      package_version: 1,
      repo_path: "/workspace/motherboard-systems-hq",
      expected_head: "c".repeat(40),
      branch: "feature/test",
      allowed_paths: [],
      forbidden_paths: [],
      scope_constraints: "Bounded scope.",
    }),
  );
});

test("prevents replay across envelopes and approvals", () => {
  const db = fixture();

  persistGovernanceExecutionScope(db, {
    approval_id: "approval-1",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    repo_path: "/workspace/motherboard-systems-hq",
    expected_head: "d".repeat(40),
    branch: "feature/test",
    allowed_paths: ["db/example.ts"],
    forbidden_paths: [],
    scope_constraints: "Bounded scope.",
  });

  assert.throws(() =>
    loadGovernanceExecutionScope(
      db,
      "approval-1",
      "env-2",
    ),
  );

  assert.throws(() =>
    loadGovernanceExecutionScope(
      db,
      "approval-2",
      "env-1",
    ),
  );
});

test("rejects a second durable scope for the same envelope", () => {
  const db = fixture();

  persistGovernanceExecutionScope(db, {
    approval_id: "approval-1",
    envelope_id: "env-1",
    package_id: "pkg-1",
    package_version: 1,
    repo_path: "/workspace/motherboard-systems-hq",
    expected_head: "e".repeat(40),
    branch: "feature/test",
    allowed_paths: ["db/example.ts"],
    forbidden_paths: [],
    scope_constraints: "Bounded scope.",
  });

  assert.throws(() =>
    persistGovernanceExecutionScope(db, {
      approval_id: "approval-1",
      envelope_id: "env-1",
      package_id: "pkg-1",
      package_version: 1,
      repo_path: "/workspace/other",
      expected_head: "f".repeat(40),
      branch: "feature/other",
      allowed_paths: ["db/other.ts"],
      forbidden_paths: [],
      scope_constraints: "Different scope.",
    }),
  );
});
