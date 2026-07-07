
import express from "express";

import { validateGovernance } from "../../db/matilda-governance-validation-runtime.js";

const router = express.Router();

router.post("/api/matilda/governance-validation", (req, res) => {

  try {

    const {

      delegation_id,

      package_id,

      lineage_id,

      validation_actor,

    } = req.body;

    const validation = validateGovernance({

      delegation_id,

      package_id,

      lineage_id,

      validation_actor,

    });

    return res.json({

      ok: true,

      route: "matilda_governance_validation_route",

      validation,

      envelope_created: false,

      routing_authorized: false,

      assignment_authorized: false,

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

