
import express from "express";

const router = express.Router();

router.get("/authority-snapshot", (req: any, res) => {

  res.json({

    status: "ok",

    authority: req.authority ?? null

  });

});

export { router };

export default router;

