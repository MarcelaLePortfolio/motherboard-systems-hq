import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "./mission-read-repository";
import { getOperationalPackageForProject } from "./operational-package-authority";

function createDb(): Database.Database {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE project_registry (
      project_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX
      idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages (
      project_id,
      package_id,
      package_version
    );

    CREATE TABLE operational_package_authority (
      project_id TEXT PRIMARY KEY NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      selected_at TEXT NOT NULL,
      FOREIGN KEY (project_id)
        REFERENCES project_registry(project_id),
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(
          project_id,
          package_id,
          package_version
        )
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      validation_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      gate_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      lifecycle_state TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL
    );
  `);

  return db;
}

function seedSelectedPackage(
  db: Database.Database,
  version = 1,
): void {
  db.prepare(`
    INSERT INTO project_registry (
      project_id,
      display_name
    ) VALUES ('hq', 'HQ')
  `).run();

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES ('pkg-1', ?, 'hq', 'canonical_approved')
  `).run(version);

  db.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    ) VALUES ('pkg-1', ?, 'hq', 'conversation-1', 'Outcome')
  `).run(version);

  db.prepare(`
    INSERT INTO operational_package_authority (
      project_id,
      package_id,
      package_version,
      selected_at
    ) VALUES ('hq', 'pkg-1', ?, '2026-08-25T00:00:00.000Z')
  `).run(version);
}

async function testSelectedExactIdentity(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.project_id, "hq");
    assert.equal(mission.package_id, "pkg-1");
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testMissingProjectionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 1, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO operational_package_authority (
        project_id,
        package_id,
        package_version,
        selected_at
      ) VALUES ('hq', 'pkg-1', 1, '2026-08-25T00:00:00.000Z')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongProjectFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "other",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongVersionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 2,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testNewerVersionDoesNotAutoActivate(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 2, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome
      ) VALUES ('pkg-1', 2, 'hq', 'conversation-2', 'Newer outcome')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);
    assert.equal(authority.package_version, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testUnselectedProjectHasNoAuthority(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    assert.equal(
      getOperationalPackageForProject(db, "hq"),
      null,
    );
  } finally {
    db.close();
  }
}

await testSelectedExactIdentity();
await testMissingProjectionFailsClosed();
await testWrongProjectFailsClosed();
await testWrongVersionFailsClosed();
await testNewerVersionDoesNotAutoActivate();
await testUnselectedProjectHasNoAuthority();

console.log(
  "Project-scoped Mission Read handoff targeted tests passed.",
);
