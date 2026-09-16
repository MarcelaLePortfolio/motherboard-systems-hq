import {
  readAtlasTypedPreexecutionObservations,
} from "../../atlas/atlas-preexecution-observation-aggregator";
import {
  reasonOverAtlasPreExecutionObservations,
} from "../../atlas/atlas-preexecution-structural-reasoner";

export type AtlasPreExecutionReadRouteInput = {
  projectId: string;
  conversationId: string;
  databasePath?: string;
};

function requireScopeValue(
  value: string,
  fieldName: "projectId" | "conversationId",
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(
      `${fieldName} is required for Atlas pre-execution observation.`,
    );
  }

  return normalized;
}

export function readAtlasPreExecutionRoute(
  input: AtlasPreExecutionReadRouteInput,
) {
  const projectId = requireScopeValue(
    input.projectId,
    "projectId",
  );
  const conversationId = requireScopeValue(
    input.conversationId,
    "conversationId",
  );

  const observations =
    readAtlasTypedPreexecutionObservations({
      projectId,
      conversationId,
      databasePath: input.databasePath,
    });

  const scopedObservations = observations.filter(
    (observation) =>
      observation.projectId === projectId
      && observation.conversationId === conversationId,
  );

  if (scopedObservations.length !== observations.length) {
    throw new Error(
      "Atlas pre-execution read route violated requested scope.",
    );
  }

  return reasonOverAtlasPreExecutionObservations(
    projectId,
    scopedObservations,
  );
}
