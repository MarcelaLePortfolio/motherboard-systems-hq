import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "🎨 Insight Visualizer route active"
  });
});

export default router;
