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
      package_version
    FROM governance_packages
    WHERE package_id = ?
    LIMIT 1
  `);

  const envelopeStatement = db.prepare(`
    SELECT
      envelope_id,
      lifecycle_state
    FROM governance_envelopes
    WHERE package_id = ?
    LIMIT 1
  `);

  const lifecycleCountStatement = db.prepare(`
    SELECT COUNT(*) AS count
    FROM governance_lifecycle_events
    WHERE envelope_id = ?
  `);

  return {
    async loadMission(
      packageId: string,
    ): Promise<MissionAssemblyInput | null> {
      const pkg = packageStatement.get(packageId) as
        | {
            package_id: string;
            package_version: number;
          }
        | undefined;

      if (!pkg) {
        return null;
      }

      const envelope = envelopeStatement.get(packageId) as
        | {
            envelope_id: string;
            lifecycle_state: string | null;
          }
        | undefined;

      const lifecycleCount = envelope
        ? (lifecycleCountStatement.get(envelope.envelope_id) as { count: number })
        : { count: 0 };

      return {
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        project_id: null,
        lifecycle_state: envelope?.lifecycle_state ?? null,
        lifecycle_event_count: lifecycleCount.count,
        integrity_warnings: [],
      };
    },
  };
}
