import express from "express";
import { generateMatildaInsights } from "../pipelines/insightPipeline";

const router = express.Router();

router.get("/", (_req, res) => {
  const insight = generateMatildaInsights();
  res.json({ ok: true, insight });
});

export default router;
