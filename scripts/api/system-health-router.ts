import express from "express";
import { runSystemHealthCheck } from "../pipelines/systemHealth";

const router = express.Router();

/** GET /system/health — run system health aggregation */
router.get("/health", (_req, res) => {
  try {
    const health = runSystemHealthCheck();
    res.json({ ok: true, health });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
