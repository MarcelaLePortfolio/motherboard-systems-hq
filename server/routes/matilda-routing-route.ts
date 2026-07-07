
import express from "express";

import { createRouting } from "../../db/matilda-routing-runtime.js";

const router = express.Router();

router.post("/api/matilda/routing", (req, res) => {

  try {

    const {

      envelope_id,

      package_id,

      lineage_id,

      routing_destination,

    } = req.body;

    const routing = createRouting({

      envelope_id,

      package_id,

      lineage_id,

      routing_destination,

    });

    return res.json({

      ok: true,

      route: "matilda_routing_route",

      routing,

      assignment_authorized: false,

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

