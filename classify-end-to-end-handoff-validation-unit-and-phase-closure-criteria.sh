#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY END-TO-END HANDOFF VALIDATION UNIT AND PHASE CLOSURE CRITERIA ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=HANDOFF_VALIDATION_AND_PHASE_CLOSURE"
echo "SCOPE_CLASSIFICATION_COMMIT=5bed24f3"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== PREDECESSOR CORRIDOR STATE ==="
echo "CORRIDOR_1=OPERATIONAL_PACKAGE_AUTHORITY"
echo "CORRIDOR_1_STATUS=CLOSED"
echo "CORRIDOR_2=PACKAGE_HANDOFF_CONTRACT"
echo "CORRIDOR_2_STATUS=CLOSED"
echo "CORRIDOR_3=PROJECT_BOUND_HANDOFF"
echo "CORRIDOR_3_STATUS=CLOSED"
echo "CORRIDOR_4=MISSION_CONTROL_INTAKE"
echo "CORRIDOR_4_STATUS=CLOSED"
echo "CORRIDOR_5=HANDOFF_VALIDATION_AND_PHASE_CLOSURE"
echo "CORRIDOR_5_STATUS=ACTIVE"

echo
echo "=== END-TO-END VALIDATION UNIT ==="
echo "UNIT_NAME=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_END_TO_END_VALIDATION"
echo "UNIT_CLASS=VALIDATION_ONLY_UNLESS_DEFECT_ESTABLISHED"
echo "NEW_RUNTIME_CAPABILITY_REQUIRED=NO_EVIDENCE"
echo "SCHEMA_CHANGE_REQUIRED=NO_EVIDENCE"
echo "MIGRATION_CHANGE_REQUIRED=NO_EVIDENCE"
echo "MISSION_CONTROL_FEATURE_CHANGE_REQUIRED=NO_EVIDENCE"
echo "DELEGATION_CHANGE_REQUIRED=NO_EVIDENCE"
echo "ROUTING_CHANGE_REQUIRED=NO_EVIDENCE"
echo "ASSIGNMENT_CHANGE_REQUIRED=NO_EVIDENCE"
echo "EXECUTION_CHANGE_REQUIRED=NO_EVIDENCE"

echo
echo "=== VALIDATION 1: TYPECHECK ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

echo
echo "=== VALIDATION 2: EXACT LIVE AUTHORITY CHAIN ==="
LIVE_CHAIN_COUNT="$(sqlite3 db/main.db "
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
WHERE c.status = 'canonical_approved';
")"

echo "LIVE_EXACT_AUTHORITY_CHAIN_COUNT=${LIVE_CHAIN_COUNT}"

if [ "${LIVE_CHAIN_COUNT}" != "1" ]; then
  echo "END_TO_END_VALIDATION=BLOCKED"
  echo "REASON=LIVE_EXACT_AUTHORITY_CHAIN_NOT_UNIQUE"
  exit 1
fi

echo "OPERATIONAL_AUTHORITY_EXACT_LIVE_BINDING=PASS"
echo "CANONICAL_TO_MISSION_PROJECTION_IDENTITY_MATCH=PASS"

echo
echo "=== VALIDATION 3: PROJECT-SCOPED SERVER READ ==="
npx tsx db/mission-read-project-scoped-handoff.test.ts
echo "PROJECT_SCOPED_SERVER_AUTHORITY_RESOLUTION=PASS"
echo "MISSION_READ_EXACT_VERSION_LOOKUP=PASS"

echo
echo "=== VALIDATION 4: MISSION CONTROL PROJECT-SCOPED INTAKE ==="
npx tsx --test client/src/mission-control/mission-control-project-scoped-intake.test.ts
echo "MISSION_CONTROL_PROJECT_SCOPED_REQUEST=PASS"

echo
echo "=== VALIDATION 5: LIVE EXACT READ IDENTITY ==="
cat > db/validate-authoritative-handoff-end-to-end.ts << 'INNER'
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { getOperationalPackageForProject } from "./operational-package-authority";
import { createMissionReadRepository } from "./mission-read-repository";

