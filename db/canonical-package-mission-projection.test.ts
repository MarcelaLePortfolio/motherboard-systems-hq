import assert from "node:assert/strict";
import test from "node:test";

import Database from "better-sqlite3";

import {
  projectCanonicalPackageToMissionPackage,
} from "./canonical-package-mission-projection";

function createFixture() {
  const sqlite = new Database(":memory:");

  sqlite.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_expected_outcome TEXT,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      requested_outcome TEXT,
      scope TEXT,
      containment TEXT,
      constraints TEXT,
      success_criteria TEXT,
      context TEXT,
      style_presentation_intent TEXT,
      exclusions TEXT,
      created_at TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  return sqlite;
}

function insertCanonical(
  sqlite: Database.Database,
  {
    package_id = "pkg-handoff",
    package_version = 1,
    project_id = "hq",
    conversation_id = "conversation-handoff",
    approved_expected_outcome = "Approved mission outcome",
    status = "canonical_approved",
    created_at = "2026-08-25T18:30:00.000Z",
  } = {},
) {
  sqlite.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      approved_expected_outcome,
      status,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    package_id,
    package_version,
    project_id,
    conversation_id,
    approved_expected_outcome,
    status,
    created_at,
  );
}

test("projects exact approved Canonical Package identity", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  const result = projectCanonicalPackageToMissionPackage(
    sqlite,
    {
      project_id: "hq",
      package_id: "pkg-handoff",
      package_version: 1,
    },
  );

  assert.equal(result.idempotent, false);
  assert.equal(result.project_id, "hq");
  assert.equal(result.package_id, "pkg-handoff");
  assert.equal(result.package_version, 1);
  assert.equal(result.conversation_id, "conversation-handoff");
  assert.equal(result.requested_outcome, "Approved mission outcome");
  assert.equal(result.delegation_authorized, false);
  assert.equal(result.execution_authorized, false);

  const row = sqlite.prepare(`
    SELECT *
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as Record<string, unknown>;

  assert.equal(row.project_id, "hq");
  assert.equal(row.conversation_id, "conversation-handoff");
  assert.equal(row.requested_outcome, "Approved mission outcome");
  assert.equal(row.created_at, "2026-08-25T18:30:00.000Z");
  assert.equal(row.scope, null);
  assert.equal(row.containment, null);
  assert.equal(row.constraints, null);
  assert.equal(row.success_criteria, null);
  assert.equal(row.context, null);
  assert.equal(row.style_presentation_intent, null);
  assert.equal(row.exclusions, null);

  sqlite.close();
});

test("exact existing projection is idempotent", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  const input = {
    project_id: "hq",
    package_id: "pkg-handoff",
    package_version: 1,
  };

  projectCanonicalPackageToMissionPackage(sqlite, input);
  const second =
    projectCanonicalPackageToMissionPackage(sqlite, input);

  assert.equal(second.idempotent, true);

  const count = sqlite.prepare(`
    SELECT COUNT(*) AS count
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as { count: number };

  assert.equal(count.count, 1);
  sqlite.close();
});

test("missing Canonical Package fails closed", () => {
  const sqlite = createFixture();

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-missing",
        package_version: 1,
      }),
    /source was not found/,
  );

  sqlite.close();
});

test("non-approved Canonical Package fails closed", () => {
  const sqlite = createFixture();

  insertCanonical(sqlite, {
    status: "draft_non_authoritative",
  });

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-handoff",
        package_version: 1,
      }),
    /canonical_approved/,
  );

  sqlite.close();
});

test("conflicting target fails closed without overwrite", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  sqlite.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    "pkg-handoff",
    1,
    "other-project",
    "legacy-conversation",
    "Legacy outcome",
    "2026-07-01T00:00:00.000Z",
  );

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-handoff",
        package_version: 1,
      }),
    /conflicting identity, semantics, or provenance/,
  );

  const row = sqlite.prepare(`
    SELECT project_id, conversation_id, requested_outcome
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as {
    project_id: string;
    conversation_id: string;
    requested_outcome: string;
  };

  assert.deepEqual(row, {
    project_id: "other-project",
    conversation_id: "legacy-conversation",
    requested_outcome: "Legacy outcome",
  });

  sqlite.close();
});
