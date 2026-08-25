#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT OPERATIONAL PACKAGE AUTHORITY PERSISTENCE UNIT ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "AUTHORIZATION_COMMIT=555d0d32"
echo "IMPLEMENTATION_AUTHORIZED=YES"

MIGRATION="drizzle/0011_operational_package_authority.sql"

cat > "${MIGRATION}" << 'SQL'
CREATE TABLE operational_package_authority (
  project_id TEXT PRIMARY KEY NOT NULL,
  package_id TEXT NOT NULL,
  package_version INTEGER NOT NULL,
  selected_at TEXT NOT NULL,
  FOREIGN KEY (project_id)
    REFERENCES project_registry(project_id),
  FOREIGN KEY (project_id, package_id, package_version)
    REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
);
SQL

cat > db/operational-package-authority.ts << 'TS'
import type { Database } from "better-sqlite3";

export interface OperationalPackageAuthority {
  project_id: string;
  package_id: string;
  package_version: number;
  selected_at: string;
}

export interface SelectOperationalPackageInput {
  project_id: string;
  package_id: string;
  package_version: number;
}

function requireText(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`${field} is required.`);
  }
  return normalized;
}

export function getOperationalPackageForProject(
  db: Database,
  projectId: string,
): OperationalPackageAuthority | null {
  const project_id = requireText(projectId, "project_id");

  const row = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      selected_at
    FROM operational_package_authority
    WHERE project_id = ?
  `).get(project_id) as OperationalPackageAuthority | undefined;

  return row ?? null;
}

export function selectOperationalPackageForProject(
  db: Database,
  input: SelectOperationalPackageInput,
): OperationalPackageAuthority {
  const project_id = requireText(input.project_id, "project_id");
  const package_id = requireText(input.package_id, "package_id");

  if (
    !Number.isInteger(input.package_version) ||
    input.package_version < 1
  ) {
    throw new Error("package_version must be a positive integer.");
  }

  const package_version = input.package_version;

  const project = db.prepare(`
    SELECT project_id
    FROM project_registry
    WHERE project_id = ?
  `).get(project_id) as { project_id: string } | undefined;

  if (!project) {
    throw new Error("Operational Package Authority project was not found.");
  }

  const canonical = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      status
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
  `).get(
    project_id,
    package_id,
    package_version,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
        status: string;
      }
    | undefined;

  if (!canonical) {
    throw new Error(
      "Operational Package Authority canonical Package was not found for the exact project/package/version identity.",
    );
  }

  if (canonical.status !== "canonical_approved") {
    throw new Error(
      "Operational Package Authority requires canonical_approved status.",
    );
  }

  const projection = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
      AND project_id = ?
  `).get(
    package_id,
    package_version,
    project_id,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
      }
    | undefined;

  if (!projection) {
    throw new Error(
      "Operational Package Authority requires an exact derived Mission Package projection.",
    );
  }

  const existing = getOperationalPackageForProject(db, project_id);

  if (
    existing &&
    existing.package_id === package_id &&
    existing.package_version === package_version
  ) {
    return existing;
  }

  const selected_at = new Date().toISOString();

  db.prepare(`
    INSERT INTO operational_package_authority (
      project_id,
      package_id,
      package_version,
      selected_at
    ) VALUES (?, ?, ?, ?)
    ON CONFLICT(project_id) DO UPDATE SET
      package_id = excluded.package_id,
      package_version = excluded.package_version,
      selected_at = excluded.selected_at
  `).run(
    project_id,
    package_id,
    package_version,
    selected_at,
  );

  const selected = getOperationalPackageForProject(db, project_id);

  if (!selected) {
    throw new Error(
      "Operational Package Authority write completed without a readable authority row.",
    );
  }

  return selected;
}
TS

cat > db/operational-package-authority.test.ts << 'TS'
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
TS

echo
echo "=== APPLY LIVE MIGRATION ==="
BACKUP="db/main.db.pre-operational-package-authority-$(date +%Y%m%d_%H%M%S).bak"
cp db/main.db "${BACKUP}"
echo "ROLLBACK_BACKUP=${BACKUP}"

sqlite3 db/main.db < "${MIGRATION}"

echo
echo "=== VERIFY LIVE SCHEMA ==="
sqlite3 -header -column db/main.db "
SELECT sql
FROM sqlite_master
WHERE type = 'table'
  AND name = 'operational_package_authority';
"

echo
echo "=== TARGETED FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM pragma_foreign_key_check
WHERE \"table\" = 'operational_package_authority';
"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== TARGETED TESTS ==="
npx tsx db/operational-package-authority.test.ts

echo
echo "=== IMPLEMENTATION RESULT ==="
echo "OPERATIONAL_PACKAGE_AUTHORITY_SCHEMA=IMPLEMENTED"
echo "OPERATIONAL_PACKAGE_AUTHORITY_WRITE_ADAPTER=IMPLEMENTED"
echo "OPERATIONAL_PACKAGE_AUTHORITY_READ_ADAPTER=IMPLEMENTED"
echo "MISSION_READ_CHANGE=NO"
echo "MISSION_CONTROL_CHANGE=NO"
echo "DELEGATION_CHANGE=NO"
echo "VALIDATION_CHANGE=NO"
echo "ROUTING_CHANGE=NO"
echo "ASSIGNMENT_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"
echo "LIVE_OPERATIONAL_PACKAGE_SELECTION_PERFORMED=NO"
echo "NEXT_ACTION=CLASSIFY_IMPLEMENTATION_AND_VALIDATE_AUTHORITY_BOUNDARY_BEFORE_ANY_LIVE_SELECTION"
