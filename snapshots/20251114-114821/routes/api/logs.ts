import express from "express";
import { sqlite } from "../../db/client";

const router = express.Router();

// GET /logs/recent
router.get("/logs/recent", (req, res) => {
  try {
    const rows = sqlite.prepare(
      "SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 20"
    ).all();

    res.json({ ok: true, logs: rows });
  } catch (err) {
    console.error("❌ /logs/recent error:", err);
    res.status(500).json({ ok: false, error: "log_fetch_error" });
  }
});

export default router;
