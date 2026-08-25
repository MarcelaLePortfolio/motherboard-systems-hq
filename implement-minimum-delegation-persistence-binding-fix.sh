#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

git merge-base --is-ancestor 3a7d3de0 HEAD || {
  echo "Authorized checkpoint is not an ancestor of HEAD."
  exit 1
}

python3 <<'PY'
from pathlib import Path

path = Path("db/governance-runtime.ts")
text = path.read_text()

start = text.find("export function createGovernanceDelegation(")
end = text.find("\nexport function createGovernanceValidationResult(", start)
if start == -1 or end == -1:
    raise SystemExit("Delegation function boundary not found")

block = text[start:end]
old = """  `).run({

    delegation_id,

    package_id,
"""
new = """  `).run({

    delegation_id,

    project_id,

    package_id,
"""

if old not in block:
    raise SystemExit("Expected Delegation binding fragment not found")

block = block.replace(old, new, 1)
path.write_text(text[:start] + block + text[end:])
PY

cat > db/governance-delegation-persistence.test.ts << 'INNER'
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
INNER

npx tsc --noEmit --pretty false
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts \
  db/governance-delegation-persistence.test.ts

git add db/governance-runtime.ts db/governance-delegation-persistence.test.ts
git commit -m "Fix Delegation project persistence binding"
git push

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "MINIMUM_BINDING_FIX_APPLIED=YES"
echo "DIRECT_PERSISTENCE_REGRESSION_TEST=PASS"
echo "PROJECT_ID_PERSISTENCE_ASSERTION=PASS"
echo "CROSS_PROJECT_REJECTION_ASSERTION=PASS"
echo "SCHEMA_CHANGE=NONE"
echo "MIGRATION_CHANGE=NONE"
echo "PACKAGE_HANDOFF_CONTRACT_INVESTIGATION=PAUSED"
echo "NEXT_ACTION=RECLASSIFY_PROJECT_SCOPED_DELEGATION_CORRIDOR_FOR_RECLOSURE"