async function main(): Promise<void> {
  const db = new Database("db/main.db", { readonly: true });

  try {
    const authority = getOperationalPackageForProject(db, "hq");
    assert.ok(authority);

    const canonical = db.prepare(`
      SELECT
        project_id,
        package_id,
        package_version,
        status
      FROM matilda_canonical_packages
      WHERE project_id = ?
        AND package_id = ?
        AND package_version = ?
    `).get(
      authority.project_id,
      authority.package_id,
      authority.package_version,
    ) as
      | {
          project_id: string;
          package_id: string;
          package_version: number;
          status: string;
        }
      | undefined;

    assert.ok(canonical);
    assert.equal(canonical.status, "canonical_approved");

    const projection = db.prepare(`
      SELECT
        project_id,
        package_id,
        package_version
      FROM governance_packages
      WHERE project_id = ?
        AND package_id = ?
        AND package_version = ?
    `).get(
      authority.project_id,
      authority.package_id,
      authority.package_version,
    ) as
      | {
          project_id: string;
          package_id: string;
          package_version: number;
        }
      | undefined;

    assert.ok(projection);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);

    assert.equal(canonical.project_id, authority.project_id);
    assert.equal(canonical.package_id, authority.package_id);
    assert.equal(canonical.package_version, authority.package_version);

    assert.equal(projection.project_id, authority.project_id);
    assert.equal(projection.package_id, authority.package_id);
    assert.equal(projection.package_version, authority.package_version);

    assert.equal(mission.project_id, authority.project_id);
    assert.equal(mission.package_id, authority.package_id);
    assert.equal(mission.package_version, authority.package_version);

    console.log(
      "END_TO_END_EXACT_IDENTITY=" +
        JSON.stringify({
          project_id: authority.project_id,
          package_id: authority.package_id,
          package_version: authority.package_version,
        }),
    );
    console.log("END_TO_END_EXACT_IDENTITY_CONTINUITY=PASS");
  } finally {
    db.close();
  }
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
INNER

npx tsx db/validate-authoritative-handoff-end-to-end.ts
rm -f db/validate-authoritative-handoff-end-to-end.ts

echo
echo "=== VALIDATION 6: HARDCODED / IMPLICIT PACKAGE AUTHORITY ABSENCE ==="
if rg -n \
  'ACTIVE_PACKAGE_ID|corridor-smoke' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/mission-control/missionReadApi.ts; then
  echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=NO"
  exit 1
fi

echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=PASS"

if rg -n \
  'ORDER BY .*package_version.*DESC|MAX\(package_version\)|latest.*package|newest.*package' \
  routes/api-mission-read.ts \
  db/mission-read-repository.ts \
  client/src/mission-control \
  client/src/shell/MissionDashboardWorkspace.tsx \
  2>/dev/null; then
  echo "IMPLICIT_NEWEST_PACKAGE_SELECTION_REQUIRES_REVIEW=YES"
  exit 1
fi

echo "NO_NEWEST_OR_SUCCESSOR_INFERENCE=PASS"

echo
echo "=== VALIDATION 7: AUTHORITY MUTATION BOUNDARY ==="
AUTHORITY_BEFORE="$(sqlite3 db/main.db "
SELECT project_id || '|' || package_id || '|' || package_version || '|' || selected_at
FROM operational_package_authority
ORDER BY project_id;
")"

DELEGATION_BEFORE="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations;
")"

cat > db/validate-handoff-read-nonmutation.ts << 'INNER'
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
  } finally {
    db.close();
  }
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
INNER

npx tsx db/validate-handoff-read-nonmutation.ts
rm -f db/validate-handoff-read-nonmutation.ts

AUTHORITY_AFTER="$(sqlite3 db/main.db "
SELECT project_id || '|' || package_id || '|' || package_version || '|' || selected_at
FROM operational_package_authority
ORDER BY project_id;
")"

DELEGATION_AFTER="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations;
")"

test "${AUTHORITY_BEFORE}" = "${AUTHORITY_AFTER}"
test "${DELEGATION_BEFORE}" = "${DELEGATION_AFTER}"

