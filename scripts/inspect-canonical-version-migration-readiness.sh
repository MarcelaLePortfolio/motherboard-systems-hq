#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CANONICAL VERSION IDENTITY · MIGRATION READINESS ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=b1f31f54' \
'DRAFT_REVISION_RUNTIME_TARGETED_TYPECHECK=PASS' \
'BASELINE_ATLAS_TYPECHECK_FAILURE=PREEXISTING' \
'NEXT_UNIT=CANONICAL_PACKAGE_VERSION_PERSISTENCE' \
'QUESTION=CAN_THE_EXISTING_CANONICAL_PACKAGE_BE_MIGRATED_TO_VERSION_1_WITHOUT_INVENTING_DRAFT_REVISION_PROVENANCE' \
'IMPLEMENTATION_AUTHORIZED=YES'

node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

const canonical = db.prepare(`
  SELECT *
  FROM matilda_canonical_packages
  ORDER BY created_at
`).all();

console.log("\n=== EXISTING CANONICAL PACKAGES ===");
console.log(canonical);

console.log("\n=== SOURCE LIVING DRAFT COMPARISON ===");

for (const pkg of canonical) {
  const draft = db.prepare(`
    SELECT *
    FROM matilda_living_draft_packages
    WHERE draft_package_id = ?
    LIMIT 1
  `).get(pkg.draft_package_id);

  console.log({
    package_id: pkg.package_id,
    draft_package_id: pkg.draft_package_id,
    canonical_created_at: pkg.created_at,
    living_draft_updated_at: draft?.updated_at ?? null,
    same_lineage: draft ? draft.lineage_id === pkg.lineage_id : false,
    same_interpretation:
      draft ? draft.current_interpretation === pkg.approved_interpretation : false,
    same_work:
      draft ? (draft.proposed_work ?? null) === (pkg.approved_work ?? null) : false,
    same_artifacts:
      draft ? (draft.proposed_artifacts ?? null) === (pkg.approved_artifacts ?? null) : false,
    same_scope:
      draft ? (draft.in_scope ?? null) === (pkg.approved_scope ?? null) : false,
    same_constraints:
      draft ? (draft.constraints ?? null) === (pkg.approved_constraints ?? null) : false,
    same_expected_outcome:
      draft ? (draft.expected_outcome ?? null) === (pkg.approved_expected_outcome ?? null) : false,
  });
}

console.log("\n=== DRAFT REVISION TABLE STATE ===");
const revisionTable = db.prepare(`
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
    AND name = 'matilda_draft_revisions'
`).get();

console.log(`REVISION_TABLE_EXISTS=${revisionTable ? "YES" : "NO"}`);

if (revisionTable) {
  console.log(
    db.prepare(`
      SELECT *
      FROM matilda_draft_revisions
      ORDER BY created_at
    `).all()
  );
}

db.close();
NODE

printf '\n=== BOUNDARY ===\n'
printf '%s\n' \
'NO_SCHEMA_MUTATION_PERFORMED=YES' \
'NO_CANONICAL_ROW_MUTATION_PERFORMED=YES' \
'NO_DELEGATION_CHANGE_PERFORMED=YES'
