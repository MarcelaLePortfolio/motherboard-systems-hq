/*
 * Mission Read Repository
 *
 * Responsibilities:
 *  - Read authoritative governance persistence.
 *  - Return normalized assembler input.
 *  - Never derive executive state.
 *  - Never mutate persistence.
 *  - Never authorize execution.
 */

import type { MissionAssemblyInput } from "./mission-read-model-assembler";

export interface MissionReadRepository {
  loadMission(
    packageId: string,
  ): Promise<MissionAssemblyInput | null>;
}

/*
 * Temporary stub.
 *
 * The next implementation corridor will replace this with
 * authoritative SQLite queries against governance persistence.
 */
export const missionReadRepository: MissionReadRepository = {
  async loadMission(): Promise<MissionAssemblyInput | null> {
    return null;
  },
};
