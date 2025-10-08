import express from "express";
import { recordChronicle, getChronicle } from "../pipelines/systemChronicle";

const router = express.Router();

/** POST /chronicle/add — manual or system log entry */
router.post("/add", (req, res) => {
  try {
    const { event, detail } = req.body || {};
    const entry = recordChronicle(event || "manual-entry", detail || {});
    res.json({ ok: true, entry });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /chronicle/list — retrieve recent entries */
router.get("/list", (_req, res) => {
  try {
    const log = getChronicle(50);
    res.json({ ok: true, log });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
