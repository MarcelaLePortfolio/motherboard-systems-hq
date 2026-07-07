
import express from "express";

import { evaluateAuthority } from "../../server/authority/authority-gate";

const router = express.Router();

/**

 * Phase 3A: controlled runtime exposure

 * Still diagnostic-only (no execution coupling)

 */

router.get("/authority", (req, res) => {

  const mode = (req.query.mode as any) ?? "diagnostic";

  const source = (req.query.source as any) ?? "api";

  const result = evaluateAuthority({

    mode,

    source

  });

  res.json({

    status: "ok",

    input: { mode, source },

    authority: result

  });

});

export { router };

export default router;

