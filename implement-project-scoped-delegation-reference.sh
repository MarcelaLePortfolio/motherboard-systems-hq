#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT PROJECT-SCOPED DELEGATION REFERENCE ==="

echo
echo "=== BASELINE ==="
test "$(git rev-parse --short=8 HEAD)" = "fea53c11" || {
  echo "Unexpected HEAD; refusing implementation."
  exit 1
}
test -z "$(git status --short)" || {
  echo "Worktree is not clean; refusing implementation."
  git status --short
  exit 1
}

python3 <<'PY'
from pathlib import Path

path = Path("db/governance-runtime.ts")
text = path.read_text()

replacements = [
(
"""export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  package_id: string;""",
"""export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  project_id: string;

  package_id: string;"""
),
(
"""export type CreatedGovernanceDelegation = {

  delegation_id: string;

  package_id: string;""",
"""export type CreatedGovernanceDelegation = {

  delegation_id: string;

  project_id: string;

  package_id: string;"""
),
(
"""    CREATE TABLE IF NOT EXISTS governance_delegations (

      delegation_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,""",
"""    CREATE TABLE IF NOT EXISTS governance_delegations (

      delegation_id TEXT PRIMARY KEY,

      project_id TEXT NOT NULL,

      package_id TEXT NOT NULL,"""
),
(
"""      FOREIGN KEY (package_id, package_version)

        REFERENCES matilda_canonical_packages(package_id, package_version)

    );""",
"""      FOREIGN KEY (project_id, package_id, package_version)

        REFERENCES matilda_canonical_packages(project_id, package_id, package_version)

    );"""
),
(
"""  const delegation_id = requireDelegationText(input, "delegation_id");

  const package_id = requireDelegationText(input, "package_id");""",
"""  const delegation_id = requireDelegationText(input, "delegation_id");

  const project_id = requireDelegationText(input, "project_id");

  const package_id = requireDelegationText(input, "package_id");"""
),
(
"""    SELECT
      package_id,
      package_version
    FROM matilda_canonical_packages
    WHERE package_id = ?
      AND package_version = ?
    LIMIT 1
  `).get(
    package_id,
    package_version,
  ) as
    | {
        package_id: string;
        package_version: number;
      }""",
"""    SELECT
      project_id,
      package_id,
      package_version
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 1
  `).get(
    project_id,
    package_id,
    package_version,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
      }"""
),
(
"""      delegation_id,

      package_id,

      package_version,""",
"""      delegation_id,

      project_id,

      package_id,

      package_version,"""
),
(
"""      @delegation_id,

      @package_id,

      @package_version,""",
"""      @delegation_id,

      @project_id,

      @package_id,

      @package_version,"""
),
(
"""    delegation_id,

    package_id,

    package_version,""",
"""    delegation_id,

    project_id,

    package_id,

    package_version,"""
),
]

for old, new in replacements:
    if old not in text:
        raise SystemExit(f"Expected governance-runtime fragment not found:\n{old[:180]}")
    text = text.replace(old, new, 1)

marker = """    CREATE TABLE IF NOT EXISTS governance_delegations ("""
index_sql = """    CREATE UNIQUE INDEX IF NOT EXISTS idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages(project_id, package_id, package_version);

"""
if index_sql not in text:
    if marker not in text:
        raise SystemExit("Delegation table marker not found for unique index insertion.")
    text = text.replace(marker, index_sql + marker, 1)

path.write_text(text)
PY

python3 <<'PY'
from pathlib import Path

files = [
    Path("server/delegation/production-delegation-entry-point.ts"),
    Path("server/delegation/production-delegation-consumer.ts"),
]

for path in files:
    text = path.read_text()

    if "project_id:" not in text:
        text = text.replace(
            "  delegation_id: string;",
            "  delegation_id: string;\n\n  project_id: string;",
            1,
        )

    needle = "      delegation_id: input.delegation_id,"
    replacement = "      delegation_id: input.delegation_id,\n\n      project_id: input.project_id,"
    if path.name == "production-delegation-consumer.ts":
        needle = "    delegation_id: input.delegation_id,"
        replacement = "    delegation_id: input.delegation_id,\n\n    project_id: input.project_id,"

    if replacement not in text:
        if needle not in text:
            raise SystemExit(f"Expected transport fragment not found in {path}")
        text = text.replace(needle, replacement, 1)

    path.write_text(text)
PY

python3 <<'PY'
from pathlib import Path

for filename in [
    "server/delegation/production-delegation-entry-point.test.ts",
    "server/delegation/production-delegation-consumer.test.ts",
]:
    path = Path(filename)
    text = path.read_text()

    text = text.replace(
        '    delegation_id: "delegation-entry-point-success",',
        '    delegation_id: "delegation-entry-point-success",\n\n    project_id: "hq",'
    )
    text = text.replace(
        '    delegation_id: "delegation-entry-point-fail",',
        '    delegation_id: "delegation-entry-point-fail",\n\n    project_id: "hq",'
    )
    text = text.replace(
        '    delegation_id: "delegation-consumer-success",',
        '    delegation_id: "delegation-consumer-success",\n\n    project_id: "hq",'
    )
    text = text.replace(
        '    delegation_id: "delegation-consumer-fail",',
        '    delegation_id: "delegation-consumer-fail",\n\n    project_id: "hq",'
    )

    text = text.replace(
        "      delegation_id: input.delegation_id,\n",
        "      delegation_id: input.delegation_id,\n\n      project_id: input.project_id,\n",
        1,
    )

    path.write_text(text)
