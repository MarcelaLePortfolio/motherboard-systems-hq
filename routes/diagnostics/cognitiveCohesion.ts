import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "<0001fab9> Cognitive Cohesion route active"
  });
});

export default router;
