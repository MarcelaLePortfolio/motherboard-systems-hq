export type MissionStage =
  | "INTERPRETATION"
  | "GOVERNANCE_VALIDATION"
  | "DELEGATION"
  | "ASSIGNMENT"
  | "EXECUTION"
  | "REVIEW"
  | "ARCHIVED"
  | "ENVELOPE_CREATED"
  | string;

export type MissionOwner = string;

export type MissionHealth =
  | "HEALTHY"
  | "WARNING"
  | "BLOCKED"
  | "UNKNOWN"
  | string;

export interface MissionIdentity {
  package_id: string;
  package_version: number;
  project_id: string | null;
}

export interface MissionEvidence {
  artifact_count: number;
  lifecycle_event_count: number;
  integrity_warnings: string[];
  latest_timestamp: string | null;
}

export interface MissionTimelineEntry {
  stage?: string;
  event_type?: string;
  timestamp?: string | null;
  [key: string]: unknown;
}

export interface MissionReadModel {
  identity: MissionIdentity;
  requested_outcome: string;
  stage: MissionStage;
  owner: MissionOwner;
  health: MissionHealth;
  awaiting: string | null;
  evidence: MissionEvidence;
  timeline: MissionTimelineEntry[];
}

interface MissionReadSuccessResponse {
  ok: true;
  mission: MissionReadModel;
}

interface MissionReadErrorResponse {
  ok: false;
  error: string;
}

type MissionReadResponse =
  | MissionReadSuccessResponse
  | MissionReadErrorResponse;

export class MissionReadNotFoundError extends Error {
  constructor(readonly packageId: string) {
    super(`Mission package "${packageId}" was not found.`);
    this.name = "MissionReadNotFoundError";
  }
}

export class MissionReadRequestError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = "MissionReadRequestError";
  }
}

export class MissionReadProjectMismatchError extends Error {
  constructor(
    readonly packageId: string,
    readonly expectedProjectId: string,
    readonly actualProjectId: string | null,
  ) {
    super(
      `Mission package "${packageId}" does not belong to the active project.`,
    );
    this.name = "MissionReadProjectMismatchError";
  }
}

export async function getMissionReadModel(
  packageId: string,
  expectedProjectId?: string | null,
  signal?: AbortSignal,
): Promise<MissionReadModel> {
  const id = packageId.trim();
  const expectedProject = expectedProjectId?.trim() || null;

  if (!id) {
    throw new MissionReadRequestError(
      "A mission package ID is required.",
      400,
    );
  }

  const response = await fetch(
    `/api/mission-read/${encodeURIComponent(id)}`,
    {
      headers: { Accept: "application/json" },
      signal,
    },
  );

  let payload: MissionReadResponse;

  try {
    payload = (await response.json()) as MissionReadResponse;
  } catch {
    throw new MissionReadRequestError(
      `Mission Read API returned invalid JSON (${response.status}).`,
      response.status,
    );
  }

  if (response.status === 404) {
    throw new MissionReadNotFoundError(id);
  }

  if (!response.ok || !payload.ok) {
    throw new MissionReadRequestError(
      payload.ok ? "Mission Read request failed." : payload.error,
      response.status,
    );
  }

  if (
    expectedProject &&
    payload.mission.identity.project_id !== expectedProject
  ) {
    throw new MissionReadProjectMismatchError(
      id,
      expectedProject,
      payload.mission.identity.project_id,
    );
  }

  return payload.mission;
}
