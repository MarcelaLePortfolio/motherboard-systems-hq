#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CANONICAL VERSION PERSISTENCE · LIVE VALIDATION ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=cc8ea3f0' \
'QUESTION=DID_THE_LIVE_SCHEMA_MIGRATE_SAFELY_AND_DO_VERSION_IDENTITY_INVARIANTS_HOLD' \
'DELEGATION_CHANGE=NONE'

printf '\n=== INITIALIZE AUTHORIZED SCHEMA ===\n'
node -r ts-node/register <<'NODE'
const {
  initializeCanonicalPackageSchema,
} = require("./db/matilda-canonical-package-runtime");

initializeCanonicalPackageSchema();
console.log("CANONICAL_SCHEMA_INITIALIZATION=PASS");
NODE

printf '\n=== VERIFY LIVE DATABASE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

const columns = db.prepare(
  "PRAGMA table_info(matilda_canonical_packages)"
).all();

const canonical = db.prepare(`
  SELECT
    package_id,
    package_version,
    draft_package_id,
    draft_revision_id,
    lineage_id,
    status,
    approval_timestamp,
    created_at
  FROM matilda_canonical_packages
  ORDER BY package_id, package_version
`).all();

const revisionTable = db.prepare(`
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
    AND name = 'matilda_draft_revisions'
`).get();

const indexes = db.prepare(`
  SELECT name, sql
  FROM sqlite_master
  WHERE type = 'index'
    AND tbl_name = 'matilda_canonical_packages'
  ORDER BY name
`).all();

console.log("\n=== COLUMNS ===");
console.log(columns);

console.log("\n=== CANONICAL ROWS ===");
console.log(canonical);

console.log("\n=== DRAFT REVISION SCHEMA ===");
console.log(`REVISION_TABLE_EXISTS=${revisionTable ? "YES" : "NO"}`);

console.log("\n=== CANONICAL INDEXES ===");
console.log(indexes);

const legacy = canonical.find(
  row => row.package_id === "pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c"
);

if (!legacy) {
  throw new Error("Historical Canonical Package is missing.");
}

if (legacy.package_version !== 1) {
  throw new Error(
    `Historical Canonical Package expected version 1; found ${legacy.package_version}.`
  );
}

if (legacy.draft_revision_id !== null) {
  throw new Error(
    "Historical Canonical Package must retain NULL draft_revision_id."
  );
}

if (legacy.status !== "canonical_approved") {
  throw new Error(
    `Historical Canonical Package status changed unexpectedly: ${legacy.status}`
  );
}

console.log("\nLEGACY_CANONICAL_VERSION_1=PASS");
console.log("LEGACY_NULL_REVISION_PROVENANCE=PASS");
console.log("CANONICAL_APPROVAL_STATUS_PRESERVED=PASS");

db.close();
NODE

printf '\n=== WORKTREE ===\n'
git status --short
