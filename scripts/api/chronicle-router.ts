import express from "express";
import fs from "fs";
import path from "path";

const router = express.Router();

/**
 * GET /chronicle/list
 * -------------------
 * Returns the most recent Chronicle events for dashboard display.
 */
router.get("/list", (req, res) => {
  try {
    const chroniclePath = path.join(process.cwd(), "logs", "system-chronicle.jsonl");
    if (!fs.existsSync(chroniclePath)) {
      return res.json({ ok: true, log: [] });
    }

    const lines = fs.readFileSync(chroniclePath, "utf8")
      .trim()
      .split("\n")
      .slice(-100) // latest 100 events
      .map(l => JSON.parse(l));

    res.json({ ok: true, log: lines });
  } catch (err: any) {
    console.error("❌ Chronicle list error:", err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
});

export default router;

/**
 * DELETE /chronicle/clear
 * -----------------------
 * Clears all Chronicle logs (used by the dashboard reset button).
 */
router.delete("/clear", (req, res) => {
  try {
    const chroniclePath = path.join(process.cwd(), "logs", "system-chronicle.jsonl");
    if (fs.existsSync(chroniclePath)) {
      fs.writeFileSync(chroniclePath, "", "utf8");
    }
    res.json({ ok: true, message: "Chronicle cleared." });
  } catch (err: any) {
    console.error("❌ Chronicle clear error:", err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
});
