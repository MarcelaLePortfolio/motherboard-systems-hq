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
      project_id
    FROM governance_packages
    WHERE package_id = ?
    LIMIT 1
  `);

  const lifecycleStatement = db.prepare(`
    SELECT
      lifecycle_state
    FROM governance_envelopes
    WHERE package_id = ?
    LIMIT 1
  `);

  const lifecycleCountStatement = db.prepare(`
    SELECT COUNT(*) AS count
    FROM governance_lifecycle_events
    WHERE package_id = ?
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
          }
        | undefined;

      if (!pkg) {
        return null;
      }

      const lifecycle = lifecycleStatement.get(packageId) as
        | {
            lifecycle_state: string | null;
          }
        | undefined;

      const count = lifecycleCountStatement.get(packageId) as {
        count: number;
      };

      return {
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        project_id: pkg.project_id,
        lifecycle_state: lifecycle?.lifecycle_state ?? null,
        lifecycle_event_count: count.count,
        integrity_warnings: [],
      };
    },
  };
}
