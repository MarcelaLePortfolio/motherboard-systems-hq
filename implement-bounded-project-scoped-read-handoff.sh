#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT BOUNDED PROJECT-SCOPED READ HANDOFF ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "AUTHORIZATION_COMMIT=711f5a87"
echo "IMPLEMENTATION_AUTHORIZED=YES"

cat > db/mission-read-repository.ts << 'TS'
/*
 * Mission Read Repository
 *
 * Read-only persistence adapter for the Mission Read Model.
 * This layer retrieves authoritative governance evidence only.
 * State derivation remains the responsibility of the assembler.
 */

import type { Database } from "better-sqlite3";
import type { MissionAssemblyInput } from "./mission-read-model-assembler";

export interface MissionReadIdentity {
  project_id: string;
  package_id: string;
  package_version: number;
}

export interface MissionReadRepository {
  loadMission(
    identity: MissionReadIdentity,
  ): Promise<MissionAssemblyInput | null>;
}

export function createMissionReadRepository(
  db: Database,
): MissionReadRepository {
  const packageStatement = db.prepare(`
    SELECT
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    FROM governance_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 1
  `);

  const delegationStatement = db.prepare(`
    SELECT authorization_state
    FROM governance_delegations
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const validationStatement = db.prepare(`
    SELECT validation_status
    FROM governance_validation_results
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const gateStatement = db.prepare(`
    SELECT gate_status
    FROM governance_envelope_gates
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const envelopeStatement = db.prepare(`
    SELECT
      envelope_id,
      lifecycle_state
    FROM governance_envelopes
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const lifecycleEventsStatement = db.prepare(`
    SELECT
      transition_authorization,
      persisted_at
    FROM governance_lifecycle_events
    WHERE envelope_id = ?
    ORDER BY persisted_at ASC, event_id ASC
  `);

  return {
    async loadMission(
      identity: MissionReadIdentity,
    ): Promise<MissionAssemblyInput | null> {
      const project_id = identity.project_id.trim();
      const package_id = identity.package_id.trim();

      if (
        !project_id ||
        !package_id ||
        !Number.isInteger(identity.package_version) ||
        identity.package_version < 1
      ) {
        return null;
      }

      const pkg = packageStatement.get(
        project_id,
        package_id,
        identity.package_version,
      ) as
        | {
            package_id: string;
            package_version: number;
            project_id: string | null;
            conversation_id: string | null;
            requested_outcome: string;
          }
        | undefined;

      if (!pkg) {
        return null;
      }

      if (
        pkg.project_id !== project_id ||
        pkg.package_id !== package_id ||
        pkg.package_version !== identity.package_version
      ) {
        return null;
      }

      const delegation = delegationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { authorization_state: string }
        | undefined;

      const validation = validationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { validation_status: string }
        | undefined;

      const gate = gateStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { gate_status: string }
        | undefined;

      const envelope = envelopeStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | {
            envelope_id: string;
            lifecycle_state: string | null;
          }
        | undefined;

      const lifecycleEvents = envelope
        ? (lifecycleEventsStatement.all(envelope.envelope_id) as Array<{
            transition_authorization: string;
            persisted_at: string;
          }>)
        : [];

      return {
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        project_id: pkg.project_id,
        conversation_id: pkg.conversation_id,
        requested_outcome: pkg.requested_outcome,
        authorization_state: delegation?.authorization_state ?? null,
        validation_status: validation?.validation_status ?? null,
        gate_status: gate?.gate_status ?? null,
        lifecycle_state: envelope?.lifecycle_state ?? null,
        lifecycle_event_count: lifecycleEvents.length,
        lifecycle_events: lifecycleEvents,
        integrity_warnings: [],
      };
    },
  };
}
TS

cat > routes/api-mission-read.ts << 'TS'
import express from "express";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "../db/mission-read-repository";
import { assembleMissionReadModel } from "../db/mission-read-model-assembler";
import { getOperationalPackageForProject } from "../db/operational-package-authority";

const router = express.Router();

/*
 * Mission Read is part of the governance persistence family.
 * Use the same authoritative database as governance-runtime
 * and the Mission Read integration tests.
 */
const db = new Database("db/main.db", {
  readonly: true,
});

router.get(
  "/api/mission-read/:projectId",
  async (req, res) => {
    try {
      const projectId = req.params.projectId?.trim();

      if (!projectId) {
        return res.status(400).json({
          ok: false,
          error: "Missing projectId.",
        });
      }

      const authority =
        getOperationalPackageForProject(db, projectId);

      if (!authority) {
        return res.status(404).json({
          ok: false,
          error: "No active operational mission for project.",
        });
      }

      if (authority.project_id !== projectId) {
        return res.status(409).json({
          ok: false,
          error: "Operational Package Authority project mismatch.",
        });
      }

      const repository = createMissionReadRepository(db);

      const mission = await repository.loadMission({
        project_id: authority.project_id,
        package_id: authority.package_id,
        package_version: authority.package_version,
      });

      if (!mission) {
        return res.status(409).json({
          ok: false,
          error: "Operational mission projection is missing or mismatched.",
        });
      }

      if (
        mission.project_id !== authority.project_id ||
        mission.package_id !== authority.package_id ||
        mission.package_version !== authority.package_version
      ) {
        return res.status(409).json({
          ok: false,
          error: "Operational mission identity mismatch.",
        });
      }

      return res.json({
        ok: true,
        mission: assembleMissionReadModel(mission),
      });
    } catch (error) {
      console.error("[Mission Read API]", error);

      return res.status(500).json({
        ok: false,
        error: "Unable to assemble Mission Read Model.",
      });
    }
  },
);

export default router;
TS

cat > db/mission-read-project-scoped-handoff.test.ts << 'TS'
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "./mission-read-repository";
import { getOperationalPackageForProject } from "./operational-package-authority";

function createDb(): Database.Database {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE project_registry (
      project_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX
      idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages (
      project_id,
      package_id,
      package_version
    );

    CREATE TABLE operational_package_authority (
      project_id TEXT PRIMARY KEY NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      selected_at TEXT NOT NULL,
      FOREIGN KEY (project_id)
        REFERENCES project_registry(project_id),
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(
          project_id,
          package_id,
          package_version
        )
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      validation_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      gate_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      lifecycle_state TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL
    );
  `);

  return db;
}

function seedSelectedPackage(
  db: Database.Database,
  version = 1,
): void {
  db.prepare(`
    INSERT INTO project_registry (
      project_id,
      display_name
    ) VALUES ('hq', 'HQ')
  `).run();

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES ('pkg-1', ?, 'hq', 'canonical_approved')
  `).run(version);

  db.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    ) VALUES ('pkg-1', ?, 'hq', 'conversation-1', 'Outcome')
  `).run(version);

  db.prepare(`
    INSERT INTO operational_package_authority (
      project_id,
      package_id,
      package_version,
      selected_at
    ) VALUES ('hq', 'pkg-1', ?, '2026-08-25T00:00:00.000Z')
  `).run(version);
}

async function testSelectedExactIdentity(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.project_id, "hq");
    assert.equal(mission.package_id, "pkg-1");
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testMissingProjectionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 1, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO operational_package_authority (
        project_id,
        package_id,
        package_version,
        selected_at
      ) VALUES ('hq', 'pkg-1', 1, '2026-08-25T00:00:00.000Z')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongProjectFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "other",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongVersionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 2,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testNewerVersionDoesNotAutoActivate(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 2, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome
      ) VALUES ('pkg-1', 2, 'hq', 'conversation-2', 'Newer outcome')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);
    assert.equal(authority.package_version, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testUnselectedProjectHasNoAuthority(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    assert.equal(
      getOperationalPackageForProject(db, "hq"),
      null,
    );
  } finally {
    db.close();
  }
}

await testSelectedExactIdentity();
await testMissingProjectionFailsClosed();
await testWrongProjectFailsClosed();
await testWrongVersionFailsClosed();
await testNewerVersionDoesNotAutoActivate();
await testUnselectedProjectHasNoAuthority();

console.log(
  "Project-scoped Mission Read handoff targeted tests passed.",
);
TS

echo
echo "=== AUTHORITY STATE BEFORE VALIDATION ==="
AUTHORITY_BEFORE="$(sqlite3 db/main.db "
SELECT project_id || '|' || package_id || '|' || package_version || '|' || selected_at
FROM operational_package_authority
ORDER BY project_id;
")"
printf '%s\n' "${AUTHORITY_BEFORE}"

DELEGATION_BEFORE="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations;
")"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

echo
echo "=== TARGETED SERVER-SIDE TESTS ==="
npx tsx db/mission-read-project-scoped-handoff.test.ts

echo
echo "=== LIVE EXACT READ VALIDATION ==="
cat > db/validate-live-project-scoped-mission-read.ts << 'INNER'
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { getOperationalPackageForProject } from "./operational-package-authority";
import { createMissionReadRepository } from "./mission-read-repository";

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

  console.log(
    "LIVE_PROJECT_SCOPED_MISSION_READ=" +
      JSON.stringify({
        project_id: mission.project_id,
        package_id: mission.package_id,
        package_version: mission.package_version,
      }),
  );
} finally {
  db.close();
}
INNER

npx tsx db/validate-live-project-scoped-mission-read.ts
rm -f db/validate-live-project-scoped-mission-read.ts

AUTHORITY_AFTER="$(sqlite3 db/main.db "
SELECT project_id || '|' || package_id || '|' || package_version || '|' || selected_at
FROM operational_package_authority
ORDER BY project_id;
")"

DELEGATION_AFTER="$(sqlite3 db/main.db "
SELECT COUNT(*)
FROM governance_delegations;
")"

if [ "${AUTHORITY_BEFORE}" != "${AUTHORITY_AFTER}" ]; then
  echo "OPERATIONAL_AUTHORITY_STATE_UNCHANGED=NO"
  exit 1
fi

if [ "${DELEGATION_BEFORE}" != "${DELEGATION_AFTER}" ]; then
  echo "DELEGATION_STATE_UNCHANGED=NO"
  exit 1
fi

echo "OPERATIONAL_AUTHORITY_STATE_UNCHANGED=YES"
echo "DELEGATION_STATE_UNCHANGED=YES"

echo
echo "=== IMPLEMENTATION RESULT ==="
echo "SERVER_SIDE_PROJECT_SCOPED_AUTHORITY_RESOLUTION=IMPLEMENTED"
echo "MISSION_READ_EXACT_IDENTITY_LOOKUP=IMPLEMENTED"
echo "EXACT_SELECTED_VERSION_PRESERVED=YES"
echo "CALLER_PACKAGE_ID_AS_SELECTION_AUTHORITY=REMOVED_FROM_SERVER_BOUNDARY"
echo "NEWEST_PACKAGE_INFERENCE=NO"
echo "SUCCESSOR_VERSION_INFERENCE=NO"
echo "MISSION_CONTROL_UI_CHANGE=NO"
echo "MISSION_CONTROL_PROVIDER_CHANGE=NO"
echo "MISSION_CONTROL_WORKSPACE_CHANGE=NO"
echo "MISSION_CONTROL_INTAKE_STARTED=NO"
echo "OPERATIONAL_AUTHORITY_MUTATION=NO"
echo "DELEGATION_CHANGE=NO"
echo "ROUTING_CHANGE=NO"
echo "ASSIGNMENT_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_PROJECT_BOUND_HANDOFF_IMPLEMENTATION_AND_DETERMINE_CORRIDOR_CLOSURE_READINESS"
