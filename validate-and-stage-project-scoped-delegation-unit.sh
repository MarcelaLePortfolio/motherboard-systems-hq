#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE AND STAGE PROJECT-SCOPED DELEGATION UNIT ==="

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== TARGETED TESTS ==="
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts

echo
echo "=== DISPOSABLE SCHEMA VALIDATION ==="
node scripts/validate-project-scoped-delegation-reference.mjs

echo
echo "=== MIGRATION DOWNSTREAM FK SAFETY CHECK ==="
node <<'NODE'
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const Database = require("better-sqlite3");

const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "delegation-fk-safety-"));
const dbPath = path.join(tempDir, "main.db");
fs.copyFileSync("db/main.db", dbPath);

const db = new Database(dbPath);
try {
  db.pragma("foreign_keys = OFF");
  db.exec(fs.readFileSync("drizzle/0010_project_scoped_delegation_reference.sql", "utf8"));
  db.pragma("foreign_keys = ON");

  const dependent = [
    "governance_validation_results",
    "governance_envelope_gates",
    "governance_envelopes",
  ];

  let unsafe = false;

  for (const table of dependent) {
    const rows = db.prepare(`PRAGMA foreign_key_list(${table})`).all();
    const delegationRefs = rows.filter((row) =>
      String(row.table).includes("governance_delegations")
    );

    console.log(`${table}_DELEGATION_FKS=${JSON.stringify(delegationRefs)}`);

    if (
      delegationRefs.some(
        (row) => row.table === "governance_delegations_pre_project_scope"
      )
    ) {
      unsafe = true;
    }
  }

  if (unsafe) {
    console.error("MIGRATION_DOWNSTREAM_FK_SAFETY=FAIL");
    process.exitCode = 1;
  } else {
    console.log("MIGRATION_DOWNSTREAM_FK_SAFETY=PASS");
  }
} finally {
  db.close();
  fs.rmSync(tempDir, { recursive: true, force: true });
}
NODE

echo
echo "=== REMOVE EMPTY ACCIDENTAL FILE IF STILL EMPTY ==="
if [[ -f "prompt," ]]; then
  test ! -s "prompt," || {
    echo "ERROR=prompt,_IS_NOT_EMPTY"
    exit 1
  }
  rm "prompt,"
fi

echo
echo "=== CONTAINMENT ==="
git diff --check
git status --short

echo
echo "=== STAGE AUTHORIZED UNIT ONLY ==="
git add \
  db/governance-runtime.ts \
  server/routes/governance-delegation-route.ts \
  server/delegation/production-delegation-consumer.ts \
  server/delegation/production-delegation-consumer.test.ts \
  server/delegation/production-delegation-entry-point.ts \
  server/delegation/production-delegation-entry-point.test.ts \
  drizzle/0010_project_scoped_delegation_reference.sql \
  scripts/validate-project-scoped-delegation-reference.mjs

git diff --cached --check
git diff --cached --stat

git commit -m "Implement project-scoped Delegation reference"
git push
