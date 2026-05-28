
import express from "express";

import {

  runGovernedPlanningPipeline,

} from "../execution/governed-planning-pipeline.mjs";

import {

  buildGovernedPlanningArtifactBundle,

} from "../execution/build-governed-planning-artifact-bundle.mjs";

import {

  normalizeGovernedResponse,

} from "../execution/normalize-governed-response.mjs";

const router = express.Router();

function buildPipelineInput(body = {}) {

  return {

    intent: {

      actor: body.actor || "Matilda",

      target: body.target || "Cade",

      objective:

        body.objective ||

        "Generate governed engineering plan",

      requested_outcome:

        body.requested_outcome ||

        "Dry-run reconciliation-ready planning artifact",

      raw_user_intent:

        body.raw_user_intent ||

        body.objective ||

        "Generate governed engineering plan",

      source:

        body.source ||

        "api_request",

      tags:

        Array.isArray(body.tags)

          ? body.tags

          : ["governance", "dry_run"],

    },

    mutation_scope: {

      scope_type: "file",

      allowed_paths:

        Array.isArray(body.allowed_paths)

          ? body.allowed_paths

          : ["docs/contracts/"],

      forbidden_paths:

        Array.isArray(body.forbidden_paths)

          ? body.forbidden_paths

          : ["secrets/", ".env"],

      scope_constraints:

        body.scope_constraints ||

        "Governed planning dry-run route scope",

    },

    execution_plan: {

      summary:

        body.objective ||

        "Generate governed engineering plan",

      steps:

        Array.isArray(body.steps)

          ? body.steps

          : [

              {

                step_id: "step-1",

                action: "inspect",

                target: "docs/contracts/example.md",

                instructions: "Plan only",

                expected_output:

                  "Dry-run governed planning artifact",

              },

            ],

    },

    patch_spec: {

      format: "structured_patch",

      patches:

        Array.isArray(body.proposed_changes)

          ? body.proposed_changes

          : [],

    },

  };

}

router.post(

  "/api/governed-planning/dry-run",

  async (req, res) => {

    try {

      const body = req.body || {};

      const input = buildPipelineInput(body);

      const pipelineResult =

        await runGovernedPlanningPipeline(input);

      const bundle =

        buildGovernedPlanningArtifactBundle({

          pipelineResult,

        });

      return res.status(200).json({

        ok: true,

        route:

          "governed_planning_dry_run",

        mode:

          "planning_only",

        bundle,

      });

    } catch (err) {

      const response =

        normalizeGovernedResponse({

          ok: false,

          phase: "governance_failed",

          mutation_performed: false,

          shell_execution_performed: false,

          autonomous_execution_performed: false,

          error: {

            code:

              err.code ||

              "GOVERNED_PLANNING_ROUTE_FAILURE",

            message:

              err.message ||

              "unknown governed planning route error",

          },

        });

      return res.status(400).json({

        ok: false,

        failed_closed: true,

        route:

          "governed_planning_dry_run",

        mode:

          "planning_only",

        response,

      });

    }

  },

);

export default router;