PY

cat > drizzle/0010_project_scoped_delegation_reference.sql << 'SQL'
PRAGMA foreign_keys = OFF;

CREATE UNIQUE INDEX IF NOT EXISTS idx_matilda_canonical_packages_project_package_version
ON matilda_canonical_packages(project_id, package_id, package_version);

ALTER TABLE governance_delegations
RENAME TO governance_delegations_pre_project_scope;

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

INSERT INTO governance_delegations (
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
)
SELECT
  legacy.delegation_id,
  canonical.project_id,
  legacy.package_id,
  legacy.package_version,
  legacy.authorization_state,
  legacy.authorization_timestamp,
  legacy.delegated_by,
  legacy.created_at
FROM governance_delegations_pre_project_scope AS legacy
LEFT JOIN matilda_canonical_packages AS canonical
  ON canonical.package_id = legacy.package_id
 AND canonical.package_version = legacy.package_version;

DROP TABLE governance_delegations_pre_project_scope;

PRAGMA foreign_keys = ON;
SQL

cat > scripts/validate-project-scoped-delegation-reference.mjs << 'EOFJS'
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import Database from "better-sqlite3";

const source = "db/main.db";
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "project-scoped-delegation-"));
const target = path.join(tempDir, "main.db");
fs.copyFileSync(source, target);

const db = new Database(target);

try {
  db.pragma("foreign_keys = OFF");
  db.exec(fs.readFileSync("drizzle/0010_project_scoped_delegation_reference.sql", "utf8"));
  db.pragma("foreign_keys = ON");

  const cols = db.prepare("PRAGMA table_info(governance_delegations)").all();
  if (!cols.some((row) => row.name === "project_id")) {
    throw new Error("governance_delegations.project_id missing after migration");
  }

  const fks = db.prepare("PRAGMA foreign_key_list(governance_delegations)").all();
  const composite = fks.filter((row) => row.table === "matilda_canonical_packages");
  const mapping = new Set(composite.map((row) => `${row.from}->${row.to}`));

  for (const required of [
    "project_id->project_id",
    "package_id->package_id",
    "package_version->package_version",
  ]) {
    if (!mapping.has(required)) {
      throw new Error(`Missing composite FK component: ${required}`);
    }
  }

  const canonical = db.prepare(`
    SELECT project_id, package_id, package_version
    FROM matilda_canonical_packages
    WHERE project_id IS NOT NULL
      AND TRIM(project_id) <> ''
      AND status = 'canonical_approved'
    LIMIT 1
  `).get();

  if (!canonical) {
    throw new Error("No project-bound canonical approved Package available.");
  }

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
    ) VALUES (?, ?, ?, ?, 'AUTHORIZED', ?, 'validation-probe', ?)
  `).run(
    "project-scoped-delegation-valid-probe",
    canonical.project_id,
    canonical.package_id,
    canonical.package_version,
    new Date().toISOString(),
    new Date().toISOString(),
  );

  let mismatchRejected = false;
  try {
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
      ) VALUES (?, ?, ?, ?, 'AUTHORIZED', ?, 'validation-probe', ?)
    `).run(
      "project-scoped-delegation-mismatch-probe",
      "__wrong_project__",
      canonical.package_id,
      canonical.package_version,
      new Date().toISOString(),
      new Date().toISOString(),
    );
  } catch {
    mismatchRejected = true;
  }

  if (!mismatchRejected) {
    throw new Error("Cross-project canonical Package reference was accepted.");
  }

  const targeted = db.prepare(`
    SELECT *
    FROM pragma_foreign_key_check
    WHERE "table" = 'governance_delegations'
  `).all();

  console.log("PROJECT_SCOPED_DELEGATION_SCHEMA=PASS");
  console.log("VALID_PROJECT_PACKAGE_REFERENCE=PASS");
  console.log("CROSS_PROJECT_PACKAGE_REFERENCE=REJECTED");
  console.log(
    "TARGETED_DELEGATION_FOREIGN_KEY_CHECK=" +
      (targeted.length === 0 ? "PASS" : "FAIL"),
  );

  if (targeted.length !== 0) {
    console.log(JSON.stringify(targeted, null, 2));
    process.exitCode = 1;
  }
} finally {
  db.close();
  fs.rmSync(tempDir, { recursive: true, force: true });
}
EOFJS

echo
echo "=== BOUNDED VALIDATION ==="
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts
node scripts/validate-project-scoped-delegation-reference.mjs
npx tsc --noEmit --pretty false

echo
echo "=== CONTAINMENT CHECK ==="
git diff --name-only
git diff --check

echo
echo "=== IMPLEMENTATION RESULT ==="
echo "UNIT_NAME=PROJECT_SCOPED_DELEGATION_REFERENCE"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_STARTED=YES"
echo "PROJECT_SCOPED_DELEGATION_REFERENCE_IMPLEMENTED=YES"
echo "CANONICAL_PRIMARY_IDENTITY_CHANGED=NO"
echo "LEGACY_CORRIDOR_SMOKE_REPARENTED=NO"
echo "VALIDATION_GATE_ENVELOPE_SCOPE_EXPANDED=NO"
echo "MISSION_CONTROL_CHANGED=NO"
echo "NEXT_ACTION=REVIEW_VALIDATION_OUTPUT_BEFORE_APPLYING_MIGRATION_TO_LIVE_DATABASE"
