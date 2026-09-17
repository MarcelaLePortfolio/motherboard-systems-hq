export interface AtlasPreexecutionObservation {
  sourceKind?: string;
  sourceId?: string;
  observation?: string;
  [key: string]: unknown;
}

export interface AtlasPreexecutionResponse {
  status: "ok";
  route: "atlas_preexecution_read_route";
  projectId: string;
  observations: AtlasPreexecutionObservation[];
  lineageSequences: unknown[];
  causalExplanation: false;
  executionHistory: false;
  approvalDecision: false;
  authorityDecision: false;
}

export async function getAtlasPreexecution(
  projectId: string,
  conversationId: string,
): Promise<AtlasPreexecutionResponse> {
  const params = new URLSearchParams({
    projectId,
    conversationId,
  });

  const response = await fetch(`/atlas/preexecution?${params.toString()}`, {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(
      `Unable to load Atlas pre-execution observations (${response.status}).`,
    );
  }

  return (await response.json()) as AtlasPreexecutionResponse;
}
