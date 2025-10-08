import { Router } from "express";
const router = Router();

router.get("/", (req, res) => {
  res.json({ ok: true, message: "<0001f9e2> Insight Visualizer API active." });
});

export default router;
