#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PROJECT_ID="hq"
PACKAGE_ID="pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c"
PACKAGE_VERSION="1"

echo "=== EXECUTE EXACT LIVE OPERATIONAL PACKAGE SELECTION ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "AUTHORIZATION_COMMIT=1eddacfe"
echo "AUTHORIZED_PROJECT_ID=${PROJECT_ID}"
echo "AUTHORIZED_PACKAGE_ID=${PACKAGE_ID}"
echo "AUTHORIZED_PACKAGE_VERSION=${PACKAGE_VERSION}"

echo
echo "=== PRECONDITION CHECK ==="
sqlite3 -header -column db/main.db "
SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.status,
  g.project_id AS mission_project_id,
  g.package_id AS mission_package_id,
  g.package_version AS mission_package_version
FROM matilda_canonical_packages c
JOIN governance_packages g
  ON g.package_id = c.package_id
 AND g.package_version = c.package_version
WHERE c.project_id = '${PROJECT_ID}'
  AND c.package_id = '${PACKAGE_ID}'
  AND c.package_version = ${PACKAGE_VERSION}
  AND c.status = 'canonical_approved'
  AND g.project_id = c.project_id;
"

EXISTING_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM operational_package_authority
WHERE project_id = '${PROJECT_ID}';
")"

echo "EXISTING_AUTHORITY_ROWS=${EXISTING_COUNT}"

if [ "${EXISTING_COUNT}" != "0" ]; then
  echo "SELECTION_EXECUTION=BLOCKED"
  echo "REASON=UNEXPECTED_EXISTING_AUTHORITY_ROW"
  exit 1
fi

DELEGATION_BEFORE="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations
WHERE package_id = '${PACKAGE_ID}'
  AND package_version = ${PACKAGE_VERSION};
")"

echo "DELEGATION_ROWS_BEFORE=${DELEGATION_BEFORE}"

cat > db/run-exact-live-operational-package-selection.ts << 'INNER'
import Database from "better-sqlite3";

import {
  selectOperationalPackageForProject,
} from "./operational-package-authority";

const db = new Database("db/main.db");

try {
  db.pragma("foreign_keys = ON");

  const selected = selectOperationalPackageForProject(db, {
    project_id: "hq",
    package_id: "pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c",
    package_version: 1,
  });

  console.log(
    "SELECTION_RESULT=" + JSON.stringify(selected),
  );
} finally {
  db.close();
}
INNER

npx tsx db/run-exact-live-operational-package-selection.ts
rm -f db/run-exact-live-operational-package-selection.ts

echo
echo "=== PERSISTED AUTHORITY STATE ==="
sqlite3 -header -column db/main.db "
SELECT
  project_id,
  package_id,
  package_version,
  selected_at
FROM operational_package_authority
WHERE project_id = '${PROJECT_ID}';
"

MATCH_COUNT="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM operational_package_authority a
JOIN matilda_canonical_packages c
  ON c.project_id = a.project_id
 AND c.package_id = a.package_id
 AND c.package_version = a.package_version
JOIN governance_packages g
  ON g.project_id = a.project_id
 AND g.package_id = a.package_id
 AND g.package_version = a.package_version
WHERE a.project_id = '${PROJECT_ID}'
  AND a.package_id = '${PACKAGE_ID}'
  AND a.package_version = ${PACKAGE_VERSION}
  AND c.status = 'canonical_approved';
")"

echo "EXACT_OPERATIONAL_BINDING_MATCH_COUNT=${MATCH_COUNT}"

if [ "${MATCH_COUNT}" != "1" ]; then
  echo "SELECTION_VALIDATION=FAIL"
  exit 1
fi

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

cat > db/retry-exact-live-operational-package-selection.ts << 'INNER'
import Database from "better-sqlite3";

import {
  selectOperationalPackageForProject,
} from "./operational-package-authority";

const db = new Database("db/main.db");

try {
  db.pragma("foreign_keys = ON");

  const before = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      selected_at
    FROM operational_package_authority
    WHERE project_id = 'hq'
  `).get();

  const selected = selectOperationalPackageForProject(db, {
    project_id: "hq",
    package_id: "pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c",
    package_version: 1,
  });

  const after = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      selected_at
    FROM operational_package_authority
    WHERE project_id = 'hq'
  `).get();

  console.log(
    "IDEMPOTENT_RETRY_RESULT=" + JSON.stringify(selected),
  );

  if (JSON.stringify(before) !== JSON.stringify(after)) {
    throw new Error(
      "Idempotent retry changed the persisted operational authority binding.",
    );
  }
} finally {
  db.close();
}
INNER

npx tsx db/retry-exact-live-operational-package-selection.ts
rm -f db/retry-exact-live-operational-package-selection.ts

echo
echo "=== SELECTION CLASSIFICATION ==="
echo "LIVE_OPERATIONAL_PACKAGE_SELECTION=EXECUTED"
echo "EXACT_project_id+package_id+package_version_BINDING=VERIFIED"
echo "IDEMPOTENT_REPEAT=PRESERVED"
echo "CANONICAL_PACKAGE_MUTATION=NO"
echo "MISSION_PACKAGE_PROJECTION_MUTATION=NO"
echo "DELEGATION_STATE_UNCHANGED=YES"
echo "MISSION_READ_INTEGRATION=NOT_STARTED"
echo "MISSION_CONTROL_INTEGRATION=NOT_STARTED"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"

echo
echo "=== CORRIDOR STATE ==="
echo "PROJECT_BOUND_HANDOFF_OPERATIONAL_AUTHORITY_STATE=ESTABLISHED"
echo "PROJECT_BOUND_HANDOFF_CORRIDOR=CANNOT_CLOSE_YET"
echo "REMAINING_BOUNDARY=DOWNSTREAM_PROJECT_SCOPED_READ_HANDOFF"
echo "MISSION_CONTROL_INTAKE_STARTED=NO"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_PROJECT_SCOPED_READ_HANDOFF_FROM_OPERATIONAL_PACKAGE_AUTHORITY_TO_MISSION_READ"
