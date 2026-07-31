import type { MissionReadModel, MissionStage } from "./missionReadApi";

/**
 * Canonical Mission Progress sequence.
 *
 * Source: CLAUDE_TASK.md canonical stage list -- Intent, Governance,
 * Envelope, Assignment, Execution, Review, Complete.
 *
 * `DELEGATION` (a value permitted by the `MissionStage` type in
 * `missionReadApi.ts`) is intentionally not included here. Its position
 * relative to the other governed stages is not demonstrated anywhere in
 * the supplied frontend model or presentation authority documents, so
 * assigning it a sequence position would be an invented ordering rather
 * than a preserved one. A mission whose current stage is `DELEGATION`
 * falls through to the unrecognized-stage path in `buildProgressStages`
 * below: Mission Progress renders an explicit "not recognized" state
 * instead of a track. The raw `DELEGATION` value is not hidden -- it
 * continues to display normally anywhere the current stage is shown
 * generically (Mission Status, Executive Brief, Latest Event, Governance
 * History), since those surfaces format `mission.stage` directly and do
 * not depend on this sequence.
 */
const MISSION_PROGRESS_SEQUENCE: ReadonlyArray<{
  stage: MissionStage;
  label: string;
}> = [
  { stage: "INTERPRETATION", label: "Intent" },
  { stage: "GOVERNANCE_VALIDATION", label: "Governance" },
  { stage: "ENVELOPE_CREATED", label: "Envelope" },
  { stage: "ASSIGNMENT", label: "Assignment" },
  { stage: "EXECUTION", label: "Execution" },
  { stage: "REVIEW", label: "Review" },
  { stage: "ARCHIVED", label: "Complete" },
];

export type MissionProgressStatus = "complete" | "current" | "pending";

export interface MissionProgressStage {
  key: string;
  label: string;
  status: MissionProgressStatus;
}

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

  /**
   * Earliest recorded timeline timestamp, used as a "started" indicator on
   * Mission Status. Derived from existing timeline evidence (assumed
   * chronological, consistent with how the existing Governance Lifecycle
   * card already treats `timeline[timeline.length - 1]` as "current").
   * `null` when no timeline evidence exists.
   */
  startedTimestamp: string | null;

  /**
   * Operational lifecycle projection for the Mission Progress tracker.
   * `null` when the mission's current `stage` value is not a recognized
   * member of the canonical sequence -- in that case no stage is marked
   * complete or current, per the "no stage may be marked complete without
   * authoritative supporting state" rule.
   */
  progressStages: MissionProgressStage[] | null;

  /** 1-based position of the current stage within the sequence, or null. */
  progressPosition: number | null;

  /** Total number of stages in the canonical sequence. */
  progressTotal: number;

  /**
   * Label of the stage structurally next after the current one, derived
   * purely from sequence position (not a timing or ownership claim).
   * `null` at the final stage or when the current stage is unrecognized.
   */
  nextStageLabel: string | null;
}

function buildProgressStages(
  currentStage: MissionStage,
): {
  stages: MissionProgressStage[] | null;
  position: number | null;
  nextStageLabel: string | null;
} {
  const currentIndex = MISSION_PROGRESS_SEQUENCE.findIndex(
    (entry) => entry.stage === currentStage,
  );

  if (currentIndex === -1) {
    return { stages: null, position: null, nextStageLabel: null };
  }

  const stages: MissionProgressStage[] = MISSION_PROGRESS_SEQUENCE.map(
    (entry, index) => ({
      key: String(entry.stage),
      label: entry.label,
      status:
        index < currentIndex
          ? "complete"
          : index === currentIndex
            ? "current"
            : "pending",
    }),
  );

  const nextEntry = MISSION_PROGRESS_SEQUENCE[currentIndex + 1];

  return {
    stages,
    position: currentIndex + 1,
    nextStageLabel: nextEntry ? nextEntry.label : null,
  };
}

export function mapMissionReadToPresentation(
  mission: MissionReadModel,
): MissionPresentationModel {
  const { stages, position, nextStageLabel } = buildProgressStages(
    mission.stage,
  );

  const firstTimelineEntry = mission.timeline[0];

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

    startedTimestamp:
      (firstTimelineEntry?.timestamp as string | null | undefined) ?? null,

    progressStages: stages,
    progressPosition: position,
    progressTotal: MISSION_PROGRESS_SEQUENCE.length,
    nextStageLabel,
  };
}
