import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  ensureGovernanceExecutionApprovalTable,
  loadGovernanceExecutionApproval,
  persistGovernanceExecutionApproval,
} from "./governance-execution-approval-persistence";

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

  ensureGovernanceExecutionApprovalTable(db);
  return db;
}

test("persists and reads exact approved commit scope", () => {
  const db = fixture();

  const persisted = persistGovernanceExecutionApproval(db, {
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
    issued_at: new Date(Date.now() - 1000).toISOString(),
  });

  assert.equal(persisted.status, "approved");
  assert.equal(persisted.commit_authorized, true);
  assert.equal(persisted.push_authorized, false);

  const loaded = loadGovernanceExecutionApproval(
    db,
    "approval-1",
    "env-1",
  );

  assert.equal(loaded.approval_id, "approval-1");
  assert.equal(loaded.envelope_id, "env-1");
});

test("rejects package lineage mismatch", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionApproval(db, {
      approval_id: "approval-2",
      envelope_id: "env-1",
      package_id: "pkg-other",
      package_version: 1,
      approved_by: "user",
      approval_scope: "governed_version_control_commit",
      commit_authorized: true,
      push_authorized: false,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
    }),
  );
});

test("rejects push without commit authority", () => {
  const db = fixture();

  assert.throws(() =>
    persistGovernanceExecutionApproval(db, {
      approval_id: "approval-3",
      envelope_id: "env-1",
      package_id: "pkg-1",
      package_version: 1,
      approved_by: "user",
      approval_scope: "governed_version_control_push",
      commit_authorized: false,
      push_authorized: true,
      remote: "origin",
      branch: "feature/test",
      issued_at: new Date().toISOString(),
    }),
  );
});

test("fails closed on envelope replay", () => {
  const db = fixture();

  persistGovernanceExecutionApproval(db, {
    approval_id: "approval-4",
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

  assert.throws(() =>
    loadGovernanceExecutionApproval(
      db,
      "approval-4",
      "env-other",
    ),
  );
});
