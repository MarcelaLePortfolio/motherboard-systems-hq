import { Router } from "express";
const router = Router();

router.get("/", (req, res) => {
  res.json({ ok: true, message: "<0001f9e1> Adaptation API active." });
});

export default router;
