import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

test("project-scoped Delegation persistence binds and stores project_id", () => {
  const db = new Database(":memory:");

  db.exec(`
    PRAGMA foreign_keys = ON;

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages(project_id, package_id, package_version);

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
    );

    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES (
      'pkg-direct-persistence',
      1,
      'hq',
      'canonical_approved'
    );
  `);

  const insert = db.prepare(`
    INSERT INTO governance_delegations (
      delegation_id,
      project_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    ) VALUES (
      @delegation_id,
      @project_id,
      @package_id,
      @package_version,
      @authorization_state,
      @authorization_timestamp,
      @delegated_by,
      @created_at
    )
  `);

  insert.run({
    delegation_id: "delegation-direct-persistence",
    project_id: "hq",
    package_id: "pkg-direct-persistence",
    package_version: 1,
    authorization_state: "AUTHORIZED",
    authorization_timestamp: "2026-08-25T18:05:00.000Z",
    delegated_by: "marcela",
    created_at: "2026-08-25T18:05:00.000Z",
  });

  const persisted = db.prepare(`
    SELECT project_id, package_id, package_version
    FROM governance_delegations
    WHERE delegation_id = 'delegation-direct-persistence'
  `).get() as {
    project_id: string;
    package_id: string;
    package_version: number;
  };

  assert.deepEqual(persisted, {
    project_id: "hq",
    package_id: "pkg-direct-persistence",
    package_version: 1,
  });

  assert.throws(
    () =>
      insert.run({
        delegation_id: "delegation-cross-project",
        project_id: "other",
        package_id: "pkg-direct-persistence",
        package_version: 1,
        authorization_state: "AUTHORIZED",
        authorization_timestamp: "2026-08-25T18:05:00.000Z",
        delegated_by: "marcela",
        created_at: "2026-08-25T18:05:00.000Z",
      }),
    /FOREIGN KEY constraint failed/,
  );

  db.close();
});
