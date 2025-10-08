import express from "express";
import { generateCognitiveLesson, getCognitiveHistory } from "../pipelines/cognitiveCohesion";

const router = express.Router();

router.post("/synthesize", (_req, res) => {
  try {
    const lesson = generateCognitiveLesson();
    res.json({ ok: true, lesson });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

router.get("/history", (_req, res) => {
  try {
    const history = getCognitiveHistory(50);
    res.json({ ok: true, history });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
