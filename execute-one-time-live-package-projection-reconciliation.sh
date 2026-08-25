#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PROJECT_ID="hq"
PACKAGE_ID="pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c"
PACKAGE_VERSION="1"

echo "=== EXECUTE ONE-TIME LIVE PACKAGE PROJECTION RECONCILIATION ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "AUTHORIZATION_COMMIT=f077930b"
echo "AUTHORIZED_PROJECT_ID=${PROJECT_ID}"
echo "AUTHORIZED_PACKAGE_ID=${PACKAGE_ID}"
echo "AUTHORIZED_PACKAGE_VERSION=${PACKAGE_VERSION}"
echo "GENERAL_HISTORICAL_BACKFILL_AUTHORIZED=NO"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"

echo
echo "=== PRE-RECONCILIATION SOURCE STATE ==="
sqlite3 -header -column db/main.db "
SELECT
  project_id,
  package_id,
  package_version,
  status,
  conversation_id,
  approved_expected_outcome,
  created_at
FROM matilda_canonical_packages
WHERE project_id = '${PROJECT_ID}'
  AND package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
"

echo
echo "=== PRE-RECONCILIATION TARGET STATE ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM governance_packages
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
"

echo
echo "=== SNAPSHOT AUTHORITY-ADJACENT STATE BEFORE RECONCILIATION ==="
DELEGATION_BEFORE="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
")"
echo "DELEGATION_ROWS_BEFORE=${DELEGATION_BEFORE}"

cat > db/run-one-time-package-projection-reconciliation.ts << 'INNER'
import Database from "better-sqlite3";

import {
  projectCanonicalPackageToMissionPackage,
} from "./canonical-package-mission-projection";

const sqlite = new Database("db/main.db");

try {
  sqlite.pragma("foreign_keys = ON");

  const result = projectCanonicalPackageToMissionPackage(
    sqlite,
    {
      project_id: "hq",
      package_id: "pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c",
      package_version: 1,
    },
  );

  console.log(
    "RECONCILIATION_RESULT="
      + JSON.stringify(result),
  );
} finally {
  sqlite.close();
}
INNER

npx tsx db/run-one-time-package-projection-reconciliation.ts
rm -f db/run-one-time-package-projection-reconciliation.ts

echo
echo "=== POST-RECONCILIATION TARGET STATE ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  requested_outcome,
  scope,
  containment,
  constraints,
  success_criteria,
  context,
  style_presentation_intent,
  exclusions,
  created_at
FROM governance_packages
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
"

echo
echo "=== EXACT SOURCE / TARGET VERIFICATION ==="
sqlite3 -header -column db/main.db "
SELECT
  c.project_id AS canonical_project_id,
  g.project_id AS projected_project_id,
  c.package_id AS canonical_package_id,
  g.package_id AS projected_package_id,
  c.package_version AS canonical_package_version,
  g.package_version AS projected_package_version,
  c.conversation_id AS canonical_conversation_id,
  g.conversation_id AS projected_conversation_id,
  c.approved_expected_outcome AS canonical_expected_outcome,
  g.requested_outcome AS projected_requested_outcome,
  c.created_at AS canonical_created_at,
  g.created_at AS projected_created_at,
  CASE
    WHEN c.project_id = g.project_id
     AND c.package_id = g.package_id
     AND c.package_version = g.package_version
     AND c.conversation_id = g.conversation_id
     AND c.approved_expected_outcome = g.requested_outcome
     AND c.created_at = g.created_at
    THEN 'PASS'
    ELSE 'FAIL'
  END AS exact_projection_match
FROM matilda_canonical_packages c
JOIN governance_packages g
  ON g.package_id = c.package_id
 AND g.package_version = c.package_version
WHERE c.project_id = '${PROJECT_ID}'
  AND c.package_id = '${PACKAGE_ID}'
  AND c.package_version = ${PACKAGE_VERSION}
  AND c.status = 'canonical_approved';
"

echo
echo "=== UNUSED LEGACY FIELD VERIFICATION ==="
sqlite3 -header -column db/main.db "
SELECT
  CASE
    WHEN scope IS NULL
     AND containment IS NULL
     AND constraints IS NULL
     AND success_criteria IS NULL
     AND context IS NULL
     AND style_presentation_intent IS NULL
     AND exclusions IS NULL
    THEN 'PASS'
    ELSE 'FAIL'
  END AS unused_legacy_fields_null
FROM governance_packages
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
"

echo
echo "=== AUTHORITY-ADJACENT STATE AFTER RECONCILIATION ==="
DELEGATION_AFTER="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
")"
echo "DELEGATION_ROWS_AFTER=${DELEGATION_AFTER}"

if [ "${DELEGATION_BEFORE}" != "${DELEGATION_AFTER}" ]; then
  echo "DELEGATION_STATE_UNCHANGED=NO"
  exit 1
fi

echo "DELEGATION_STATE_UNCHANGED=YES"
echo "MISSION_READ_CHANGE=NO"
echo "MISSION_CONTROL_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"

cat > db/retry-one-time-package-projection-reconciliation.ts << 'INNER'
import Database from "better-sqlite3";

import {
  projectCanonicalPackageToMissionPackage,
} from "./canonical-package-mission-projection";

const sqlite = new Database("db/main.db");

try {
  const result = projectCanonicalPackageToMissionPackage(
    sqlite,
    {
      project_id: "hq",
      package_id: "pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c",
      package_version: 1,
    },
  );

  console.log(
    "IDEMPOTENT_RETRY_RESULT="
      + JSON.stringify(result),
  );

  if (result.idempotent !== true) {
    process.exitCode = 1;
  }
} finally {
  sqlite.close();
}
INNER

npx tsx db/retry-one-time-package-projection-reconciliation.ts
rm -f db/retry-one-time-package-projection-reconciliation.ts

echo
echo "=== RECONCILIATION COMPLETION ==="
echo "ONE_TIME_LIVE_RECONCILIATION=EXECUTED"
echo "GENERAL_HISTORICAL_BACKFILL=NOT_PERFORMED"
echo "PACKAGE_HANDOFF_CONTRACT_LIVE_STATE_BLOCKER=EXPECTED_TO_BE_CLEARED"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "NEXT_ACTION=CLASSIFY_RECONCILIATION_RESULT_AND_FORMALLY_CLOSE_PACKAGE_HANDOFF_CONTRACT_IF_ALL_CHECKS_PASS"
