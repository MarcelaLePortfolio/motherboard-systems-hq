#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT EXISTING DELEGATION PROJECT-SCOPE CONTRACT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== GOVERNING CLASSIFICATION ==="
echo "AUTHORITY_SEMANTICS=EXISTING_DELEGATION_MODEL"
echo "MINIMUM_REQUIRED_REFERENCE=(project_id,package_id,package_version)"
echo "QUESTION=DOES_EXISTING_DELEGATION_RUNTIME_ALREADY_ENFORCE_PROJECT_SCOPED_PACKAGE_REFERENCE_AUTHORITY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CANONICAL PACKAGE SCHEMA ==="
sqlite3 -header -column db/main.db "
PRAGMA table_info(matilda_canonical_packages);
"

echo
echo "=== CANONICAL PACKAGE INDEXES ==="
sqlite3 -header -column db/main.db "
PRAGMA index_list(matilda_canonical_packages);
"

echo
echo "=== DELEGATION SCHEMA ==="
sqlite3 -header -column db/main.db "
PRAGMA table_info(governance_delegations);
"

echo
echo "=== DELEGATION FOREIGN KEYS ==="
sqlite3 -header -column db/main.db "
PRAGMA foreign_key_list(governance_delegations);
"

echo
echo "=== DELEGATION INDEXES ==="
sqlite3 -header -column db/main.db "
PRAGMA index_list(governance_delegations);
"

echo
echo "=== DELEGATION TABLE DEFINITION ==="
sqlite3 -header -column db/main.db "
SELECT sql
FROM sqlite_master
WHERE type = 'table'
  AND name = 'governance_delegations';
"

echo
echo "=== PRODUCTION DELEGATION ENTRY POINT ==="
sed -n '1,240p' server/delegation/production-delegation-entry-point.ts

echo
echo "=== PRODUCTION DELEGATION CONSUMER ==="
if [[ -f server/delegation/production-delegation-consumer.ts ]]; then
  sed -n '1,260p' server/delegation/production-delegation-consumer.ts
else
  echo "PRODUCTION_DELEGATION_CONSUMER_PRESENT=NO"
fi

echo
echo "=== DELEGATION PERSISTENCE IMPLEMENTATION ==="
rg -n -C 35 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createGovernanceDelegation|CreateGovernanceDelegationInput|governance_delegations|INSERT INTO governance_delegations' \
  db server \
  2>/dev/null | head -n 5200 || true

echo
echo "=== PROJECT-SCOPE TRANSPORT THROUGH DELEGATION SURFACES ==="
rg -n -C 28 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'project_id|projectId|package_id|package_version|delegation_id' \
  server/delegation db/governance-runtime.ts \
  2>/dev/null | head -n 5200 || true

echo
echo "=== CURRENT CANONICAL PACKAGE / DELEGATION RELATIONSHIP ==="
sqlite3 -header -column db/main.db "
SELECT
  cp.project_id,
  cp.package_id,
  cp.package_version,
  cp.status AS package_status,
  d.delegation_id,
  d.authorization_state,
  d.authorization_timestamp,
  d.delegated_by
FROM matilda_canonical_packages cp
LEFT JOIN governance_delegations d
  ON d.package_id = cp.package_id
 AND d.package_version = cp.package_version
ORDER BY cp.created_at, d.created_at;
"

echo
echo "=== STRUCTURAL PROJECT-SCOPE TEST ==="
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", { readonly: true });

try {
  const packageColumns = db
    .prepare("PRAGMA table_info(matilda_canonical_packages)")
    .all()
    .map((row) => row.name);

  const delegationColumns = db
    .prepare("PRAGMA table_info(governance_delegations)")
    .all()
    .map((row) => row.name);

  const delegationForeignKeys = db
    .prepare("PRAGMA foreign_key_list(governance_delegations)")
    .all();

  const hasPackageProject = packageColumns.includes("project_id");
  const hasDelegationProject = delegationColumns.includes("project_id");

  const packageFkColumns = delegationForeignKeys
    .filter((row) => row.table === "matilda_canonical_packages")
    .map((row) => `${row.from}->${row.to}`);

  const projectParticipatesInPackageFk = delegationForeignKeys.some(
    (row) =>
      row.table === "matilda_canonical_packages" &&
      row.from === "project_id" &&
      row.to === "project_id"
  );

  console.log(
    "CANONICAL_PACKAGE_HAS_PROJECT_ID=" + (hasPackageProject ? "YES" : "NO")
  );
  console.log(
    "DELEGATION_HAS_PROJECT_ID=" + (hasDelegationProject ? "YES" : "NO")
  );
  console.log(
    "DELEGATION_CANONICAL_PACKAGE_FK_COLUMNS=" +
      (packageFkColumns.length ? packageFkColumns.join(",") : "NONE")
  );
  console.log(
    "PROJECT_ID_PARTICIPATES_IN_DELEGATION_PACKAGE_FK=" +
      (projectParticipatesInPackageFk ? "YES" : "NO")
  );

  if (
    hasPackageProject &&
    hasDelegationProject &&
    projectParticipatesInPackageFk
  ) {
    console.log(
      "STRUCTURAL_CLASSIFICATION=EXISTING_DELEGATION_RUNTIME_SUPPORTS_PROJECT_SCOPED_PACKAGE_REFERENCE"
    );
  } else {
    console.log(
      "STRUCTURAL_CLASSIFICATION=PROJECT_SCOPED_DELEGATION_REFERENCE_NOT_FULLY_ESTABLISHED_BY_DATABASE_STRUCTURE"
    );
  }
} finally {
  db.close();
}
NODE

echo
echo "=== AUTHORITY BOUNDARY PRESERVATION ==="
echo "PACKAGE_APPROVAL_AUTHORIZES_DELEGATION_AUTOMATICALLY=NO"
echo "DELEGATION_REMAINS_EXPLICIT_AUTHORITY_EVENT=YES"
echo "DELEGATION_CREATES_NEW_PACKAGE_MEANING=NO"
echo "DELEGATION_MAY_AUTHORIZE_SCHEDULER=NO"
echo "DELEGATION_MAY_AUTHORIZE_ROUTING=NO"
echo "DELEGATION_MAY_AUTHORIZE_ASSIGNMENT=NO"
echo "DELEGATION_MAY_AUTHORIZE_EXECUTION=NO"
echo "DOWNSTREAM_GOVERNANCE_AUTOMATICALLY_AUTHORIZED=NO"

echo
echo "=== CLASSIFICATION RULE ==="
echo "IF_PROJECT_ID_IS_ALREADY_PERSISTED_AND_DATABASE_BOUND_TO_CANONICAL_PACKAGE_REFERENCE=EXISTING_RUNTIME_SUFFICIENT"
echo "IF_PROJECT_ID_IS_ABSENT_OR_NOT_DATABASE_BOUND_TO_CANONICAL_PACKAGE_REFERENCE=BOUNDED_PROJECT_SCOPE_EXTENSION_CANDIDATE"
echo "DO_NOT_IMPLEMENT_FROM_THIS_INSPECTION=YES"
echo "DO_NOT_REOPEN_COMPLETED_DELEGATION_PACKAGE_ROOT_RECONCILIATION=YES"
echo "KNOWN_VALIDATION_GATE_ENVELOPE_LINEAGE_DEFECT_REOPENED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== NEXT DECISION ==="
echo "NEXT_DECISION=CLASSIFY_EXISTING_DELEGATION_PROJECT_SCOPE_AS_SUFFICIENT_OR_DEFINE_MINIMUM_BOUNDED_EXTENSION_FROM_REPOSITORY_EVIDENCE"
