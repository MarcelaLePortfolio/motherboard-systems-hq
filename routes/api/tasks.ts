import express from "express";
const router = express.Router();




// GET /tasks/recent
router.get("/tasks/recent", (req, res) => {
  try {
    const rows = db.prepare(
      "SELECT id, type, agent, status, payload, result, created_at FROM task_events ORDER BY created_at DESC LIMIT 20"
    ).all();

    res.json({ ok: true, tasks: rows });
  } catch (err) {
    console.error("❌ /tasks/recent error:", err);
    res.status(500).json({ ok: false, error: "task_fetch_error" });
  }
});

