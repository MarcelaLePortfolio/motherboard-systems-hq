import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import Database from "better-sqlite3";

const originalCwd = process.cwd();
const modulePath = path.join(originalCwd, "server", "project-registry.mjs");

async function createIsolatedRegistry() {
  const tempRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "project-registry-target-resolution-"),
  );

  fs.mkdirSync(path.join(tempRoot, "db"), { recursive: true });
  fs.mkdirSync(path.join(tempRoot, "projects"), { recursive: true });

  process.chdir(tempRoot);

  const moduleUrl =
    `${pathToFileURL(modulePath).href}?test=${Date.now()}-${Math.random()}`;

  const registry = await import(moduleUrl);

  registry.ensureProjectRegistry();

  const db = new Database(path.join(tempRoot, "db", "main.db"));

  return { tempRoot, db, registry };
}

function insertProject(
  db,
  {
    projectId,
    projectRootPath,
    gitRepositoryReference,
    registrationStatus = "registered",
    availabilityStatus = "available",
    activeContextEligible = 1,
  },
) {
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

async function withRegistry(run) {
  const isolated = await createIsolatedRegistry();

  try {
    await run(isolated);
  } finally {
    isolated.db.close();
    process.chdir(originalCwd);
    fs.rmSync(isolated.tempRoot, {
      recursive: true,
      force: true,
    });
  }
}

test(
  "resolves repository identity from canonical project_id without Active Context authority",
  async () => {
    await withRegistry(async ({ db, registry }) => {
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

      const resolved =
        registry.resolveRegisteredProjectRepository("hq");

      assert.deepEqual(resolved, {
        projectId: "hq",
        projectRootPath: "/repos/motherboard-systems-hq-clean",
        gitRepositoryReference: "/repos/motherboard-systems-hq-clean",
        registrationStatus: "registered",
        availabilityStatus: "available",
      });
    });
  },
);

test("fails closed when project_id is missing", async () => {
  await withRegistry(async ({ registry }) => {
    assert.throws(
      () => registry.resolveRegisteredProjectRepository(""),
      /projectId is required/,
    );
  });
});

test("fails closed for an unknown project_id", async () => {
  await withRegistry(async ({ registry }) => {
    assert.throws(
      () => registry.resolveRegisteredProjectRepository("missing"),
      /not uniquely registered and available/,
    );
  });
});

test("fails closed for an archived project", async () => {
  await withRegistry(async ({ db, registry }) => {
    insertProject(db, {
      projectId: "archived",
      projectRootPath: "/repos/archived",
      gitRepositoryReference: "/repos/archived",
      registrationStatus: "archived",
      availabilityStatus: "unavailable",
      activeContextEligible: 0,
    });

    assert.throws(
      () => registry.resolveRegisteredProjectRepository("archived"),
      /not uniquely registered and available/,
    );
  });
});

test("fails closed for an unavailable registered project", async () => {
  await withRegistry(async ({ db, registry }) => {
    insertProject(db, {
      projectId: "unavailable",
      projectRootPath: "/repos/unavailable",
      gitRepositoryReference: "/repos/unavailable",
      availabilityStatus: "unavailable",
    });

    assert.throws(
      () => registry.resolveRegisteredProjectRepository("unavailable"),
      /not uniquely registered and available/,
    );
  });
});

test(
  "fails closed when registered repository identity is incomplete",
  async () => {
    await withRegistry(async ({ db, registry }) => {
      insertProject(db, {
        projectId: "incomplete",
        projectRootPath: "/repos/incomplete",
        gitRepositoryReference: "",
      });

      assert.throws(
        () => registry.resolveRegisteredProjectRepository("incomplete"),
        /missing authoritative repository identity/,
      );
    });
  },
);
