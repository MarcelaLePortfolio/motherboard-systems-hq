import express from "express";

import {
  CanonicalPackageSchemaUnavailableError,
  createCanonicalPackageFromApprovedSummary,
} from "../../db/matilda-canonical-package-runtime";

const router = express.Router();

router.post("/api/matilda/canonical-package", (req, res) => {
  try {
    const result = createCanonicalPackageFromApprovedSummary(req.body, {
      schemaReady: req.app.locals.canonicalPackageSchemaReady === true,
    });

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
    if (err instanceof CanonicalPackageSchemaUnavailableError) {
      return res.status(503).json({
        ok: false,
        error_code: err.code,
        error: err.message,
        delegation_authorized: false,
        validation_authorized: false,
        envelope_authorized: false,
        execution_authorized: false,
      });
    }

    return res.status(400).json({
      ok: false,
      error: err instanceof Error ? err.message : "Unknown error",
    });
  }
});

export default router;
