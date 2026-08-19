/*
 * Mission Read Repository
 *
 * Read-only persistence adapter for the Mission Read Model.
 * This layer retrieves authoritative governance evidence only.
 * State derivation remains the responsibility of the assembler.
 */

import type { Database } from "better-sqlite3";
import type { MissionAssemblyInput } from "./mission-read-model-assembler";

export interface MissionReadRepository {
  loadMission(
    packageId: string,
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
    WHERE package_id = ?
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
      packageId: string,
    ): Promise<MissionAssemblyInput | null> {
      const pkg = packageStatement.get(packageId) as
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
