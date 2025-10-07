import express from "express";
import { captureNewInsight, getInsightHistory } from "../pipelines/persistentInsight";

const router = express.Router();

/** POST /insights/persist — capture & store a new insight */
router.post("/persist", (_req, res) => {
  try {
    const text = captureNewInsight();
    res.json({ ok: true, stored: text });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /insights/persistent — retrieve stored insight history */
router.get("/persistent", (_req, res) => {
  try {
    const history = getInsightHistory(50);
    res.json({ ok: true, ...history });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
