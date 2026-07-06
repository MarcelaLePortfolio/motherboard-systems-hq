
import express from "express";

import {

  listLivingDraftPackages,

  upsertLivingDraftPackage,

} from "../../db/matilda-living-draft-runtime.ts";

export function createMatildaLivingDraftRouter(): express.Router {

  const router = express.Router();

  router.post("/api/matilda/living-draft", (req, res) => {

    try {

      const draft = upsertLivingDraftPackage(req.body || {});

      return res.status(201).json({

        ok: true,

        route: "matilda_living_draft_route",

        draft,

        canonical_package_created: false,

        delegation_authorized: false,

        validation_authorized: false,

        envelope_authorized: false,

        execution_authorized: false,

        findings: [

          "Living Draft Package created or updated as a non-authoritative interpretation artifact only.",

        ],

      });

    } catch (error) {

      return res.status(400).json({

        ok: false,

        route: "matilda_living_draft_route",

        error: error instanceof Error ? error.message : String(error),

        canonical_package_created: false,

        delegation_authorized: false,

        validation_authorized: false,

        envelope_authorized: false,

        execution_authorized: false,

      });

    }

  });

  router.get("/api/matilda/living-draft", (req, res) => {

    const limit = Number(req.query.limit || 20);

    return res.json({

      ok: true,

      route: "matilda_living_draft_route",

      drafts: listLivingDraftPackages(limit),

      canonical_package_created: false,

      delegation_authorized: false,

      validation_authorized: false,

      envelope_authorized: false,

      execution_authorized: false,

    });

  });

  return router;

}

export default createMatildaLivingDraftRouter();

