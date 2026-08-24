import type { ProjectRegistryState } from "./types";

const PROJECT_REGISTRY_ENDPOINT = "/api/projects/registry";
const ACTIVE_PROJECT_ENDPOINT = "/api/projects/active";
const INSPECT_PROJECT_PATH_ENDPOINT = "/api/projects/inspect-path";
const REGISTER_PROJECT_ENDPOINT = "/api/projects/register";
const ARCHIVE_PROJECT_ENDPOINT = "/api/projects/archive";
const CREATE_PROJECT_ENDPOINT = "/api/projects/create";

export interface ProjectPathInspection {
  ok: boolean;
  inputPath: string;
  resolvedPath: string | null;
  projectDirectoryName: string | null;
  exists: boolean;
  isDirectory: boolean;
  isGitRepository: boolean;
  message: string;
}

export interface CreateProjectInput {
  parentDirectory: string;
  projectDirectoryName: string;
  projectId?: string;
  displayName?: string;
}

export interface RegisterProjectInput {
  projectId: string;
  displayName: string;
  projectRootPath: string;
}

async function readProjectRegistryResponse(
  response: Response,
  fallbackMessage: string
): Promise<ProjectRegistryState> {
  if (!response.ok) {
    let message = fallbackMessage;

    try {
      const body = (await response.json()) as { error?: string };
      if (body.error) message = body.error;
    } catch {}

    throw new Error(`${message} (${response.status} ${response.statusText})`);
  }

  return response.json() as Promise<ProjectRegistryState>;
}

export async function getProjectRegistry(): Promise<ProjectRegistryState> {
  return readProjectRegistryResponse(
    await fetch(PROJECT_REGISTRY_ENDPOINT),
    "Failed to load Project Registry"
  );
}

export async function setActiveProject(
  projectId: string
): Promise<ProjectRegistryState> {
  const response = await fetch(ACTIVE_PROJECT_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ projectId }),
  });

  return readProjectRegistryResponse(
    response,
    "Failed to update Active Context"
  );
}

export async function inspectProjectPath(
  projectRootPath: string
): Promise<ProjectPathInspection> {
  const response = await fetch(INSPECT_PROJECT_PATH_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ projectRootPath }),
  });

  if (!response.ok) {
    let message = "Unable to inspect project path.";
    try {
      const body = (await response.json()) as { error?: string };
      if (body.error) message = body.error;
    } catch {}
    throw new Error(`${message} (${response.status} ${response.statusText})`);
  }

  return response.json() as Promise<ProjectPathInspection>;
}

export async function registerProject(
  input: RegisterProjectInput
): Promise<ProjectRegistryState> {
  const response = await fetch(REGISTER_PROJECT_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });

  return readProjectRegistryResponse(response, "Failed to register project");
}

export async function archiveProject(
  projectId: string
): Promise<ProjectRegistryState> {
  const response = await fetch(ARCHIVE_PROJECT_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ projectId }),
  });

  return readProjectRegistryResponse(response, "Failed to archive project");
}

const RESTORE_PROJECT_ENDPOINT = "/api/projects/restore";

export async function restoreProject(
  projectId: string
): Promise<ProjectRegistryState> {
  const response = await fetch(RESTORE_PROJECT_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ projectId }),
  });

  return readProjectRegistryResponse(response, "Failed to restore project");
}

export async function createNewProject(
  input: CreateProjectInput
): Promise<ProjectRegistryState> {
  const response = await fetch(CREATE_PROJECT_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });

  return readProjectRegistryResponse(response, "Failed to create project");
}
