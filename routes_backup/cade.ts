import express, { Request, Response } from "express";
const router = express.Router();







import { db } from "../db/client";
import { task_events } from "../db/audit";
import { desc } from "drizzle-orm";


// GET /cade/recent → returns Cade’s recent task events
  try {
    const rows = db
      .select()
      .from(task_events)
      .where(task_events.agent.eq("Cade"))
      .orderBy(desc(task_events.created_at))
      .limit(10)
      .all();
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching Cade events:", err);
    res.status(500).json({ error: "Failed to fetch Cade events" });
  }
});
