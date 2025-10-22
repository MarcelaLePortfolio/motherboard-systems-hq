import express from "express";
import { desc } from "drizzle-orm";
import { db } from "../db/client.ts";
import { task_events } from "../db/audit.ts";

export const logsRouter = express.Router();

// GET /logs/recent → returns last 10 task events
logsRouter.get("/recent", async (_req, res) => {
  try {
    const rows = db
      .select()
      .from(task_events)
      .orderBy(desc(task_events.created_at))
      .limit(10)
      .all();
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching logs:", err);
    res.status(500).json({ error: "Failed to fetch logs" });
  }
});
