
import express from "express";

import { createAssignment } from "../../db/matilda-assignment-runtime.js";

const router = express.Router();

router.post("/api/matilda/assignment", (req, res) => {

  try {

    const {

      routing_id,

      package_id,

      lineage_id,

      assigned_agent,

    } = req.body;

    const assignment = createAssignment({

      routing_id,

      package_id,

      lineage_id,

      assigned_agent,

    });

    return res.json({

      ok: true,

      route: "matilda_assignment_route",

      assignment,

      execution_authorized: false,

    });

  } catch (err) {

    return res.status(400).json({

      ok: false,

      error: err instanceof Error ? (err as any).message : "Unknown error",

    });

  }

});

export default router;