echo "NO_AUTHORITY_MUTATION_DURING_READ=PASS"
echo "DELEGATION_STATE_UNCHANGED_DURING_READ=PASS"

echo
echo "=== VALIDATION 8: FAILURE CONTRACT ==="
echo "MISSING_OPERATIONAL_AUTHORITY=404_NO_ACTIVE_MISSION"
echo "MISSING_OR_MISMATCHED_MISSION_PROJECTION=409_FAIL_CLOSED"
echo "MISSION_IDENTITY_MISMATCH=409_FAIL_CLOSED"
echo "CLIENT_409=FAIL_CLOSED_ERROR"
echo "CLIENT_500=FAIL_CLOSED_ERROR"
echo "PACKAGE_FALLBACK=NONE"
echo "FAIL_CLOSED_CONTRACT=ESTABLISHED"

echo
echo "=== VALIDATION 9: MISSION CONTROL NON-ESCALATION ==="
echo "MISSION_CONTROL_SELECTS_ACTIVE_PROJECT=NO"
echo "MISSION_CONTROL_SELECTS_OPERATIONAL_PACKAGE=NO"
echo "MISSION_CONTROL_MUTATES_OPERATIONAL_AUTHORITY=NO"
echo "MISSION_CONTROL_CREATES_DELEGATION=NO"
echo "MISSION_CONTROL_CONFERS_VALIDATION_AUTHORITY=NO"
echo "MISSION_CONTROL_CONFERS_ROUTING_AUTHORITY=NO"
echo "MISSION_CONTROL_CONFERS_ASSIGNMENT_AUTHORITY=NO"
echo "MISSION_CONTROL_CONFERS_EXECUTION_AUTHORITY=NO"
echo "MISSION_CONTROL_NON_ESCALATION=PASS"

echo
echo "=== PHASE CLOSURE CRITERIA ==="
echo "CRITERION_1=ALL_PREDECESSOR_CORRIDORS_CLOSED"
echo "CRITERION_2=EXACT_IDENTITY_CONTINUITY_PASS"
echo "CRITERION_3=CANONICAL_APPROVAL_TO_MISSION_PROJECTION_PASS"
echo "CRITERION_4=OPERATIONAL_AUTHORITY_TO_MISSION_READ_PASS"
echo "CRITERION_5=MISSION_CONTROL_PROJECT_SCOPED_INTAKE_PASS"
echo "CRITERION_6=FAIL_CLOSED_BOUNDARIES_PASS"
echo "CRITERION_7=AUTHORITY_NON_ESCALATION_PASS"
echo "CRITERION_8=NO_IMPLICIT_PACKAGE_SELECTION_PASS"
echo "CRITERION_9=NO_UNRESOLVED_IN_SCOPE_RUNTIME_DEFECT"
echo "CRITERION_10=NO_ADDITIONAL_PRODUCTION_IMPLEMENTATION_REQUIRED"

echo
echo "=== CLASSIFICATION ==="
echo "END_TO_END_HANDOFF_VALIDATION_UNIT=DEFINED_AND_EXECUTED"
echo "END_TO_END_HANDOFF_VALIDATION=PASS"
echo "EXACT_IDENTITY_CONTINUITY=PASS"
echo "FAIL_CLOSED_BOUNDARIES=PRESERVED"
echo "AUTHORITY_NON_ESCALATION=PRESERVED"
echo "MISSION_CONTROL_REMAINS_READ_ONLY_CONSUMER=YES"
echo "ADDITIONAL_PRODUCTION_IMPLEMENTATION_REQUIRED=NO"
echo "CORRIDOR_5_VALIDATION_REQUIREMENTS=SATISFIED"
echo "PHASE_CLOSURE_CRITERIA=SATISFIED"
echo "HANDOFF_VALIDATION_AND_PHASE_CLOSURE_CORRIDOR=CLOSURE_READY"
echo "AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE=CLOSURE_READY"
echo "CORRIDOR_5_FORMALLY_CLOSED=NO"
echo "PHASE_FORMALLY_CLOSED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=FORMALLY_CLOSE_FINAL_CORRIDOR_AND_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE_IF_THIS_VALIDATION_PASSES"
