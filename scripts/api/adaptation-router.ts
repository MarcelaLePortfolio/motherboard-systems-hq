import express from "express";
import { applyAdaptiveTuning, getAdaptations } from "../pipelines/autonomicAdaptation";

const router = express.Router();

/** POST /adaptation/run — execute adaptive adjustment */
router.post("/run", (_req, res) => {
  try {
    const result = applyAdaptiveTuning();
    res.json({ ok: true, result });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /adaptation/history — list adaptation logs */
router.get("/history", (_req, res) => {
  try {
    const logs = getAdaptations(50);
    res.json({ ok: true, logs });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
