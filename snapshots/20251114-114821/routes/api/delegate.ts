import express from "express";

const router = express.Router();

// POST /delegate
router.post("/delegate", (req, res) => {
  try {
    const payload = JSON.stringify(req.body || {});
    const type = "task";
    const agent = "Matilda";

    const stmt = sqlite.prepare(
      "INSERT INTO task_events (type, agent, status, payload) VALUES (?, ?, ?, ?)"
    );

    const info = stmt.run(type, agent, "received", payload);

    reson({
      ok: true,
      message: "Task received",
      task_id: info.lastInsertRowid
    });
  } catch (err) {
    console.error("❌ /delegate error:", err);
    res.status(500)on({ ok: false, error: "delegate_error" });
  }
});

export default router;
