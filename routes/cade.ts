import express from "express";
import { db } from "../db/client.ts";
import { task_events } from "../db/audit.ts";
import { desc } from "drizzle-orm";

export const cadeRouter = express.Router();

// GET /cade/recent → returns Cade’s recent task events
cadeRouter.get("/recent", async (_req, res) => {
  try {
    const rows = db
      .select()
      .from(task_events)
      .where(task_events.actor.eq("cade"))
      .orderBy(desc(task_events.created_at))
      .limit(10)
      .all();
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching Cade events:", err);
    res.status(500).json({ error: "Failed to fetch Cade events" });
  }
});
