
import express from "express";

import { runGovernedPlanningPipeline }

  from "../execution/governed-planning-pipeline.mjs";

const router = express.Router();

function failClosed(message, code = "GOVERNED_PLANNING_ROUTE_ERROR") {

  const err = new Error(message);

  err.code = code;

  throw err;

}

router.post(

  "/api/governed-planning/dry-run",

  async (req, res) => {

    try {

      const body = req.body || {};

      failClosed(

        typeof body === "object",

        "request body required",

      );

      const result = await runGovernedPlanningPipeline({

        actor: body.actor || "Matilda",

        target: body.target || "Cade",

        objective:

          body.objective ||

          "Generate governed engineering plan",

        requested_outcome:

          body.requested_outcome ||

          "Dry-run reconciliation-ready planning artifact",

        source:

          body.source ||

          "api_request",

        tags:

          Array.isArray(body.tags)

            ? body.tags

            : ["governance", "dry_run"],

        proposed_changes:

          Array.isArray(body.proposed_changes)

            ? body.proposed_changes

            : [],

      });

      return res.status(200).json({

        ok: true,

        route: "governed_planning_dry_run",

        mode: "planning_only",

        mutation_performed: false,

        shell_execution_performed: false,

        autonomous_execution_performed: false,

        result,

      });

    } catch (err) {

      return res.status(400).json({

        ok: false,

        failed_closed: true,

        code:

          err.code ||

          "GOVERNED_PLANNING_ROUTE_FAILURE",

        message:

          err.message ||

          "unknown governed planning route error",

      });

    }

  },

);

export default router;

