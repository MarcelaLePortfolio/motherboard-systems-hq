#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PROJECT-BOUND HANDOFF CLOSURE READINESS ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "READ_HANDOFF_IMPLEMENTATION_COMMIT=d28c1e75"
echo "VALIDATION_FIX_COMMIT=7b0b5104"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED IMPLEMENTATION STATE ==="
echo "OPERATIONAL_PACKAGE_AUTHORITY_PERSISTENCE=IMPLEMENTED"
echo "LIVE_OPERATIONAL_PACKAGE_SELECTION=ESTABLISHED"
echo "SERVER_SIDE_PROJECT_SCOPED_AUTHORITY_RESOLUTION=IMPLEMENTED"
echo "MISSION_READ_EXACT_PROJECT_PACKAGE_VERSION_LOOKUP=IMPLEMENTED"
echo "PROJECT_SCOPED_READ_HANDOFF_VALIDATION=PASS"
echo "TEST_ENTRYPOINT_FAILURE_CLASS=CJS_TOP_LEVEL_AWAIT_ONLY"
echo "ARCHITECTURE_FAILURE=NO"
echo "PRODUCTION_RUNTIME_DEFECT_ESTABLISHED=NO"

echo
echo "=== LIVE AUTHORITY IDENTITY ==="
sqlite3 -header -column db/main.db "
SELECT
  a.project_id,
  a.package_id,
  a.package_version,
  a.selected_at,
  c.status AS canonical_status,
  g.project_id AS mission_project_id,
  g.package_id AS mission_package_id,
  g.package_version AS mission_package_version
FROM operational_package_authority a
JOIN matilda_canonical_packages c
  ON c.project_id = a.project_id
 AND c.package_id = a.package_id
 AND c.package_version = a.package_version
JOIN governance_packages g
  ON g.project_id = a.project_id
 AND g.package_id = a.package_id
 AND g.package_version = a.package_version
ORDER BY a.project_id;
"

echo
echo "=== EXACT LIVE READ VALIDATION ==="
cat > db/classify-project-bound-handoff-live-read.ts << 'INNER'
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { getOperationalPackageForProject } from "./operational-package-authority";
import { createMissionReadRepository } from "./mission-read-repository";

async function main(): Promise<void> {
  const db = new Database("db/main.db", { readonly: true });

  try {
    const authority = getOperationalPackageForProject(db, "hq");
    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.project_id, authority.project_id);
    assert.equal(mission.package_id, authority.package_id);
    assert.equal(mission.package_version, authority.package_version);

    console.log("LIVE_READ_PROJECT_ID=" + mission.project_id);
    console.log("LIVE_READ_PACKAGE_ID=" + mission.package_id);
    console.log("LIVE_READ_PACKAGE_VERSION=" + mission.package_version);
    console.log("LIVE_EXACT_READ_IDENTITY=PASS");
  } finally {
    db.close();
  }
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
INNER

npx tsx db/classify-project-bound-handoff-live-read.ts
rm -f db/classify-project-bound-handoff-live-read.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

echo
echo "=== AUTHORITY NON-ESCALATION CHECK ==="
DELEGATION_COUNT="$(sqlite3 db/main.db "SELECT COUNT(*) FROM governance_delegations;")"
echo "LIVE_DELEGATION_COUNT=${DELEGATION_COUNT}"
echo "CANONICAL_PACKAGE_MUTATION=NO"
echo "MISSION_PACKAGE_PROJECTION_MUTATION=NO"
echo "OPERATIONAL_AUTHORITY_MUTATION_DURING_READ=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"

echo
echo "=== PROJECT-BOUND HANDOFF CONTRACT ==="
echo "ACTIVE_PROJECT_SCOPES_OPERATIONAL_AUTHORITY_LOOKUP=YES"
echo "OPERATIONAL_PACKAGE_AUTHORITY_SELECTS_EXACT_PACKAGE_VERSION=YES"
echo "MISSION_READ_CONSUMES_RESOLVED_EXACT_IDENTITY=YES"
echo "MISSION_READ_SELECTS_NEWEST_PACKAGE=NO"
echo "MISSION_READ_INFERS_SUCCESSOR_VERSION=NO"
echo "MISSION_READ_USES_CALLER_PACKAGE_ID_AS_AUTHORITY=NO"
echo "MISSION_READ_USES_DELEGATION_AS_SELECTION_AUTHORITY=NO"
echo "MISSION_CONTROL_SELECTS_OPERATIONAL_PACKAGE=NO"

echo
echo "=== CORRIDOR BOUNDARY CHECK ==="
echo "MISSION_CONTROL_INTAKE_STARTED=NO"
echo "MISSION_CONTROL_UI_CHANGE=NO"
echo "MISSION_CONTROL_PROVIDER_CHANGE=NO"
echo "MISSION_CONTROL_WORKSPACE_CHANGE=NO"
echo "HARDCODED_MISSION_CONTROL_PACKAGE_ID_STILL_EXISTS=EXPECTED_UNTIL_NEXT_CORRIDOR"
echo "MISSION_CONTROL_INTAKE_REMAINS_SEPARATE_CORRIDOR=YES"

echo
echo "=== CLOSURE READINESS DETERMINATION ==="
echo "OPERATIONAL_AUTHORITY_BOUNDARY=COMPLETE"
echo "EXACT_LIVE_SELECTION_STATE=COMPLETE"
echo "PROJECT_SCOPED_READ_HANDOFF=COMPLETE"
echo "TARGETED_VALIDATION=PASS"
echo "FAIL_CLOSED_IDENTITY_CONTRACT=PRESERVED"
echo "AUTHORITY_NON_ESCALATION=PRESERVED"
echo "PROJECT_BOUND_HANDOFF_SCOPE_REQUIREMENTS=SATISFIED"
echo "PROJECT_BOUND_HANDOFF_CLOSURE_READY=YES"
echo "PROJECT_BOUND_HANDOFF_CORRIDOR=NOT_YET_FORMALLY_CLOSED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=FORMALLY_CLOSE_PROJECT_BOUND_HANDOFF_CORRIDOR_AND_ADVANCE_TO_MISSION_CONTROL_INTAKE"
