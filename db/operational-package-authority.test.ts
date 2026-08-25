import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  getOperationalPackageForProject,
  selectOperationalPackageForProject,
} from "./operational-package-authority";

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

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      PRIMARY KEY (package_id, package_version)
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
  `);

  return db;
}

function seed(
  db: Database.Database,
  {
    projectId = "hq",
    packageId = "pkg-1",
    version = 1,
    status = "canonical_approved",
    projection = true,
  }: {
    projectId?: string;
    packageId?: string;
    version?: number;
    status?: string;
    projection?: boolean;
  } = {},
): void {
  db.prepare(`
    INSERT OR IGNORE INTO project_registry (
      project_id,
      display_name
    ) VALUES (?, ?)
  `).run(projectId, projectId);

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES (?, ?, ?, ?)
  `).run(packageId, version, projectId, status);

  if (projection) {
    db.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id
      ) VALUES (?, ?, ?)
    `).run(packageId, version, projectId);
  }
}

function testReadNullWhenUnselected(): void {
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

function testValidExactBinding(): void {
  const db = createDb();

  try {
    seed(db);

    const result = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.equal(result.project_id, "hq");
    assert.equal(result.package_id, "pkg-1");
    assert.equal(result.package_version, 1);
  } finally {
    db.close();
  }
}

function testWrongProjectRejected(): void {
  const db = createDb();

  try {
    seed(db);
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('other', 'Other')
    `).run();

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "other",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testNonApprovedRejected(): void {
  const db = createDb();

  try {
    seed(db, { status: "draft" });

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testMissingProjectionRejected(): void {
  const db = createDb();

  try {
    seed(db, { projection: false });

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testSameBindingIdempotent(): void {
  const db = createDb();

  try {
    seed(db);

    const first = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    const second = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.deepEqual(second, first);
  } finally {
    db.close();
  }
}

function testExplicitReplacement(): void {
  const db = createDb();

  try {
    seed(db, {
      packageId: "pkg-1",
      version: 1,
    });

    seed(db, {
      packageId: "pkg-2",
      version: 1,
    });

    selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    const replacement =
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-2",
        package_version: 1,
      });

    assert.equal(replacement.package_id, "pkg-2");

    const count = db.prepare(`
      SELECT COUNT(*) AS count
      FROM operational_package_authority
      WHERE project_id = 'hq'
    `).get() as { count: number };

    assert.equal(count.count, 1);
  } finally {
    db.close();
  }
}

function testSuccessorDoesNotAutoActivate(): void {
  const db = createDb();

  try {
    seed(db, {
      packageId: "pkg-1",
      version: 1,
    });

    selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    seed(db, {
      packageId: "pkg-1",
      version: 2,
    });

    const current =
      getOperationalPackageForProject(db, "hq");

    assert.ok(current);
    assert.equal(current.package_version, 1);
  } finally {
    db.close();
  }
}

testReadNullWhenUnselected();
testValidExactBinding();
testWrongProjectRejected();
testNonApprovedRejected();
testMissingProjectionRejected();
testSameBindingIdempotent();
testExplicitReplacement();
testSuccessorDoesNotAutoActivate();

console.log(
  "Operational Package Authority targeted tests passed.",
);
