import express from "express";
import { runReflectiveSynthesis, getLessons } from "../pipelines/reflectiveFeedback";

const router = express.Router();

/** POST /reflective/run — generate new reflective synthesis */
router.post("/run", (_req, res) => {
  try {
    const lesson = runReflectiveSynthesis();
    res.json({ ok: true, lesson });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /reflective/lessons — list stored lessons */
router.get("/lessons", (_req, res) => {
  try {
    const lessons = getLessons(50);
    res.json({ ok: true, lessons });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
