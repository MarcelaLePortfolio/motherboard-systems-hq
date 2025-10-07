import express from "express";
import { getRecentAuditEvents } from "../pipelines/opsStream";

const router = express.Router();

router.get("/", (_req, res) => {
  const events = getRecentAuditEvents(15);
  res.json({ ok: true, events });
});

export default router;
