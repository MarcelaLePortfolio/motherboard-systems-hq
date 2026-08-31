import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import {
  resolveRegisteredProjectRepository,
} from "./project-registry-read-repository";

function createRegistryDatabase(): Database.Database {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE project_registry (
      project_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL,
      project_root_path TEXT,
      git_repository_reference TEXT,
      registration_status TEXT NOT NULL DEFAULT 'registered',
      availability_status TEXT NOT NULL DEFAULT 'available',
      active_context_eligible INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_opened_at TEXT
    );

    CREATE TABLE active_context (
      singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
      current_project_id TEXT NOT NULL,
      source TEXT NOT NULL DEFAULT 'system',
      action TEXT NOT NULL DEFAULT 'seed',
      updated_at TEXT NOT NULL,
      FOREIGN KEY (current_project_id) REFERENCES project_registry(project_id)
    );
  `);

  return db;
}

function insertProject(
  db: Database.Database,
  {
    projectId,
    projectRootPath,
    gitRepositoryReference,
    registrationStatus = "registered",
    availabilityStatus = "available",
    activeContextEligible = 1,
  }: {
    projectId: string;
    projectRootPath: string;
    gitRepositoryReference: string;
    registrationStatus?: string;
    availabilityStatus?: string;
    activeContextEligible?: number;
  },
): void {
  const timestamp = "2026-08-28T20:56:14.000Z";

  db.prepare(`
    INSERT INTO project_registry (
      project_id,
      display_name,
      project_root_path,
      git_repository_reference,
      registration_status,
      availability_status,
      active_context_eligible,
      created_at,
      updated_at,
      last_opened_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)
  `).run(
    projectId,
    projectId,
    projectRootPath,
    gitRepositoryReference,
    registrationStatus,
    availabilityStatus,
    activeContextEligible,
    timestamp,
    timestamp,
  );
}

function statusCodeOf(error: unknown): number | undefined {
  return error instanceof Error
    ? (error as Error & { statusCode?: number }).statusCode
    : undefined;
}

test(
  "resolves repository identity from canonical project_id without Active Context authority",
  () => {
    const db = createRegistryDatabase();

    try {
      insertProject(db, {
        projectId: "hq",
        projectRootPath: "/repos/motherboard-systems-hq-clean",
        gitRepositoryReference: "/repos/motherboard-systems-hq-clean",
      });

      insertProject(db, {
        projectId: "other",
        projectRootPath: "/repos/other",
        gitRepositoryReference: "/repos/other",
      });

      db.prepare(`
        INSERT INTO active_context (
          singleton_id,
          current_project_id,
          source,
          action,
          updated_at
        ) VALUES (1, ?, 'test', 'test_active_context', ?)
      `).run(
        "other",
        "2026-08-28T20:56:14.000Z",
      );

      assert.deepEqual(
        resolveRegisteredProjectRepository(db, "hq"),
        {
          projectId: "hq",
          projectRootPath: "/repos/motherboard-systems-hq-clean",
          gitRepositoryReference: "/repos/motherboard-systems-hq-clean",
          registrationStatus: "registered",
          availabilityStatus: "available",
        },
      );
    } finally {
      db.close();
    }
  },
);

test("fails closed when project_id is missing", () => {
  const db = createRegistryDatabase();

  try {
    assert.throws(
      () => resolveRegisteredProjectRepository(db, ""),
      (error: unknown) =>
        error instanceof Error &&
        /projectId is required/.test(error.message) &&
        statusCodeOf(error) === 400,
    );
  } finally {
    db.close();
  }
});

test("fails closed for an unknown project_id", () => {
  const db = createRegistryDatabase();

  try {
    assert.throws(
      () => resolveRegisteredProjectRepository(db, "missing"),
      (error: unknown) =>
        error instanceof Error &&
        /not uniquely registered and available/.test(error.message) &&
        statusCodeOf(error) === 404,
    );
  } finally {
    db.close();
  }
});

test("fails closed for an archived project", () => {
  const db = createRegistryDatabase();

  try {
    insertProject(db, {
      projectId: "archived",
      projectRootPath: "/repos/archived",
      gitRepositoryReference: "/repos/archived",
      registrationStatus: "archived",
      availabilityStatus: "unavailable",
      activeContextEligible: 0,
    });

    assert.throws(
      () => resolveRegisteredProjectRepository(db, "archived"),
      (error: unknown) =>
        error instanceof Error &&
        /not uniquely registered and available/.test(error.message) &&
        statusCodeOf(error) === 404,
    );
  } finally {
    db.close();
  }
});

test("fails closed for an unavailable registered project", () => {
  const db = createRegistryDatabase();

  try {
    insertProject(db, {
      projectId: "unavailable",
      projectRootPath: "/repos/unavailable",
      gitRepositoryReference: "/repos/unavailable",
      availabilityStatus: "unavailable",
    });

    assert.throws(
      () => resolveRegisteredProjectRepository(db, "unavailable"),
      (error: unknown) =>
        error instanceof Error &&
        /not uniquely registered and available/.test(error.message) &&
        statusCodeOf(error) === 404,
    );
  } finally {
    db.close();
  }
});

test("fails closed when registered repository identity is incomplete", () => {
  const db = createRegistryDatabase();

  try {
    insertProject(db, {
      projectId: "incomplete",
      projectRootPath: "/repos/incomplete",
      gitRepositoryReference: "",
    });

    assert.throws(
      () => resolveRegisteredProjectRepository(db, "incomplete"),
      (error: unknown) =>
        error instanceof Error &&
        /missing authoritative repository identity/.test(error.message) &&
        statusCodeOf(error) === 409,
    );
  } finally {
    db.close();
  }
});
