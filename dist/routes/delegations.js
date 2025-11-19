// ✅ Phase 7.7.1 — Delegation Logging Route (isolated for testing)
import express from "express";
import { sqlite } from "../db/client";
const router = express.Router();
router.post("/", (req, res) => {
    try {
        const { description, event_type = "delegation", agent = "Cade", status = "pending" } = req.body;
        const stmt = sqlite.prepare(`
      INSERT INTO task_events (description, event_type, agent, status)
      VALUES (?, ?, ?, ?)
    `);
        const result = stmt.run(description, event_type, agent, status);
        res.status(200).send(`✅ Delegation logged with ID ${result.lastInsertRowid}`);
    }
    catch (err) {
        console.error("❌ Error inserting task:", err);
        res.status(500).send("Failed to insert task event.");
    }
});
export default router;
