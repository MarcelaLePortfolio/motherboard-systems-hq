import express from "express";
import { sqlite } from "../../db/client";

const router = express.Router();

// POST /delegate
router.post("/delegate", (req, res) => {
  try {
    const { task } = req.body;

    const stmt = sqlite.prepare(`
      INSERT INTO task_events (type, status, created_at)
      VALUES (?, ?, CURRENT_TIMESTAMP)
    `);

    const result = stmt.run(task || "unknown_task", "queued");

    res.json({
      ok: true,
      delegated: true,
      id: result.lastInsertRowid,
    });
  } catch (err) {
    console.error("❌ /delegate error:", err);
    res.status(500).json({ ok: false, error: "delegate_error" });
  }
});

export default router;
