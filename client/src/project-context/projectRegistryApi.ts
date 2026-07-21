import type { ProjectRegistryState } from "./types";

const PROJECT_REGISTRY_ENDPOINT = "/api/projects/registry";
const ACTIVE_PROJECT_ENDPOINT = "/api/projects/active";

async function readProjectRegistryResponse(
  response: Response,
  fallbackMessage: string
): Promise<ProjectRegistryState> {
  if (!response.ok) {
    let message = fallbackMessage;

    try {
      const body = (await response.json()) as { error?: string };
      if (body.error) {
        message = body.error;
      }
    } catch {
      // Preserve the fallback message when the response is not JSON.
    }

    throw new Error(`${message} (${response.status} ${response.statusText})`);
  }

  return response.json() as Promise<ProjectRegistryState>;
}

export async function getProjectRegistry(): Promise<ProjectRegistryState> {
  const response = await fetch(PROJECT_REGISTRY_ENDPOINT);

  return readProjectRegistryResponse(
    response,
    "Failed to load Project Registry"
  );
}

export async function setActiveProject(
  projectId: string
): Promise<ProjectRegistryState> {
  const response = await fetch(ACTIVE_PROJECT_ENDPOINT, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ projectId }),
  });

  return readProjectRegistryResponse(
    response,
    "Failed to update Active Context"
  );
}
