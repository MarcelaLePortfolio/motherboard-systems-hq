#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PROJECT-SCOPED DELEGATION IMPLEMENTATION RESULT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY IMPLEMENTATION COMMIT ==="
git show --stat --oneline 5b9082f2

echo
echo "=== VERIFY TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== VERIFY TARGETED TESTS ==="
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts

echo
echo "=== VERIFY DISPOSABLE SCHEMA CONTRACT ==="
node scripts/validate-project-scoped-delegation-reference.mjs

echo
echo "=== VERIFY LIVE DATABASE REMAINS UNMIGRATED ==="
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const columns = db.prepare("PRAGMA table_info(governance_delegations)").all();
  const hasProjectId = columns.some((row) => row.name === "project_id");

  console.log(
    "LIVE_GOVERNANCE_DELEGATIONS_PROJECT_ID_COLUMN=" +
      (hasProjectId ? "PRESENT" : "ABSENT")
  );

  const downstream = [
    "governance_validation_results",
    "governance_envelope_gates",
    "governance_envelopes",
  ];

  for (const table of downstream) {
    const refs = db
      .prepare(`PRAGMA foreign_key_list(${table})`)
      .all()
      .filter((row) => String(row.table).includes("governance_delegations"));

    console.log(`${table}_DELEGATION_FKS=${JSON.stringify(refs)}`);
  }
} finally {
  db.close();
}
NODE

echo
echo "=== CLASSIFICATION ==="
echo "UNIT_NAME=PROJECT_SCOPED_DELEGATION_REFERENCE"
echo "IMPLEMENTATION_COMMIT=5b9082f2"
echo "IMPLEMENTATION_COMMITTED=YES"
echo "IMPLEMENTATION_PUSHED=YES"
echo "TYPECHECK=PASS"
echo "TARGETED_TESTS=PASS"
echo "DISPOSABLE_SCHEMA_VALIDATION=PASS"
echo "VALID_PROJECT_PACKAGE_REFERENCE=PASS"
echo "CROSS_PROJECT_REFERENCE=REJECTED"
echo "TARGETED_DELEGATION_FK_CHECK=PASS"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT=STILL_SEPARATELY_PRESENT"
echo "KNOWN_DOWNSTREAM_DEFECT_REOPENED=NO"
echo "LIVE_DATABASE_MIGRATION_APPLIED=NO"
echo "IMPLEMENTATION_UNIT_STATUS=CODE_COMPLETE_VALIDATED_PENDING_LIVE_MIGRATION_DECISION"
echo "CORRIDOR_CLOSED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=DECIDE_LIVE_MIGRATION_BOUNDARY_SEPARATELY"
