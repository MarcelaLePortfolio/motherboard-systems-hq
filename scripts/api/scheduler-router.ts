import express from "express";
import { listSchedules, createOrUpdateSchedule, enableSchedule, disableSchedule, runNow } from "../scheduler/engine";

const router = express.Router();

/** List all schedules */
router.get("/list", (_req, res) => {
  res.json({ ok: true, tasks: listSchedules() });
});

/** Create or update a schedule */
router.post("/upsert", (req, res) => {
  try {
    const { id, action, intervalSec, enabled = true, note } = req.body || {};
    if (!id || !action || !intervalSec) return res.status(400).json({ ok: false, error: "Missing id, action, or intervalSec." });
    const task = createOrUpdateSchedule({ id, action, intervalSec, enabled, note });
    res.json({ ok: true, task });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** Enable a schedule */
router.post("/enable", (req, res) => {
  try {
    const { id } = req.body || {};
    if (!id) return res.status(400).json({ ok: false, error: "Missing id." });
    const task = enableSchedule(id);
    res.json({ ok: true, task });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** Disable a schedule */
router.post("/disable", (req, res) => {
  try {
    const { id } = req.body || {};
    if (!id) return res.status(400).json({ ok: false, error: "Missing id." });
    const task = disableSchedule(id);
    res.json({ ok: true, task });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** Run a schedule immediately */
router.post("/runNow", async (req, res) => {
  try {
    const { id } = req.body || {};
    if (!id) return res.status(400).json({ ok: false, error: "Missing id." });
    const result = await runNow(id);
    res.json({ ok: true, result });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
