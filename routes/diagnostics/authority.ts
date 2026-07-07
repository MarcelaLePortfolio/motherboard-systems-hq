
import express from "express";

import { evaluateAuthority } from "../../server/authority/authority-gate";

const router = express.Router();

router.get("/authority", (_req, res) => {

  const result = evaluateAuthority();

  res.json({

    status: "ok",

    authority: result

  });

});

export { router };

export default router;

