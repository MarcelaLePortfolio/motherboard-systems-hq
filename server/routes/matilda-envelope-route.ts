
import express from "express";

import { createEnvelope } from "../../db/matilda-envelope-runtime.js";

const router = express.Router();

router.post("/api/matilda/envelope", (req, res) => {

  try {

    const {

      validation_id,

      delegation_id,

      package_id,

      lineage_id,

    } = req.body;

    const envelope = createEnvelope({

      validation_id,

      delegation_id,

      package_id,

      lineage_id,

    });

    return res.json({

      ok: true,

      route: "matilda_envelope_route",

      envelope,

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

