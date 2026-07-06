
import express from "express";

import {

  createInterpretationEvidenceLedgerEntry,

  listInterpretationEvidenceLedgerEntries,

} from "../../db/matilda-interpretation-runtime.ts";

export function createMatildaInterpretationLedgerRouter(): express.Router {

  const router = express.Router();

  router.post("/api/matilda/interpretation-ledger", (req, res) => {

    try {

      const entry = createInterpretationEvidenceLedgerEntry(req.body || {});

      return res.status(201).json({

        ok: true,

        route: "matilda_interpretation_ledger_route",

        entry,

        package_created: false,

        delegation_authorized: false,

        validation_authorized: false,

        envelope_authorized: false,

        execution_authorized: false,

        findings: [

          "Matilda Interpretation Evidence Ledger entry created as a collaboration artifact only.",

        ],

      });

    } catch (error) {

      return res.status(400).json({

        ok: false,

        route: "matilda_interpretation_ledger_route",

        error: error instanceof Error ? error.message : String(error),

        package_created: false,

        delegation_authorized: false,

        validation_authorized: false,

        envelope_authorized: false,

        execution_authorized: false,

      });

    }

  });

  router.get("/api/matilda/interpretation-ledger", (req, res) => {

    const limit = Number(req.query.limit || 20);

    return res.json({

      ok: true,

      route: "matilda_interpretation_ledger_route",

      entries: listInterpretationEvidenceLedgerEntries(limit),

      package_created: false,

      delegation_authorized: false,

      validation_authorized: false,

      envelope_authorized: false,

      execution_authorized: false,

    });

  });

  return router;

}

export default createMatildaInterpretationLedgerRouter();

