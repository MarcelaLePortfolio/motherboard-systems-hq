import express from "express";
import { runAutonomicAudit, getReflections } from "../pipelines/autonomicFeedback";

const router = express.Router();

/** POST /autonomic/feedback — run immediate self-audit */
router.post("/feedback", (_req, res) => {
  try {
    const reflection = runAutonomicAudit();
    res.json({ ok: true, reflection });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /autonomic/reflections — get history of self-reflections */
router.get("/reflections", (_req, res) => {
  try {
    const reflections = getReflections(50);
    res.json({ ok: true, reflections });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
