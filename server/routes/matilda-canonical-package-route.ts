
import express from "express";

import { createCanonicalPackageFromApprovedSummary } from "../../db/matilda-canonical-package-runtime.js";

const router = express.Router();

router.post("/api/matilda/canonical-package", (req, res) => {

  try {

    const result = createCanonicalPackageFromApprovedSummary(req.body);

    return res.json({

      ok: true,

      route: "matilda_canonical_package_route",

      package: result,

      delegation_authorized: false,

      validation_authorized: false,

      envelope_authorized: false,

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

