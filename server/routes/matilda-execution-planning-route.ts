
import express from "express";

import { createExecutionPlan } from "../../db/matilda-execution-planning-runtime.ts";

const router = express.Router();

router.post("/api/matilda/execution-planning", (req, res) => {

  try {

    const {

      assignment_id,

      package_id,

      lineage_id,

      assigned_agent,

    } = req.body;

    const plan = createExecutionPlan({

      assignment_id,

      package_id,

      lineage_id,

      assigned_agent,

    });

    return res.json({

      ok: true,

      route: "matilda_execution_planning_route",

      execution_plan: plan,

      preview_generated: false,

      preview_confirmed: false,

      execution_authorized: false,

    });

  } catch (err) {

    return res.status(400).json({

      ok: false,

      error: err instanceof Error ? err.message : "Unknown error",

    });

  }

});

export default router;

