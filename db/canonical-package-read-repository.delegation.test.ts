import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import Database from "better-sqlite3";

import {
  createCanonicalPackageReadRepository,
} from "./canonical-package-read-repository";

function createFixtureDatabase(): string {
  const dir = fs.mkdtempSync(
    path.join(os.tmpdir(), "executive-delegation-read-"),
  );
  const databasePath = path.join(dir, "fixture.db");
  const db = new Database(databasePath);

  db.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
      lineage_id TEXT NOT NULL,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  `);

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      summary_id,
      draft_package_id,
      draft_revision_id,
      lineage_id,
      project_id,
      conversation_id,
      approved_interpretation,
      approved_work,
      approved_artifacts,
      approved_scope,
      approved_constraints,
      approved_expected_outcome,
      approval_actor,
      approval_timestamp,
      status,
      created_at
    ) VALUES (
      'pkg-1',
      1,
      'summary-1',
      'draft-1',
      'revision-1',
      'lineage-1',
      'hq',
      'conversation-1',
      'Approved interpretation',
      'Approved work',
      'Approved artifacts',
      'Approved scope',
      'Approved constraints',
      'Approved outcome',
      'marcela',
      '2026-09-22T20:00:00.000Z',
      'canonical_approved',
      '2026-09-22T20:00:00.000Z'
    )
  `).run();

  db.close();
  return databasePath;
}

function insertDelegation(
  databasePath: string,
  delegationId: string,
  authorizationState: string,
  createdAt: string,
): void {
  const db = new Database(databasePath);

  db.prepare(`
    INSERT INTO governance_delegations (
      delegation_id,
      project_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    ) VALUES (?, 'hq', 'pkg-1', 1, ?, ?, 'marcela', ?)
  `).run(
    delegationId,
    authorizationState,
    createdAt,
    createdAt,
  );

  db.close();
}

test("no matching delegation reads as awaiting_delegation", () => {
  const databasePath = createFixtureDatabase();
  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");
    assert.ok(pkg);
    assert.equal(pkg.delegation.state, "awaiting_delegation");
  } finally {
    repository.close();
  }
});

test("one AUTHORIZED delegation reads as delegated with persisted identity", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(
    databasePath,
    "delegation-1",
    "AUTHORIZED",
    "2026-09-22T20:05:00.000Z",
  );

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");
    assert.ok(pkg);

    assert.deepEqual(pkg.delegation, {
      state: "delegated",
      delegation_id: "delegation-1",
      authorization_state: "AUTHORIZED",
      authorization_timestamp: "2026-09-22T20:05:00.000Z",
      delegated_by: "marcela",
    });
  } finally {
    repository.close();
  }
});

test("multiple matching delegations fail closed as ambiguous", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(
    databasePath,
    "delegation-1",
    "AUTHORIZED",
    "2026-09-22T20:05:00.000Z",
  );

  insertDelegation(
    databasePath,
    "delegation-2",
    "AUTHORIZED",
    "2026-09-22T20:06:00.000Z",
  );

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");
    assert.ok(pkg);
    assert.equal(pkg.delegation.state, "ambiguous");
  } finally {
    repository.close();
  }
});

test("non-AUTHORIZED matching delegation fails closed as ambiguous", () => {
  const databasePath = createFixtureDatabase();

  insertDelegation(
    databasePath,
    "delegation-1",
    "PENDING",
    "2026-09-22T20:05:00.000Z",
  );

  const repository =
    createCanonicalPackageReadRepository(databasePath);

  try {
    const [pkg] = repository.listByProject("hq");
    assert.ok(pkg);
    assert.equal(pkg.delegation.state, "ambiguous");
  } finally {
    repository.close();
  }
});
