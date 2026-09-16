import express from "express";

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

export function createAtlasPreExecutionRouter(): express.Router {
  const router = express.Router();

  router.get("/atlas/preexecution", (req, res) => {
    try {
      const projectId = String(req.query.projectId ?? "");
      const conversationId = String(
        req.query.conversationId ?? "",
      );

      const result = readAtlasPreExecutionRoute({
        projectId,
        conversationId,
      });

      return res.json({
        status: "ok",
        route: "atlas_preexecution_read_route",
        projectId: result.projectId,
        observations: result.observations,
        lineageSequences: result.lineageSequences,
        causalExplanation: false,
        executionHistory: false,
        approvalDecision: false,
        authorityDecision: false,
      });
    } catch (error) {
      return res.status(400).json({
        status: "error",
        route: "atlas_preexecution_read_route",
        error:
          error instanceof Error
            ? error.message
            : String(error),
        causalExplanation: false,
        executionHistory: false,
        approvalDecision: false,
        authorityDecision: false,
      });
    }
  });

  return router;
}

export default createAtlasPreExecutionRouter();
