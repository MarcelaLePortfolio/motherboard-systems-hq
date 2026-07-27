import type { MissionReadModel } from "./missionReadApi";

export interface MissionPresentationModel {
  packageId: string;
  projectId: string | null;
  version: number;

  stage: string;
  owner: string;
  health: string;
  awaiting: string | null;

  artifactCount: number;
  lifecycleEventCount: number;
  integrityWarnings: string[];
  latestTimestamp: string | null;

  timeline: MissionReadModel["timeline"];
}

export function mapMissionReadToPresentation(
  mission: MissionReadModel,
): MissionPresentationModel {
  return {
    packageId: mission.identity.package_id,
    projectId: mission.identity.project_id,
    version: mission.identity.package_version,

    stage: mission.stage,
    owner: mission.owner,
    health: mission.health,
    awaiting: mission.awaiting,

    artifactCount: mission.evidence.artifact_count,
    lifecycleEventCount: mission.evidence.lifecycle_event_count,
    integrityWarnings: [...mission.evidence.integrity_warnings],
    latestTimestamp: mission.evidence.latest_timestamp,

    timeline: [...mission.timeline],
  };
}
